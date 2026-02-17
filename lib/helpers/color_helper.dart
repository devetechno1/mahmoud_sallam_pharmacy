import 'package:flutter/material.dart';

class ColorHelper {
  static Color getColorFromColorCode(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

/*************  ✨ Windsurf Command ⭐  *************/
  /// Converts a hex color string to a [Color] object.
  ///
  /// The [hexColor] parameter is a string representing a hex color code,
  /// which can optionally start with a '#' character. The function ensures
  /// that the provided string has a length of 6 by appending 'F' characters
  /// if necessary. It returns a [Color] object if the conversion is successful,
  /// or null if the input is invalid or not a valid color code.
  ///
  /// Example:
  /// ```dart
  /// Color? color = ColorHelper.hexToColor("#ff5733");
  /// ```

  /// *****  c2c38926-3e9e-430a-9f31-9320365ca54b  ******
  static Color? stringToColor(String? hexColor) {
    hexColor = hexColor?.replaceAll("#", "").trim();
    if (hexColor == null || hexColor.length < 3) return null;

    for (int i = hexColor.length; i < 6; i++) hexColor = "F$hexColor";

    hexColor = "0xFF${hexColor.toString()}";

    final int? color = int.tryParse("$hexColor");
    if (color == null) return null;
    return Color(color);
  }
}
