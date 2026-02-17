import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class StringHelper {
  bool? stringContains(String? string, String part) {
    return string?.toLowerCase().contains(part.toLowerCase());
  }
}

extension StringHelperEx on String {
  String timeText({int defaultLength = 2}) {
    return padLeft(defaultLength, '0');
  }

  String get langCode => isRTL ? "eg" : "en";

  bool get isRTL => intl.Bidi.detectRtlDirectionality(this);

  TextDirection get direction => isRTL ? TextDirection.rtl : TextDirection.ltr;

  TextAlign get textAlign => isRTL ? TextAlign.right : TextAlign.left;

  String get capitalizeFirst =>
      length > 1 ? '${this[0].toUpperCase()}${substring(1)}' : this;
}
