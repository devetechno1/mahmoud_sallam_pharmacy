import 'dart:convert';
import 'dart:isolate';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/language_list_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';

class LanguageRepository {
  Future<LanguageListResponse> getLanguageList() async {
    const String url = ("${AppConfig.BASE_URL}/languages");
    await app_language.load();
    final response = await ApiRequest.get(url: url, headers: {
      "App-Language": app_language.$ ?? AppConfig.default_language,
    });

    return languageListResponseFromJson(response.body);
  }

  Future<Map<String, dynamic>> getTranslations({
    required String lang,
    required String date,
  }) async {
    final response = await ApiRequest.get(
      url: "${AppConfig.BASE_URL}/app-translations/$lang?date=$date",
    );

    return Isolate.run(() => jsonDecode(response.body));
  }
}
