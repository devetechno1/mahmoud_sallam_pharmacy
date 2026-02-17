import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/common_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/confirm_code_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/login_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/logout_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/password_confirm_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/password_forget_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/resend_code_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

class AuthRepository {
  Future<LoginResponse> getLoginResponse(
      String? email, String password, String loginBy) async {
    final postBody = jsonEncode({
      "email": "$email",
      "password": "$password",
      if (AppConfig.deviceInfo.isNotEmpty) "device_info": AppConfig.deviceInfo,
      "identity_matrix": AppConfig.purchase_code,
      "login_by": loginBy,
      "temp_user_id": temp_user_id.$
    });

    const String url = ("${AppConfig.BASE_URL}/auth/login");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return loginResponseFromJson(response.body);
  }

  Future<LoginResponse> getOTPLoginResponse({
    required String countryCode,
    required String phone,
    required String provider,
  }) async {
    final postBody = jsonEncode({
      "otp_provider": "$provider",
      "phone": "$phone",
      "country_code": "$countryCode",
      "identity_matrix": AppConfig.purchase_code,
      "temp_user_id": temp_user_id.$
    });

    const String url = ("${AppConfig.BASE_URL}/auth/send-otp");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
      },
      body: postBody,
    );

    return loginResponseFromJson(response.body);
  }

  Future<LoginResponse> verifyOTPLoginResponse({
    required String countryCode,
    required String phone,
    required String otpCode,
  }) async {
    final postBody = jsonEncode({
      "phone": "$phone",
      "country_code": "$countryCode",
      "otp_code": "$otpCode",
      "identity_matrix": AppConfig.purchase_code,
      "temp_user_id": temp_user_id.$,
      if (AppConfig.deviceInfo.isNotEmpty) "device_info": AppConfig.deviceInfo,
    });

    const String url = ("${AppConfig.BASE_URL}/auth/verify-otp");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
      },
      body: postBody,
    );

    return loginResponseFromJson(response.body);
  }

  Future<LoginResponse> getSocialLoginResponse(
    String socialProvider,
    String? name,
    String? email,
    String? provider, {
    access_token = "",
    secret_token = "",
  }) async {
    email = email == ("null") ? "" : email;

    final postBody = jsonEncode({
      "name": name,
      "email": email,
      "otp_provider": "$provider",
      if (AppConfig.deviceInfo.isNotEmpty) "device_info": AppConfig.deviceInfo,
      "social_provider": "$socialProvider",
      "access_token": "$access_token",
      "secret_token": "$secret_token"
    });

    const String url = ("${AppConfig.BASE_URL}/auth/social-login");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);
    return loginResponseFromJson(response.body);
  }

  Future<LogoutResponse> getLogoutResponse() async {
    const String url = ("${AppConfig.BASE_URL}/auth/logout");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );

    return logoutResponseFromJson(response.body);
  }

  Future<CommonResponse> getAccountDeleteResponse() async {
    const String url = ("${AppConfig.BASE_URL}/auth/account-deletion");

    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );
    return commonResponseFromJson(response.body);
  }

  Future<LoginResponse> getSignupResponse(
    String name,
    String? email,
    String phone,
    String password,
    String passowrdConfirmation,
    String capchaKey,
    String? provider,
  ) async {
    final postBody = jsonEncode({
      "name": "$name",
      if (email?.trim().isNotEmpty == true) "email": "$email",
      "phone": "$phone",
      "password": "$password",
      if (AppConfig.businessSettingsData.mustOtp && provider != null)
        "otp_provider": provider,
      if (AppConfig.deviceInfo.isNotEmpty) "device_info": AppConfig.deviceInfo,
      "password_confirmation": "$passowrdConfirmation",
      "g-recaptcha-response": "$capchaKey",
    });

    const String url = ("${AppConfig.BASE_URL}/auth/signup");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
      },
      body: postBody,
    );

    return loginResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getResendCodeResponse(String? provider) async {
    final String url =
        ("${AppConfig.BASE_URL}/auth/resend_code${provider != null ? "?otp_provider=$provider" : ''}");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
        "Authorization": "Bearer ${access_token.$}",
      },
    );
    return resendCodeResponseFromJson(response.body);
  }

  Future<ConfirmCodeResponse> getConfirmCodeResponse(
      String verificationCode) async {
    final postBody = jsonEncode({"verification_code": "$verificationCode"});

    const String url = ("${AppConfig.BASE_URL}/auth/confirm_code");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
          "Authorization": "Bearer ${access_token.$}",
        },
        body: postBody);

    return confirmCodeResponseFromJson(response.body);
  }

  Future<PasswordForgetResponse> getPasswordForgetResponse(
    String? emailOrPhone,
    String sendCodeBy,
    String? otpProvider,
  ) async {
    final postBody = jsonEncode({
      "email_or_phone": "$emailOrPhone",
      "send_code_by": "$sendCodeBy",
      if (otpProvider != null) "otp_provider": otpProvider,
    });

    const String url = ("${AppConfig.BASE_URL}/auth/password/forget_request");

    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return passwordForgetResponseFromJson(response.body);
  }

  Future<PasswordConfirmResponse> getPasswordConfirmResponse(
      String verificationCode, String password) async {
    final postBody = jsonEncode(
        {"verification_code": "$verificationCode", "password": "$password"});

    const String url = ("${AppConfig.BASE_URL}/auth/password/confirm_reset");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return passwordConfirmResponseFromJson(response.body);
  }

  Future<ResendCodeResponse> getPasswordResendCodeResponse(
      String? emailOrCode, String verifyBy) async {
    final postBody =
        jsonEncode({"email_or_code": "$emailOrCode", "verify_by": "$verifyBy"});

    const String url = ("${AppConfig.BASE_URL}/auth/password/resend_code");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody);

    return resendCodeResponseFromJson(response.body);
  }

  Future<LoginResponse> getUserByTokenResponse() async {
    final postBody = jsonEncode({"access_token": "${access_token.$}"});

    const String url = ("${AppConfig.BASE_URL}/auth/info");
    if (access_token.$!.isNotEmpty) {
      final response = await ApiRequest.post(
          url: url,
          headers: {
            "Content-Type": "application/json",
            "App-Language": app_language.$!,
          },
          body: postBody);

      return loginResponseFromJson(response.body);
    }
    return LoginResponse();
  }
}
