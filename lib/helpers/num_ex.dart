import 'package:intl/intl.dart';

extension NumEx on num? {
  String? padLeft(int width, [String padding = '0']) {
    return this?.toString().padLeft(width, padding);
  }

  String? get fromSeconds {
    if (this == null) return null;
    final String seconds = (this! % 60).round().padLeft(2)!;
    final String minutes = (this! / 60).floor().padLeft(2)!;
    return '$minutes:$seconds';
  }

  String get locale => custom('#.###############', Intl.defaultLocale);

  String custom([String? newPattern, String? locale]) {
    return NumberFormat(newPattern, locale).format(this);
  }

  String customLocale(String locale) => custom(null, locale);
  String localeCustomPattern(String pattern) => custom(pattern);

  String get withSeparator => localeCustomPattern('#,##0.##');

  num? get onlyPositive {
    if (this == null) return null;
    return this! < 0 ? 0 : this!;
  }
}
