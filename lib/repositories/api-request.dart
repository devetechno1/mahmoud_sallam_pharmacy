import 'dart:developer';

import 'package:active_ecommerce_cms_demo_app/helpers/main_helpers.dart';
import 'package:active_ecommerce_cms_demo_app/middlewares/group_middleware.dart';
import 'package:active_ecommerce_cms_demo_app/middlewares/middleware.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/aiz_api_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiRequest {
  static Future<http.Response> get({
    required String url,
    Map<String, String>? headers,
    Middleware? middleware,
    GroupMiddleware? groupMiddleWare,
  }) async {
    final Uri uri = Uri.parse(url);
    final Map<String, String> headerMap = commonHeader;
    headerMap.addAll(currencyHeader);
    if (headers != null) {
      headerMap.addAll(headers);
    }
    if (kDebugMode) print("api request url: $url headers: $headerMap");
    final response = await http.get(uri, headers: headerMap);
    if (kDebugMode) log("api response url: $url response: ${response.body}");
    return AIZApiResponse.check(
      response,
      middleware: middleware,
      groupMiddleWare: groupMiddleWare,
    );
  }

  static Future<http.Response> post({
    required String url,
    Map<String, String>? headers,
    required String body,
    Middleware? middleware,
    GroupMiddleware? groupMiddleWare,
  }) async {
    final Uri uri = Uri.parse(url);
    final Map<String, String> headerMap = commonHeader;
    headerMap.addAll(currencyHeader);
    if (headers != null) {
      headerMap.addAll(headers);
    }
    if (kDebugMode)
      log("post api request url: $url headers: $headerMap body: $body");
    final response = await http.post(uri, headers: headerMap, body: body);
    if (kDebugMode)
      log("post api response url: $url response: ${response.body}");
    return AIZApiResponse.check(
      response,
      middleware: middleware,
      groupMiddleWare: groupMiddleWare,
    );
  }

  static Future<http.Response> delete({
    required String url,
    Map<String, String>? headers,
    Middleware? middleware,
    GroupMiddleware? groupMiddleWare,
  }) async {
    final Uri uri = Uri.parse(url);
    final Map<String, String> headerMap = commonHeader;
    headerMap.addAll(currencyHeader);
    if (headers != null) {
      headerMap.addAll(headers);
    }
    final response = await http.delete(uri, headers: headerMap);
    return AIZApiResponse.check(
      response,
      middleware: middleware,
      groupMiddleWare: groupMiddleWare,
    );
  }
}
