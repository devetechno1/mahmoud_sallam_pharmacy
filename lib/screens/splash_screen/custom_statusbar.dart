import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

AppBar customStatusBar([SystemUiOverlayStyle? systemOverlayStyle]) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    toolbarHeight: 0,
    forceMaterialTransparency: true,
    systemOverlayStyle: systemOverlayStyle,
    automaticallyImplyLeading: false,
  );
}
