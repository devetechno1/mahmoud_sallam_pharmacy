import 'package:active_ecommerce_cms_demo_app/custom/AIZTypeDef.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';

class ConfirmDialog {
  static Future show(BuildContext context,
      {String? title,
      required String message,
      String? yesText,
      String? noText,
      required OnPress pressYes}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('pleaseEnsureUs'.tr(context: context)),
          content: Row(
            children: [
              SizedBox(
                width: DeviceInfo(context).width! * 0.6,
                child: Text(
                  message,
                  style:
                      const TextStyle(fontSize: 14, color: MyTheme.font_grey),
                ),
              )
            ],
          ),
          actions: [
            Btn.basic(
              color: MyTheme.font_grey,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                noText ?? "",
                style: const TextStyle(fontSize: 14, color: MyTheme.white),
              ),
            ),
            Btn.basic(
              color: MyTheme.golden,
              onPressed: () {
                Navigator.pop(context);
                pressYes();
              },
              child: Text(
                'yes_ucf'.tr(context: context),
                style: const TextStyle(fontSize: 14, color: MyTheme.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
