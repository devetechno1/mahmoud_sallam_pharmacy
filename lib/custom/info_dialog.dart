import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';

class InfoDialog {
  static Future show({required String title, Widget? content}) {
    return OneContext().showDialog(
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusSmallExtra),
              topRight: Radius.circular(AppDimensions.radiusSmallExtra),
            ),
          ),
          padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyTheme.white),
          ),
        ),
        content: content ?? const Text(""),
        actions: [
          Btn.basic(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusHalfSmall)),
            color: MyTheme.grey_153,
            onPressed: () => Navigator.pop(context),
            child: Text('ok'.tr(context: context),
                style: const TextStyle(fontSize: 14, color: MyTheme.white)),
          ),
        ],
      ),
    );
  }
}
