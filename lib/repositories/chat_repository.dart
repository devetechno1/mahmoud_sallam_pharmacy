import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/conversation_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/message_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/middlewares/banned_user.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

import '../data_model/conversation_create_response.dart';

class ChatRepository {
  Future<dynamic> getConversationResponse({page = 1}) async {
    final String url = ("${AppConfig.BASE_URL}/chat/conversations?page=$page");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return conversationResponseFromJson(response.body);
  }

  Future<dynamic> getMessageResponse(
      {required conversation_id, page = 1}) async {
    final String url =
        ("${AppConfig.BASE_URL}/chat/messages/$conversation_id?page=$page");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        middleware: BannedUser());
    return messageResponseFromJson(response.body);
  }

  Future<dynamic> getInserMessageResponse(
      {required conversation_id, required String message}) async {
    final postBody = jsonEncode({
      "user_id": "${user_id.$}",
      "conversation_id": "$conversation_id",
      "message": "$message"
    });

    const String url = ("${AppConfig.BASE_URL}/chat/insert-message");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: postBody,
        middleware: BannedUser());
    return messageResponseFromJson(response.body);
  }

  Future<dynamic> getNewMessageResponse(
      {required conversation_id, required last_message_id}) async {
    final String url =
        ("${AppConfig.BASE_URL}/chat/get-new-messages/$conversation_id/$last_message_id");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        middleware: BannedUser());
    return messageResponseFromJson(response.body);
  }

  Future<dynamic> getCreateConversationResponse(
      {required product_id,
      required String title,
      required String message}) async {
    final postBody = jsonEncode({
      "user_id": "${user_id.$}",
      "product_id": "$product_id",
      "title": "$title",
      "message": "$message"
    });
    const String url = ("${AppConfig.BASE_URL}/chat/create-conversation");

    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!
      },
      body: postBody,
      middleware: BannedUser(),
    );
    return conversationCreateResponseFromJson(response.body);
  }
}
