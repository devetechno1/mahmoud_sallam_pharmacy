// App temp/documents directory (no runtime permissions).
// Android: use temporary directory (no extra folders).
// iOS: Documents.

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DownloadPaths {
  static Future<Directory> appBaseForDownload() async {
    if (Platform.isAndroid) {
      // Use cache/temp so we don't create any folder in Android/data
      return getTemporaryDirectory();
    }
    // iOS: keep Documents
    return getApplicationDocumentsDirectory();
  }
}
