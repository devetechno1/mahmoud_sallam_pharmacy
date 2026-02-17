import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';

import '../app_config.dart';
import '../helpers/business_setting_helper.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  Locale get locale {
    return _locale ??
        Locale(
            app_mobile_language.$ == ''
                ? AppConfig.mobile_app_code
                : app_mobile_language.$!,
            '');
  }

  Future<void> setLocale(String code) async{
    BusinessSettingHelper.handleTranslations();
    _locale = Locale(code, '');
    notifyListeners();
  }
}
