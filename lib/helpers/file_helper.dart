import 'dart:convert';
import 'dart:io';

class FileHelper {
  static String getBase64FormateFile(String path) {
    final File file = File(path);
    // print('File is = ' + file.toString());
    final List<int> fileInByte = file.readAsBytesSync();
    final String fileInBase64 = base64Encode(fileInByte);
    return fileInBase64;
  }
}
