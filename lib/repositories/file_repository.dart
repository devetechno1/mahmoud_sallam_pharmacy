import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/middlewares/banned_user.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';
import 'dart:convert';
import 'package:active_ecommerce_cms_demo_app/data_model/simple_image_upload_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';

class FileRepository {
  Future<dynamic> getSimpleImageUploadResponse(
      String image, String filename) async {
    final postBody = jsonEncode({"image": "$image", "filename": "$filename"});

    const String url = ("${AppConfig.BASE_URL}/file/image-upload");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: postBody,
        middleware: BannedUser());

    return simpleImageUploadResponseFromJson(response.body);
  }
}
