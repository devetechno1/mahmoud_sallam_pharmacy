// Streaming downloads with HttpClient (no external packages).
// - Determines file name from Content-Disposition (fallback to URL) and ensures extension from Content-Type.
// - Supports pause/resume/cancel. No error recording on user cancel.
// - Uses HEAD as a fallback to get total size when GET doesn't provide Content-Length.
// - Saves into app documents (provided by caller via baseDir) so no runtime permissions are required.

import 'dart:async';
import 'dart:io';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../main.dart';
import 'media_store_saver.dart'; // for Color in ToastComponent

@immutable
class DownloadProgress {
  final int received;
  final int? total; // null if unknown (no Content-Length)
  final double? speedBytesPerSec; // can be null during initial ticks
  final Duration? eta;

  const DownloadProgress({
    required this.received,
    required this.total,
    required this.speedBytesPerSec,
    required this.eta,
  });

  double? get percent =>
      (total == null || total == 0) ? null : received / total!;
}

enum DownloadStatus { idle, running, paused, completed, failed, canceled }

class DownloadResult {
  final DownloadStatus status;
  final File? file;
  final String? fileName;
  final String? mimeType;
  final Object? error;
  final StackTrace? stackTrace;

  const DownloadResult.completed(this.file, {this.fileName, this.mimeType})
      : status = DownloadStatus.completed,
        error = null,
        stackTrace = null;

  const DownloadResult.canceled()
      : status = DownloadStatus.canceled,
        file = null,
        fileName = null,
        mimeType = null,
        error = null,
        stackTrace = null;

  const DownloadResult.failed(this.error, this.stackTrace)
      : status = DownloadStatus.failed,
        file = null,
        fileName = null,
        mimeType = null;
}

class DownloadTask {
  final Uri uri;
  final Map<String, String> headers;
  final Directory baseDir; // App documents from caller (no permissions needed)

  HttpClientRequest? _request;
  IOSink? _sink;

  bool _paused = false;
  bool _canceled = false;
  bool _userCanceled = false; // never record error when true

  File? _destFile;
  String? _resolvedFileName;
  String? _resolvedMime;

  DownloadTask({
    required this.uri,
    required this.baseDir,
    Map<String, String>? headers,
  }) : headers = headers ?? const {};

  // --- Utilities ---

  static String _safeFileName(String name) {
    // Remove illegal characters and trim spaces.
    var n = name.trim();
    n = n.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    if (n.isEmpty) n = 'file';
    return n;
  }

  static String? _fileNameFromContentDisposition(String? cd) {
    if (cd == null) return null;
    // Matches RFC 5987 filename* or simple filename=
    final fnStar =
        RegExp('filename\*\s*=\s*[^\'"]*\'\'([^;]+)', caseSensitive: false);
    final fn = RegExp(r'filename\s*=\s*"([^"]+)"|filename\s*=\s*([^;]+)',
        caseSensitive: false);

    final m1 = fnStar.firstMatch(cd);
    if (m1 != null) {
      final val = Uri.decodeFull((m1.group(1) ?? '').trim());
      return val.isEmpty ? null : val;
    }
    final m2 = fn.firstMatch(cd);
    if (m2 != null) {
      final v = (m2.group(1) ?? m2.group(2) ?? '').trim();
      return v.isEmpty ? null : v.replaceAll('"', '');
    }
    return null;
  }

  static String _extForMime(String? mime) {
    if (mime == null) return '';
    final m = mime.toLowerCase();
    if (m.contains('pdf')) return '.pdf';
    if (m.contains('jpeg') || m.contains('jpg')) return '.jpg';
    if (m.contains('png')) return '.png';
    if (m.contains('gif')) return '.gif';
    if (m.contains('webp')) return '.webp';
    if (m.contains('zip')) return '.zip';
    if (m.contains('json')) return '.json';
    if (m.contains('xml')) return '.xml';
    if (m.contains('mp4')) return '.mp4';
    if (m.contains('mpeg') || m.contains('mp3')) return '.mp3';
    if (m.contains('csv')) return '.csv';
    if (m.contains('plain')) return '.txt';
    return '';
  }

