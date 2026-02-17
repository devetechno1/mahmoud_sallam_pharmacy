import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/common_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/order_detail_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/order_item_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/order_mini_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/purchased_ditital_product_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/main_helpers.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/middlewares/banned_user.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';

import '../data_model/reorder_response.dart';

class OrderRepository {
  Future<OrderMiniResponse> getOrderList(
      {page = 1, payment_status = "", delivery_status = ""}) async {
    final String url = ("${AppConfig.BASE_URL}/purchase-history" +
        "?page=$page&payment_status=$payment_status&delivery_status=$delivery_status");

    final Map<String, String> header = commonHeader;

    header.addAll(authHeader);
    header.addAll(currencyHeader);

    final response = await ApiRequest.get(
        url: url, headers: header, middleware: BannedUser());

    return orderMiniResponseFromJson(response.body);
  }

  Future<OrderDetailResponse?> getOrderDetails({int? id = 0}) async {
    final String url =
        ("${AppConfig.BASE_URL}/purchase-history-details/" + id.toString());

    final Map<String, String> header = commonHeader;

    header.addAll(authHeader);
    header.addAll(currencyHeader);

    final response = await ApiRequest.get(
        url: url, headers: header, middleware: BannedUser());
    return orderDetailResponseFromJson(response.body);
  }

  Future<ReOrderResponse> reOrder({int? id = 0}) async {
    final String url = ("${AppConfig.BASE_URL}/re-order/$id");

    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return reOrderResponseFromJson(response.body);
  }

  Future<CommonResponse> cancelOrder({int? id = 0}) async {
    final String url = "${AppConfig.BASE_URL}/order/cancel/$id";

    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return commonResponseFromJson(response.body);
  }

  Future<OrderItemResponse> getOrderItems({int? id = 0}) async {
    final String url =
        ("${AppConfig.BASE_URL}/purchase-history-items/" + id.toString());
    final Map<String, String> header = commonHeader;

    header.addAll(authHeader);
    header.addAll(currencyHeader);

    final response = await ApiRequest.get(
        url: url, headers: header, middleware: BannedUser());

    return orderItemlResponseFromJson(response.body);
  }

  Future<dynamic> getPurchasedDigitalProducts({
    page = 1,
  }) async {
    final String url =
        ("${AppConfig.BASE_URL}/digital/purchased-list?page=$page");
    final Map<String, String> header = commonHeader;

    header.addAll(authHeader);
    header.addAll(currencyHeader);

    final response = await ApiRequest.get(
        url: url, headers: header, middleware: BannedUser());

    return purchasedDigitalProductResponseFromJson(response.body);
  }
}
