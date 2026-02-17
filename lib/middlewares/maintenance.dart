import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/middlewares/middleware.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:one_context/one_context.dart';

class MaintenanceMiddleware extends Middleware {
  @override
  bool next(http.Response response) {
    try {
      final jsonData = jsonDecode(response.body);
      if (jsonData.runtimeType != List &&
          jsonData['result'] != null &&
          !jsonData['result']) {
        if (jsonData.containsKey("status") &&
            jsonData['status'] == "maintenance") {
          OneContext().addOverlay(
              overlayId: "maintenance",
              builder: (context) => Scaffold(
                    body: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      height: DeviceInfo(context).height!,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.maintenance,
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            Text(
                              jsonData['message'],
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: MyTheme.font_grey),
                            )
                          ]),
                    ),
                  ));
          return false;
        }
      }
    } on Exception {
      // TODO
    }
    return true;
  }
}
