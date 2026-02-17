import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_add_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_count_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_delete_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_process_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/cart_summary_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/middlewares/banned_user.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

class CartRepository {
  // get cart list
  Future<dynamic> getCartResponseList() async {
    const String url = ("${AppConfig.BASE_URL}/carts");
    String postBody;

    if (AppConfig.businessSettingsData.guestCheckoutStatus && !is_logged_in.$) {
      postBody = jsonEncode({"temp_user_id": temp_user_id.$});
    } else {
      postBody = jsonEncode({"user_id": user_id.$});
    }

    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "App-Language": app_language.$!,
        },
        body: postBody,
        middleware: BannedUser());

    return cartResponseFromJson(response.body);
  }

  Future<void> removePrescription(String imageId) async {
    const String url = "${AppConfig.BASE_URL}/carts/prescription/remove-image";
    Map<String, String> postBody;

    if (AppConfig.businessSettingsData.guestCheckoutStatus && !is_logged_in.$) {
      postBody = {"temp_user_id": temp_user_id.$};
    } else {
      postBody = {"user_id": "${user_id.$}"};
    }

    postBody['image_id'] = imageId;

    await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
      },
      body: jsonEncode(postBody),
      middleware: BannedUser(),
    );
  }

  // cart count
  Future<dynamic> getCartCount() async {
    String postBody;
    if (AppConfig.businessSettingsData.guestCheckoutStatus && !is_logged_in.$) {
      postBody = jsonEncode({"temp_user_id": temp_user_id.$});
    } else {
      postBody = jsonEncode({"user_id": user_id.$});
    }

    // if (AppConfig.businessSettingsData.guestCheckoutStatus && !is_logged_in.$) {
    // var postBody = jsonEncode({"temp_user_id": temp_user_id.$});
    const String url = ("${AppConfig.BASE_URL}/cart-count");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "App-Language": app_language.$ ?? AppConfig.default_language,
      },
      body: postBody,
    );

    return cartCountResponseFromJson(response.body);
  }

  // cart item delete
  Future<dynamic> getCartDeleteResponse(int cartId) async {
    final String url = "${AppConfig.BASE_URL}/carts/$cartId";

    final response = await ApiRequest.delete(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
      middleware: BannedUser(),
    );

    if (response.statusCode == 200) {
      return cartDeleteResponseFromJson(response.body);
    } else {
      throw Exception("Failed to delete item: ${response.body}");
    }
  }

  // cart process
  Future<dynamic> getCartProcessResponse(
      String cartIds, String cartQuantities) async {
    final postBody = jsonEncode(
        {"cart_ids": "$cartIds", "cart_quantities": "$cartQuantities"});

    const String url = ("${AppConfig.BASE_URL}/carts/process");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: postBody,
        middleware: BannedUser());
    return cartProcessResponseFromJson(response.body);
  }

  // cart add
  Future<dynamic> getCartAddResponse(
      int? id, String? variant, int? quantity) async {
    String postBody;

    if (AppConfig.businessSettingsData.guestCheckoutStatus && !is_logged_in.$) {
      postBody = jsonEncode({
        "id": "$id",
        "variant": variant,
        "quantity": "$quantity",
        "cost_matrix": AppConfig.purchase_code,
        "temp_user_id": temp_user_id.$
      });
    } else {
      postBody = jsonEncode({
        "id": "$id",
        "variant": variant,
        "user_id": "${user_id.$}",
        "quantity": "$quantity",
        "cost_matrix": AppConfig.purchase_code,
      });
    }

    const String url = ("${AppConfig.BASE_URL}/carts/add");
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
    print("digital cart add response: ${response.body}");
    return cartAddResponseFromJson(response.body);
  }

  Future<dynamic> getCartSummaryResponse() async {
    String postBody;

    if (AppConfig.businessSettingsData.guestCheckoutStatus && !is_logged_in.$) {
      postBody = jsonEncode({"temp_user_id": temp_user_id.$});
    } else {
      postBody = jsonEncode({"user_id": user_id.$});
    }

    const String url = ("${AppConfig.BASE_URL}/cart-summary");
    final response = await ApiRequest.post(
        url: url,
        body: postBody,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());

    return cartSummaryResponseFromJson(response.body);
  }
}
