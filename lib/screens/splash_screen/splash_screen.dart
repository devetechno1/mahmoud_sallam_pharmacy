import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_statusbar.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: AppConfig.splashType.screenBackgroundColor(context),
      appBar: customStatusBar(SystemUiOverlayStyle.light),
      body: InkWell(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              top: DeviceInfo(context).height! / 2 - 72,
              child: AppConfig.splashType.splashScreenWidget,
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "BV ${AppConfig.backendVersion}",

                  /// Backend version
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 10.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "AV ${AppConfig.mobileVersion}",

                  /// App version
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 10.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
