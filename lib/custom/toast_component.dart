import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:one_context/one_context.dart';

import '../my_theme.dart';

class ToastComponent {
  static Future<void> showDialog(
    String msg, {
    bool isError = false,
    Toast? toastLength,
    ToastGravity? gravity,
    Color? color,
  }) async {
    // ToastContext().init(OneContext().context!);
    await Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength ?? Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.CENTER,
      backgroundColor: isError
          ? Theme.of(OneContext().context!).colorScheme.error
          : color ?? const Color.fromRGBO(239, 239, 239, .9),
      textColor: color != null || isError ? MyTheme.white : MyTheme.font_grey,
    );
  }
}
