import 'dart:io';

import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonFunctions {
  BuildContext context;

  CommonFunctions(this.context);

  void appExitDialog() {
    showDialog(
        context: context,
        builder: (context) => Directionality(
              textDirection:
                  app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                content: Text('do_you_want_close_the_app'.tr(context: context)),
                actions: [
                  TextButton(
                      onPressed: () {
                        Platform.isAndroid ? SystemNavigator.pop() : exit(0);
                      },
                      child: Text('yes_ucf'.tr(context: context))),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('no_ucf'.tr(context: context))),
                ],
              ),
            ));
  }

  static TextStyle dashboardBoxNumber(context) {
    return const TextStyle(
        fontSize: 16, color: MyTheme.white, fontWeight: FontWeight.bold);
  }

  static TextStyle dashboardBoxText(context) {
    return const TextStyle(
        fontSize: 12, color: MyTheme.white, fontWeight: FontWeight.bold);
  }
}
