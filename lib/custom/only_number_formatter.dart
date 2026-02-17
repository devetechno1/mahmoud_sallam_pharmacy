import 'package:active_ecommerce_cms_demo_app/helpers/main_helpers.dart';
import 'package:flutter/services.dart';

class OnlyNumberFormatter extends TextInputFormatter {
  String minValue;

  OnlyNumberFormatter({this.minValue = "1"});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String value = newValue.text;
    if (value.isEmpty) {
      newValue = TextEditingValue(
          text: minValue,
          selection: TextSelection.fromPosition(const TextPosition(offset: 1)));
      return newValue;
    }
    if (isNumber(value) && !(int.parse(value).isNegative)) {
      return newValue;
    }
    return oldValue;
  }
}
