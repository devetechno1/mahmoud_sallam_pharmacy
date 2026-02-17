import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import 'data_model/business_settings/business_settings.dart';
import 'data_model/business_settings/update_model.dart';
import 'screens/splash_screen/splash_screen_config.dart';
export 'constants/app_dimensions.dart';
export 'constants/app_images.dart';

// final String this_year = DateTime.now().year.toString();

class AppConfig {
  /// To know the device operating system (ios, huawei or any android device)
  /// Determines whether the login page should directly show full login fields
  /// (phone/email + password + others) or just display a single "Login" button
  /// that navigates to the detailed login form when pressed.
  /// [showFullLoginFields] = false that means the default behavior will be used
  /// [showFullLoginFields] = true that means the full login form will be shown
  static const bool showFullLoginFields = false;

  /// To know the device operating system (ios, huawei or any android device)
  static StoreType storeType = StoreType.unknown;

  ///Specifies the splash screen type to use a custom animated widget instead of a static image or traditional screen.
  static SplashScreenType get splashType =>
      SplashScreenType.splashAnimatedImageWidget;

  /// To make force update to app
  static String version = '1.0.0';

  /// App Version (AV) shown on the splash screen.
  /// Used to verify the app build matches the master version.
  static const String mobileVersion = '9.11.x';

  /// Backend Version (BV) used for compatibility checks.
  /// Used to verify the app is compatible with backend data.
  static const String backendVersion = '9.8.1';

  //configure this
  // static String copyright_text =
  //     "@ Deve Finance " + this_year; //this shows in the splash screen

  /// This get the name of the application in deviceLocale
  static String appNameOnDeviceLang = "app_name".trGivenLocale(
    PlatformDispatcher.instance.locale,
  );

  static bool isDebugMode = false;
  static bool turnDevicePreviewOn = isDebugMode;

  static String search_bar_text(BuildContext context) {
    return 'search_in_app_name'.tr(
      context: context,    
      args: {'app_name': 'app_name'.tr(context: context)},
    );
  }

  static String purchase_code =
      "a"; //enter your purchase code for the app from codecanyon
  static String system_key =
      r"a"; //enter your purchase code for the app from codecanyon

  //Default language config
  static String default_language =
      CustomLocalization.supportedLocales.first.languageCode;
  static String mobile_app_code =
      CustomLocalization.supportedLocales.first.languageCode;
  static bool app_language_rtl = mobile_app_code == "ar";

  //Default country config
  static String default_country = "EG";

  //configure this
  static const bool HTTPS =
      true; //if you are using localhost , set this to false

  /// use only domain name without http:// or https://
  /// if you make update to old type app from multi/cms to this. to save login put the [oldTokenKey]
  static const DOMAIN_PATH = "mahmoudsallamcare.com";

  //do not configure these below
  static const String API_ENDPATH = "api/v2";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  // static const String RAW_BASE_URL = "http://192.168.100.200:8080/devef";
  static const String RAW_BASE_URL = "$PROTOCOL$DOMAIN_PATH";
  static const String BASE_URL = "$RAW_BASE_URL/$API_ENDPATH";

  // static HomePageType selectedHomePageType = HomePageType.home;
  static BusinessSettingsData businessSettingsData = BusinessSettingsData();

  static Map<String, dynamic> deviceInfo = {};

  /// This is the token we need to get so change key if you want access token from shared preferences.
  /// mostly in cms "user_login_token" in multi "6ammart_token" or "devetechno_token"
  static const String oldTokenKey = "";
}

const SizedBox emptyWidget = SizedBox();
