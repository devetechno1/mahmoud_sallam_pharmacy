import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:flutter/material.dart';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

class PiratedWidget extends StatelessWidget {
  const PiratedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AppConfig.purchase_code != "") return emptyWidget;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        9.0,
        16.0,
        9.0,
        0.0,
      ),
      child: Container(
        height: 140,
        color: Colors.black,
        child: Stack(
          children: [
            Positioned(
                left: 20,
                top: 0,
                child: Image.asset(
                  AppImages.piratedSquare,
                  color: Colors.white,
                )),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: AppDimensions.paddingMaxLarge,
                    left: AppDimensions.paddingMaxLarge,
                    right: AppDimensions.paddingMaxLarge),
                child: Text(
                  'pirated_app'.tr(context: context),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