  File _resolveDestinationFile({
    required String? contentDisposition,
    required String? contentType,
  }) {
    // 1) Name from Content-Disposition
    String? name = _fileNameFromContentDisposition(contentDisposition);

    // 2) Fallback to the last segment in URL path
    name ??= p.basename(uri.path);

    // 3) Sanitize
    name = _safeFileName(name);

    // 4) Ensure extension if missing (from MIME)
    final hasExt = p.extension(name).isNotEmpty;
    if (!hasExt) {
      final ext = _extForMime(contentType);
      if (ext.isNotEmpty) {
        name += ext;
      }
    }

    _resolvedFileName = name;
    return File(p.join(baseDir.path, name));
  }

  Future<bool> _serverSupportsResumeAndHeadSize({
    required void Function(int? headSize, bool canResume) onHead,
  }) async {
    final client = HttpClient();
    try {
      final req = await client.headUrl(uri);
      final mergedHeaders = {
        'Accept-Encoding': 'identity',
        ...headers,
      };
      mergedHeaders.forEach(req.headers.add);
      final res = await req.close();

      final acceptRanges = res.headers.value(HttpHeaders.acceptRangesHeader);
      final canResume = (acceptRanges?.toLowerCase() == 'bytes');
      final headLen = res.headers.value(HttpHeaders.contentLengthHeader);
      final headSize = headLen != null ? int.tryParse(headLen) : null;

      onHead(headSize, canResume);
      return canResume;
    } catch (_) {
      onHead(null, false);
      return false;
    } finally {
      client.close(force: true);
    }
  }

  void _resetFlags() {
    _paused = false;
    _canceled = false;
    _userCanceled = false;
  }

  // --- Public API ---

  Stream<DownloadProgress> start(
      {void Function(DownloadResult result)? onDone}) async* {
    _resetFlags();

    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }

    final client = HttpClient();
    int received = 0;
    int? total; // from GET (or from HEAD fallback)
    int? headSize; // HEAD fallback size
    bool canResume = false;

