import 'package:flutter/material.dart';

class MyTheme {
  /*configurable colors stars*/
  static const Color mainColor = Color(0xffF2F1F6);
  static Color primaryColor = const Color(0xff0f2236);
  static Color secondaryColor = const Color(0xff094484);
  static const Color accent_color_shadow =
      Color.fromRGBO(229, 65, 28, .40); // this color is a dropshadow of
  static const Color soft_accent_color = Color.fromRGBO(254, 234, 209, 1);
  /*configurable colors ends*/
  /*If you are not a developer, do not change the bottom colors*/
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color noColor = Color.fromRGBO(255, 255, 255, 0);
  static const Color light_grey = Color.fromRGBO(239, 239, 239, 1);
  static const Color dark_grey = Color.fromRGBO(107, 115, 119, 1);
  static const Color medium_grey = Color.fromRGBO(167, 175, 179, 1);
  static const Color blue_grey = Color.fromRGBO(168, 175, 179, 1);
  static const Color medium_grey_50 = Color.fromRGBO(167, 175, 179, .5);
  static const Color grey_153 = Color.fromRGBO(153, 153, 153, 1);
  static const Color dark_font_grey = Color.fromRGBO(62, 68, 71, 1);
  static const Color font_grey = Color.fromRGBO(107, 115, 119, 1);
  static const Color textfield_grey = Color.fromRGBO(209, 209, 209, 1);
  static const Color font_grey_Light = Color(0xff6B7377);
  static const Color golden = Color.fromRGBO(255, 168, 0, 1);
  static const Color amber = Color.fromRGBO(254, 234, 209, 1);
  static const Color amber_medium = Color.fromRGBO(254, 240, 215, 1);
  static const Color golden_shadow = Color.fromRGBO(255, 168, 0, .4);
  static const Color green = Colors.green;
  static Color green_light = Colors.green[200]!;
  static Color shimmer_base = Colors.grey.shade50;
  static Color shimmer_highlighted = Colors.grey.shade200;
  //testing shimmer
  /*static Color shimmer_base = MyTheme.accent_colorAccent;
  static Color shimmer_highlighted = Colors.yellow;*/

  // gradient color for coupons
  static const Color gigas = Color.fromRGBO(95, 74, 139, 1);
  static const Color polo_blue = Color.fromRGBO(152, 179, 209, 1);
  //------------
  static const Color blue_chill = Color.fromRGBO(71, 148, 147, 1);
  static const Color cruise = Color.fromRGBO(124, 196, 195, 1);
  //---------------
  static const Color brick_red = Color.fromRGBO(191, 25, 49, 1);
  static const Color cinnabar = Color.fromRGBO(226, 88, 62, 1);

  static TextTheme textTheme1 = const TextTheme(
    bodyLarge: TextStyle(fontFamily: "PublicSansSerif", fontSize: 14),
    bodyMedium: TextStyle(fontFamily: "PublicSansSerif", fontSize: 12),
  );

  static LinearGradient buildLinearGradient3() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [MyTheme.polo_blue, MyTheme.gigas],
    );
  }

  static LinearGradient buildLinearGradient2() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [MyTheme.cruise, MyTheme.blue_chill],
    );
  }

  static LinearGradient buildLinearGradient1() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [MyTheme.cinnabar, MyTheme.brick_red],
    );
  }

  static BoxShadow commonShadow() {
    return BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      spreadRadius: 0.0,
      offset: const Offset(0.0, 10.0),
    );
  }
}
