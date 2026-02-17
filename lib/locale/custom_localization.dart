import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';

import '../helpers/shared_value_helper.dart';
import '../providers/locale_provider.dart';
import 'app_ar.dart';
import 'app_en.dart';

class CustomLocalization {
  final Locale locale;
  const CustomLocalization(this.locale);

  static List<Locale> supportedLocales = [
    const Locale('en'),
    const Locale('ar'),
  ];

  static bool isSupported(Locale locale) {
    for (Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  static CustomLocalization? of(BuildContext context) {
    return Localizations.of<CustomLocalization>(context, CustomLocalization);
  }

  static Map<String, Map<String, String>> localizedValues = {
    'en': enLangs,
    'ar': arLangs,
  };

  String translate(String key, [Locale? locale]) {
    return localizedValues[locale?.languageCode ??
            app_mobile_language.$ ??
            this.locale.languageCode]?[key] ??
        key;
    // return localizedValues[locale.languageCode]?[key] ?? key;
  }

  static String translateWithGivenLocale(String key, Locale locale) {
    return (localizedValues[locale.languageCode] ??
            localizedValues[supportedLocales.first.languageCode] ??
            localizedValues[localizedValues.keys.first])![key] ??
        key;
  }
}

class CustomLocalizationDelegate
    extends LocalizationsDelegate<CustomLocalization> {
  const CustomLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => CustomLocalization.isSupported(locale);

  @override
  Future<CustomLocalization> load(Locale locale) async {
    return CustomLocalization(locale);
  }

  @override
  bool shouldReload(CustomLocalizationDelegate old) => false;
}

extension StringTr on String {
  String tr({BuildContext? context, Map<String, String>? args}) {
    final _context = context ?? OneContext().context!;
    String translated = CustomLocalization.of(_context)?.translate(
      this,
      Provider.of<LocaleProvider>(_context, listen: false).locale,
    ) ?? this;
    if (args != null) {
      for (String key in args.keys) {
        translated = translated.replaceAll('{$key}', args[key] ?? key);
      }
    }
    return translated;
  }

  String trGivenLocale(Locale locale, {Map<String, String>? args}) {
    String translated =
        CustomLocalization.translateWithGivenLocale(this, locale);
    if (args != null) {
      for (String key in args.keys) {
        translated = translated.replaceAll('{$key}', args[key] ?? key);
      }
    }
    return translated;
  }
}
