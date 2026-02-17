import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/flash_deal_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/slider_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';
import 'package:flutter/cupertino.dart';

import '../data_model/popup_banner_model.dart';
import '../data_model/today_deal_response.dart';

class SlidersRepository {
  Future<SliderResponse> getSliders() async {
    const String url = ("${AppConfig.BASE_URL}/sliders");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );
    return sliderResponseFromJson(response.body);
  }

  Future<SliderResponse> getBannerOneImages() async {
    const String url = ("${AppConfig.BASE_URL}/banners-one");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );
    return sliderResponseFromJson(response.body);
  }

  Future<SliderResponse> getFlashDealBanner() async {
    const String url = ("${AppConfig.BASE_URL}/flash-deals-banners");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );
    return sliderResponseFromJson(response.body);
  }
      Future<TodaysDealBannerResponse> getTodaysDealBanner() async {
    const String url = ("${AppConfig.BASE_URL}/todays-deal-banners");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );
    debugPrint('TODAYS DEAL RESPONSE => ${response.body}');

    return todaysDealBannerResponseFromJson(response.body);
  }

  Future<SliderResponse> getBannerTwoImages() async {
    const String url = ("${AppConfig.BASE_URL}/banners-two");

    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );

    return sliderResponseFromJson(response.body);
  }

  Future<SliderResponse> getBannerThreeImages() async {
    const String url = ("${AppConfig.BASE_URL}/banners-three");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );

    return sliderResponseFromJson(response.body);
  }
    Future<SliderResponse> getBannerFourImages() async {
    const String url = ("${AppConfig.BASE_URL}/banners-four");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );
    print('BANNER FOUR RESPONSE => ${response.body}');
    return sliderResponseFromJson(response.body);
  }
      Future<SliderResponse> getBannerFiveImages() async {
    const String url = ("${AppConfig.BASE_URL}/banners-five");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );
    print('BANNER five RESPONSE => ${response.body}');
    return sliderResponseFromJson(response.body);
  }

  Future<List<FlashDealResponseDatum>> fetchBanners() async {
    const String url = ("${AppConfig.BASE_URL}/flash-deals");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "App-Language": app_language.$!,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['data'] != null) {
        return (jsonData['data'] as List)
            .map((banner) => FlashDealResponseDatum.fromJson(banner))
            .toList();
      } else {
        throw Exception('Failed to load banners: Data is null');
      }
    } else {
      throw Exception('Failed to load banners: Status code not 200');
    }
  }

  Future<List<PopupBannerModel>> fetchBannerPopupData() async {
    const String url = '${AppConfig.BASE_URL}/banners-popup';

    try {
      final response = await ApiRequest.get(url: url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return (data['data'] as List<dynamic>?)
                ?.map(
                    (e) => PopupBannerModel.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [];
      } else {
        throw Exception(
            'Failed to load popup banner, status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
