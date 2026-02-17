import 'dart:io';
import 'package:flutter/services.dart';

class MediaStoreSaver {
  static const MethodChannel _ch = MethodChannel('media_store_saver');

  static Future<String?> saveToPublicDownloads({
    required String filePath,
    required String fileName,
    required String mimeType,
    String? subDir,
  }) async {
    if (!Platform.isAndroid) return null;
    return _ch.invokeMethod<String>('saveToPublicDownloads', {
      'filePath': filePath,
      'fileName': fileName,
      'mimeType': mimeType,
      'subDir': subDir ?? '',
    });
  }
}
