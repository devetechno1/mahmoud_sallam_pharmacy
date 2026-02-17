// lib/core/download/download_provider.dart
// Provider-based state management for a single DownloadTask.

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../helpers/download/download_service.dart';

class DownloadProvider extends ChangeNotifier {
  final DownloadTask task;
  StreamSubscription<DownloadProgress>? _sub;

  DownloadStatus status = DownloadStatus.idle;
  int received = 0;
  int? total;
  double? speedBytesPerSec;
  Duration? eta;
  File? file;
  String? fileName;
  String? mimeType;
  Object? error;

  DownloadProvider(this.task);

  double? get percent => (total == null || total == 0) ? null : received / total!;

  Future<void> start() async {
    status = DownloadStatus.running;
    error = null;
    notifyListeners();

    await _sub?.cancel();
    _sub = task.start(onDone: (result) {
      status = result.status;
      if (result.status == DownloadStatus.completed) {
        file = result.file;
        fileName = result.fileName;
        mimeType = result.mimeType;
      } else if (result.status == DownloadStatus.failed) {
        error = result.error;
      }
      notifyListeners();
    }).listen((p) {
      received = p.received;
      total = p.total;
      speedBytesPerSec = p.speedBytesPerSec;
      eta = p.eta;
      notifyListeners();
    });
  }

  void pause() {
    task.pause();
    status = DownloadStatus.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    task.resume();
    status = DownloadStatus.running;
    notifyListeners();
  }

  Future<void> cancel() async {
    task.cancel();
    await _sub?.cancel();
    status = DownloadStatus.canceled;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
