import 'package:flutter/material.dart';

const double maxPhoneWidth = 600;
const double maxTabletWidth = 900;

extension ContextHelperEx on BuildContext {
  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;
  bool get isPhoneWidth => width <= maxPhoneWidth;
  bool get isTabletWidth => width <= maxTabletWidth;
  bool get isDesktopWidth => width > maxTabletWidth;
}
