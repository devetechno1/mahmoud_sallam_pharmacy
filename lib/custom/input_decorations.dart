import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration buildInputDecoration_1({hint_text = ""}) {
    return InputDecoration(
        hintText: hint_text,
        filled: true,
        fillColor: MyTheme.white,
        hintStyle: const TextStyle(fontSize: 12.0, color: Color(0xffA8AFB3)),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.noColor, width: 0.2),
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.radiusHalfSmall),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.primaryColor, width: 0.5),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppDimensions.radiusHalfSmall),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14.0));
  }

  static InputDecoration buildInputDecoration_phone({hint_text = ""}) {
    return InputDecoration(
        hintText: hint_text,
        hintStyle:
            const TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.textfield_grey, width: 0.5),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(AppDimensions.radiusHalfSmall),
              bottomRight: Radius.circular(AppDimensions.radiusHalfSmall)),
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyTheme.primaryColor, width: 0.5),
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppDimensions.radiusHalfSmall),
                bottomRight: Radius.circular(AppDimensions.radiusHalfSmall))),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingDefault));
  }

  static InputDecoration buildInputDecoration_with_border(String hintText) {
    final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: MyTheme.textfield_grey, width: 0.5),
      borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
    );
    return InputDecoration(
        hintText: hintText,
        hintStyle:
            const TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        border: outlineInputBorder,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0));
  }
}
