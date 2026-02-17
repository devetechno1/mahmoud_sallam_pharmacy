import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/screens/classified_ads/classified_model.dart';

import '../app_config.dart';
import '../data_model/classified_ads_details_response.dart';
import '../data_model/classified_ads_response.dart';
import '../data_model/common_response.dart';
import '../helpers/shared_value_helper.dart';
import 'api-request.dart';

class ClassifiedProductRepository {
  Future<ClassifiedAdsResponse> getClassifiedProducts({
    page = 1,
  }) async {
    final String url = ("${AppConfig.BASE_URL}/classified/all?page=$page");

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });

    return classifiedAdsResponseFromJson(response.body);
  }

  Future<MyclassifiedProductModel> getMyClassifiedProducts(int page) async {
    final url = '${AppConfig.BASE_URL}/classified/own-products?page=$page';
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
      "System-Key": AppConfig.system_key,
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return MyclassifiedProductModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<ClassifiedAdsResponse> getOwnClassifiedProducts({
    page = 1,
  }) async {
    final String url =
        ("${AppConfig.BASE_URL}/classified/own-products?page=$page");
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
    });

    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedAdsResponse> getClassifiedOtherAds({
    required slug,
  }) async {
    final String url =
        ("${AppConfig.BASE_URL}/classified/related-products/$slug");

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });

    return classifiedAdsResponseFromJson(response.body);
  }

  Future<ClassifiedProductDetailsResponse> getClassifiedProductsDetails(
      slug) async {
    final String url =
        ("${AppConfig.BASE_URL}/classified/product-details/$slug");

    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$!,
    });

    return classifiedProductDetailsResponseFromJson(response.body);
  }

  Future<CommonResponse> getDeleteClassifiedProductResponse(id) async {
    final String url = ("${AppConfig.BASE_URL}/classified/delete/$id");

    final response = await ApiRequest.delete(url: url, headers: {
      "App-Language": app_language.$!,
      "Content-Type": "application/json",
      "Authorization": "Bearer ${access_token.$}",
    });

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> getStatusChangeClassifiedProductResponse(
      id, status) async {
    final String url = ("${AppConfig.BASE_URL}/classified/change-status/$id");

    final postBody = jsonEncode({"status": status});
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: postBody,
    );

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> addProductResponse(postBody) async {
    const String url = ("${AppConfig.BASE_URL}/classified/store");

    final response = await ApiRequest.post(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: postBody,
    );

    return commonResponseFromJson(response.body);
  }

  Future<CommonResponse> updateCustomerProductResponse(
      postBody, id, lang) async {
    final String url =
        ("${AppConfig.BASE_URL}/classified/update/$id?lang=$lang");

    final response = await ApiRequest.post(
      url: url,
      headers: {
        "App-Language": app_language.$!,
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
      },
      body: postBody,
    );

    return commonResponseFromJson(response.body);
  }
}
