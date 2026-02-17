import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../app_config.dart';
import '../data_model/common_response.dart';
import '../data_model/uploaded_file_list_response.dart';
import '../helpers/shared_value_helper.dart';
import 'api-request.dart';

class FileUploadRepository {
  Future<CommonResponse> fileUpload(File file) async {
    final Uri url = Uri.parse("${AppConfig.BASE_URL}/file/upload");

    final Map<String, String> header = {
      "App-Language": app_language.$!,
      "Authorization": "Bearer ${access_token.$}",
      "Content-Type":
          "multipart/form-data; boundary=<calculated when request is sent>",
      "Accept": "*/*",
      "System-Key": AppConfig.system_key
    };

    final httpReq = http.MultipartRequest("POST", url);
    httpReq.headers.addAll(header);

    final image = await http.MultipartFile.fromPath("aiz_file", file.path);

    httpReq.files.add(image);

    final response = await httpReq.send();
    var commonResponse =
        CommonResponse(result: false, message: "File upload failed");

    final responseDecode = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      try {
        commonResponse = commonResponseFromJson(responseDecode);
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    }
    return commonResponse;
  }

  Future<UploadedFilesListResponse> getFiles(page, search, type, sort) async {
    final String url =
        ("${AppConfig.BASE_URL}/file/all?page=$page&search=$search&type=$type&sort=$sort");
    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$!,
      "System-Key": AppConfig.system_key
    });

    return uploadedFilesListResponseFromJson(response.body);
  }

  Future<CommonResponse> deleteFile(id) async {
    final String url = ("${AppConfig.BASE_URL}/file/delete/$id");
    final response = await ApiRequest.get(url: url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$!,
      "System-Key": AppConfig.system_key
    });

    return commonResponseFromJson(response.body);
  }

  /// Upload multiple files in ONE multipart request using `http` only,
  /// with accurate byte-level progress via HttpClient.addStream.
  /// - `onProgress`: value 0..1 (double)
  Future<CommonResponse> multiFileUploadHttpWithProgress(
    String endPoint, {
    void Function(double progress)? onProgress,
    required List<XFile> files,
    String fieldName = "images[]",
  }) async {
    final Uri url = Uri.parse("${AppConfig.BASE_URL}/$endPoint");

    final req = http.MultipartRequest("POST", url);

    req.headers.addAll({
      "Authorization": "Bearer ${access_token.$}",
      "Accept": "application/json",
      "System-Key": AppConfig.system_key
    });

    req.fields.addAll(
      is_logged_in.$
          ? {"user_id": user_id.$.toString()}
          : {"temp_user_id": temp_user_id.$.toString()},
    );

    for (final f in files) {
      req.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          f.path,
          filename: path.basename(f.path),
        ),
      );
    }

    final Stream<List<int>> bodyStream = req.finalize();
    final int total = req.contentLength;
    int sent = 0;
    final countingStream = bodyStream.transform<List<int>>(
      StreamTransformer.fromHandlers(
        handleData: (chunk, sink) {
          sent += chunk.length;
          if (total > 0 && onProgress != null) {
            onProgress(sent / total);
          }
          sink.add(chunk);
        },
      ),
    );

    final httpClient = HttpClient();
    final ioReq = await httpClient.postUrl(url);

    // copy headers including multipart boundary content type if present
    req.headers.forEach((k, v) => ioReq.headers.set(k, v));
    final ct = req.headers[HttpHeaders.contentTypeHeader];
    if (ct != null) {
      ioReq.headers.set(HttpHeaders.contentTypeHeader, ct);
    }

    if (total >= 0) {
      ioReq.contentLength = total;
    }

    await ioReq.addStream(countingStream);

    final ioRes = await ioReq.close();
    final respBody = await utf8.decodeStream(ioRes);

    if (ioRes.statusCode < 200 || ioRes.statusCode >= 300) {
      throw respBody;
    }

    final Map<String, dynamic> jsonMap =
        jsonDecode(respBody) as Map<String, dynamic>;
    return CommonResponse.fromJson(jsonMap);
  }
}
