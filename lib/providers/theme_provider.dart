import 'package:flutter/material.dart';
import '../my_theme.dart';

class ThemeProvider with ChangeNotifier {
  Color primary = MyTheme.primaryColor;
  Color secondary = MyTheme.secondaryColor;

  void changeAppColors({Color? primary, Color? secondary}) {
    this.primary = primary ?? MyTheme.primaryColor;
    this.secondary = secondary ?? MyTheme.secondaryColor;

    MyTheme.primaryColor = this.primary;
    MyTheme.secondaryColor = this.secondary;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => notifyListeners(),
    );
  }
}