    try {
      ToastComponent.showDialog('download_started'.tr(),
          color: const Color(0xFF4CAF50), gravity: ToastGravity.BOTTOM);

      // Preflight (HEAD): determine resume support + fallback size
      await _serverSupportsResumeAndHeadSize(onHead: (h, cr) {
        headSize = h;
        canResume = cr;
      });

      // Build GET request
      _request = await client.getUrl(uri);
      final mergedHeaders = {
        'Accept-Encoding': 'identity', // help servers provide Content-Length
        ...headers,
      };
      mergedHeaders.forEach(_request!.headers.add);

      // We will resolve filename after receiving GET response headers
      int resumeFrom = 0;
      if (_destFile != null && await _destFile!.exists()) {
        resumeFrom = await _destFile!.length();
      }

      if (resumeFrom > 0 && canResume) {
        _request!.headers.set(HttpHeaders.rangeHeader, 'bytes=$resumeFrom-');
      } else if (resumeFrom > 0 && !canResume) {
        try {
          await _destFile?.delete();
        } catch (_) {}
        resumeFrom = 0;
      }

      final response = await _request!.close();

      _resolvedMime = response.headers.contentType?.mimeType ??
          response.headers.value('content-type');
      final cd = response.headers.value('content-disposition');

      // Resolve final destination path now
      _destFile ??= _resolveDestinationFile(
          contentDisposition: cd, contentType: _resolvedMime);
      if (!(await _destFile!.exists())) {
        await _destFile!.create(recursive: true);
      }

      // Determine total size: prefer GET content-length, otherwise fallback to HEAD size
      final getLen = response.headers.value(HttpHeaders.contentLengthHeader);
      if (getLen != null) {
        final parsed = int.tryParse(getLen);
        total =
            parsed != null ? parsed + (resumeFrom > 0 ? resumeFrom : 0) : null;
      } else {
        total = headSize; // may be null -> indeterminate progress UI
      }

      // Open sink (append if resuming)
      _sink = _destFile!.openWrite(
          mode:
              (resumeFrom > 0 && canResume) ? FileMode.append : FileMode.write);

      int bytesInWindow = 0;
      final sw = Stopwatch()..start();
      int lastTickMs = 0;
      received = resumeFrom;

      await for (final chunk in response) {
        if (_canceled) {
          await _sink?.flush();
          await _sink?.close();
          _request?.abort();
          client.close(force: true);
          ToastComponent.showDialog('download_canceled'.tr(),
              isError: true, gravity: ToastGravity.BOTTOM);
          onDone?.call(const DownloadResult.canceled());
          return;
        }
        while (_paused && !_canceled) {
          await Future<void>.delayed(const Duration(milliseconds: 120));
        }
        if (_canceled) break;

        _sink!.add(chunk);
        received += chunk.length;
        bytesInWindow += chunk.length;

        // Emit progress every ~800ms with speed and ETA
        double? speed;
        Duration? eta;
        final nowMs = sw.elapsedMilliseconds;
        if (nowMs - lastTickMs >= 800) {
          final secs = (nowMs - lastTickMs) / 1000.0;
          if (secs > 0) {
            speed = bytesInWindow / secs;
            if (total != null && speed > 0) {
              final remain = total - received;
              eta = Duration(seconds: (remain / speed).round());
            }
          }
          bytesInWindow = 0;
          lastTickMs = nowMs;
        }

        yield DownloadProgress(
          received: received,
          total: total,
          speedBytesPerSec: speed,
          eta: eta,
        );
      }

      await _sink?.flush();
      await _sink?.close();

      if (_canceled) {
        onDone?.call(const DownloadResult.canceled());
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 206) {
        if (Platform.isAndroid && _destFile != null) {
          try {
            final publicUri = await MediaStoreSaver.saveToPublicDownloads(
              filePath: _destFile!.path,
              fileName: _resolvedFileName ?? 'file',
              mimeType: _resolvedMime ?? 'application/octet-stream',
              subDir: AppConfig.appNameOnDeviceLang, // Downloads/<AppName>
            );
            if (publicUri != null) {
              // Delete temp source right after successful export (no leftovers in Android/data)
              try {
                await _destFile!.delete();
              } catch (_) {}
            }
          } catch (_) {
            // If export fails, keep temp file so user doesn't lose the download
          }
        }
        onDone?.call(DownloadResult.completed(_destFile,
            fileName: _resolvedFileName, mimeType: _resolvedMime));
      } else {
        ToastComponent.showDialog('download_failed'.tr(),
            isError: true, gravity: ToastGravity.BOTTOM);
        onDone?.call(DownloadResult.failed(
            HttpException('HTTP ${response.statusCode}'), StackTrace.current));
      }
    } catch (e, st) {
      // Do NOT record error when cancel was user initiated
      if (!_userCanceled) {
        recordError(e, st);
      }
      try {
        await _sink?.flush();
        await _sink?.close();
      } catch (_) {}
      if (!_userCanceled) {
        ToastComponent.showDialog('download_failed'.tr(),
            isError: true, gravity: ToastGravity.BOTTOM);
        onDone?.call(DownloadResult.failed(e, st));
      } else {
        onDone?.call(const DownloadResult.canceled());
      }
    }
  }

  void pause() {
    // Soft pause; the stream loop will idle until resume is called.
    _paused = true;
  }

  void resume() {
    _paused = false;
  }

  void cancel() {
    // Mark as user-initiated cancel; never treated as error.
    _userCanceled = true;
    _canceled = true;
    try {
      _request?.abort();
    } catch (_) {}
  }
}
