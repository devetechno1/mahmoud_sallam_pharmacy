import 'package:active_ecommerce_cms_demo_app/data_model/currency_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/login_response.dart';
import 'package:flutter/material.dart';

class SystemConfig {
  static CurrencyInfo? defaultCurrency;
  static BuildContext? context;
  static CurrencyInfo? systemCurrency;
  static User? systemUser;
  static bool isShownSplashScreen = false;
}
