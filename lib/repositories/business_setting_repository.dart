import 'dart:convert';
import 'dart:io';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/business_setting_response.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

import '../data_model/otp_provider_model.dart';
import '../helpers/shared_value_helper.dart';

class BusinessSettingRepository {
  Future<BusinessSettingListResponse> getBusinessSettingList() async {
    const String url = ("${AppConfig.BASE_URL}/business-settings");

    // var businessSettings = [
    //   "facebook_login",
    //   "google_login",
    //   "twitter_login",
    //   "pickup_point",
    //   "wallet_system",
    //   "email_verification",
    //   "conversation_system",
    //   "shipping_type",
    //   "classified_product",
    //   "google_recaptcha",
    //   "vendor_system_activation",
    //   "guest_checkout_activation",
    //   "last_viewed_product_activation",
    //   "notification_show_type"
    // ];
    // String params = businessSettings.join(',');
    // var body = {"keys": params};
    final response = await ApiRequest.get(url: url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Device-type': Platform.isAndroid
    ? 'android'
    : Platform.isIOS
        ? 'ios'
        : 'other',
      if (user_id.$ != null && is_logged_in.$) 'user_id': user_id.$.toString(),
      // 'device_info': jsonEncode(AppConfig.deviceInfo),
    });

    return businessSettingListResponseFromJson(response.body);
  }

  Future<List<OTPProviderModel>> getActivatedOTPLoginList() async {
    const String url = ("${AppConfig.BASE_URL}/activated-otp-login");
    final response = await ApiRequest.get(url: url);

    return OTPProviderModel.parseList(jsonDecode(response.body));
  }
}
