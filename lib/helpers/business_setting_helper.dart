import 'dart:isolate';

import 'package:active_ecommerce_cms_demo_app/data_model/business_setting_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/business_setting_repository.dart';
import 'package:active_ecommerce_cms_demo_app/status/execute_and_handle_remote_errors.dart';
import 'package:active_ecommerce_cms_demo_app/status/status.dart';
import 'package:flutter/material.dart';

import '../app_config.dart';
import '../data_model/business_settings/business_settings.dart';
import '../data_model/language_list_response.dart';
import '../data_model/otp_provider_model.dart';
import '../locale/custom_localization.dart';
import '../repositories/language_repository.dart';

class BusinessSettingHelper {
  Future<void> setBusinessSettingData() async {
    final Status<BusinessSettingListResponse> status =
        await executeAndHandleErrors(
      () => BusinessSettingRepository().getBusinessSettingList(),
    );
    if (status is Failure<BusinessSettingListResponse>) return;

    status as Success<BusinessSettingListResponse>;

    final BusinessSettingListResponse businessLists = status.data;
    final Map<String, dynamic> map = {};

    businessLists.data
        ?.forEach((element) => map[element.type!] = element.value);

    AppConfig.businessSettingsData = BusinessSettingsData.fromMap(map);
  }

  static Future<void> setInitLang() async {
    final Status<LanguageListResponse> status = await executeAndHandleErrors(
      () => LanguageRepository().getLanguageList(),
    );
    if (status is Failure<LanguageListResponse>) return;

    status as Success<LanguageListResponse>;

    final LanguageListResponse langs = status.data;

    if (langs.success != true) return;

    CustomLocalization.supportedLocales.clear();
    for (Language l in langs.languages ?? []) {
      CustomLocalization.supportedLocales.add(
        Locale(l.mobile_app_code ?? AppConfig.mobile_app_code),
      );
    }

    if (langs.languages?.length == 1) {
      await _setLangConfig(langs.languages!.first);
      return;
    }
    bool resetLang = true;
    await Future.wait([
      app_language.load(),
      access_token.load(),
    ]);
    Language? defaultLang;

    for (Language lang in langs.languages ?? []) {
      if (lang.code == app_language.$) {
        if (app_language.$ != null) {
          resetLang = false;
          break;
        }
      }
      if (lang.is_default ?? false) defaultLang = lang;
    }
    if (defaultLang != null && resetLang) {
      await _setLangConfig(defaultLang);
    }
  }

  static Future<void> _setLangConfig(Language lang) async {
    AppConfig.default_language = lang.code ?? AppConfig.default_language;
    AppConfig.mobile_app_code =
        lang.mobile_app_code ?? AppConfig.mobile_app_code;
    AppConfig.app_language_rtl = lang.rtl ?? AppConfig.app_language_rtl;
    app_language.$ = lang.code;
    app_mobile_language.$ = lang.mobile_app_code;
    app_language_rtl.$ = lang.rtl;
    await Future.wait([
      app_language.save(),
      app_mobile_language.save(),
      app_language_rtl.save(),
    ]);
  }

  static Future<void> getOTPLoginProviders() async {
    final Status<List<OTPProviderModel>> status = await executeAndHandleErrors(
      () => BusinessSettingRepository().getActivatedOTPLoginList(),
    );
    if (status is Success<List<OTPProviderModel>>) {
      AppConfig.businessSettingsData.setOTPProviders(status.data);
    }
  }

  static Future<void> handleTranslations() async {
    await Future.wait([
      lastUpdateTranslation.load(),
      app_mobile_language.load(),
    ]);

    final String langCode = app_mobile_language.$ ?? AppConfig.mobile_app_code;

    final Status<Map<String, dynamic>> status = await executeAndHandleErrors(
      () => LanguageRepository().getTranslations(
        lang: langCode,
        date: lastUpdateTranslation.$,
      ),
    );
    if (status is Success<Map<String, dynamic>> &&
        status.data['success'] == true) {
      final String lastDate = status.data['data']['date'] ?? '';
      if (status.data['data']['lang'].isNotEmpty) {
        final Map<String, dynamic> newTranslations =
            status.data['data']['lang'];

        await _saveTranslations(
          langCode: langCode,
          lastUpdate: lastDate,
          newTranslations: newTranslations,
        );
      }
    }

    final Map localeTranslations = (localeTranslation.get(langCode) ?? {});

    if (localeTranslations.isNotEmpty) {
      final Map<String, String> allLangs = {
        ...(CustomLocalization.localizedValues[langCode] ?? {})
      };

      allLangs.addAll(
        await Isolate.run(
          () {
            final Map<String, String> _allLangs = allLangs;
            localeTranslations.entries.forEach(
              (e) => _allLangs['${e.key}'] = '${e.value ?? e.key}',
            );
            return _allLangs;
          },
        ),
      );
      CustomLocalization.localizedValues[langCode] = allLangs;
    }
  }

  static Future<void> _saveTranslations({
    required String langCode,
    required String lastUpdate,
    required Map newTranslations,
  }) async {
    final Map translations = localeTranslation.get(langCode) ?? {};
    translations.addAll(newTranslations);

    await localeTranslation.put(langCode, translations);
    lastUpdateTranslation.$ = lastUpdate;
    await lastUpdateTranslation.save();
  }
}
