import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

bool isNumber(String text) {
  return RegExp('^[0-9]+\$').hasMatch(text);
}

String capitalize(String text) {
  return toBeginningOfSentenceCase(text) ?? text;
}

Map<String, String> get commonHeader => {
      "Content-Type": "application/json",
      "App-Language": app_language.$ ?? AppConfig.default_language,
      "Accept": "application/json",
      "System-Key": AppConfig.system_key,
      if (access_token.$?.trim().isNotEmpty == true)
        "Authorization": "Bearer ${access_token.$}",
    };
Map<String, String> get authHeader =>
    {"Authorization": "Bearer ${access_token.$}"};
Map<String, String> get currencyHeader =>
    SystemConfig.systemCurrency?.code != null
        ? {
            "Currency-Code": SystemConfig.systemCurrency!.code!,
            "Currency-Exchange-Rate":
                SystemConfig.systemCurrency!.exchangeRate.toString(),
          }
        : {};

String convertPrice(String amount) {
  return amount.replaceAll(
      SystemConfig.systemCurrency!.code!, SystemConfig.systemCurrency!.symbol!);
}

String getParameter(GoRouterState state, String key) =>
    state.pathParameters[key] ?? "";

bool get userIsLogedIn => SystemConfig.systemUser?.id != null;
