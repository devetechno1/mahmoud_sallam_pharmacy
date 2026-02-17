import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/profile_image_update_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/user_info_response.dart';
import 'dart:convert';
import 'package:active_ecommerce_cms_demo_app/data_model/profile_counters_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/profile_update_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/device_token_update_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/phone_email_availability_response.dart';

import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

class ProfileRepository {
  Future<dynamic> getProfileCountersResponse() async {
    const String url = ("${AppConfig.BASE_URL}/profile/counters");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );

    return profileCountersResponseFromJson(response.body);
  }

  Future<dynamic> getProfileUpdateResponse({required String post_body}) async {
    const String url = ("${AppConfig.BASE_URL}/profile/update");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: post_body);

    return profileUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getDeviceTokenUpdateResponse(String deviceToken) async {
    final postBody = jsonEncode({"device_token": "$deviceToken"});

    const String url = ("${AppConfig.BASE_URL}/profile/update-device-token");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return deviceTokenUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getProfileImageUpdateResponse(
      String image, String filename) async {
    final postBody = jsonEncode({"image": "$image", "filename": "$filename"});

    const String url = ("${AppConfig.BASE_URL}/profile/update-image");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return profileImageUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getPhoneEmailAvailabilityResponse() async {
    //var post_body = jsonEncode({"user_id":"${user_id.$}"});

    const String url = ("${AppConfig.BASE_URL}/profile/check-phone-and-email");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: '');

    return phoneEmailAvailabilityResponseFromJson(response.body);
  }

  Future<UserInfoResponse> getUserInfoResponse() async {
    const String url = ("${AppConfig.BASE_URL}/customer/info");

    final response = await ApiRequest.get(url: url, headers: {
      "Authorization": "Bearer ${access_token.$}",
      "App-Language": app_language.$!,
    });

    return userInfoResponseFromJson(response.body);
  }
}
