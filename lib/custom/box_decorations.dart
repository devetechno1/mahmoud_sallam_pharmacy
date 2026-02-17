import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:flutter/material.dart';

class BoxDecorations {
  static BoxDecoration buildBoxDecoration_1({double radius = 6.0}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: Colors.white,
      // boxShadow: [
      //   BoxShadow(
      //     color: Colors.black.withValues(alpha: .08),
      //     blurRadius: 20,
      //     spreadRadius: 0.0,
      //     offset: Offset(0.0, 10.0), // shadow direction: bottom right
      //   )
      // ],
    );
  }

  static BoxDecoration buildBoxDecoration_with_shadow({double radius = 6.0}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .08),
          blurRadius: 20,
          spreadRadius: 0.0,
          offset: const Offset(0.0, 10.0), // shadow direction: bottom right
        )
      ],
    );
  }

  static BoxDecoration buildCartCircularButtonDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
      color: const Color.fromRGBO(229, 241, 248, 1),
    );
  }

  static BoxDecoration buildCircularButtonDecoration_1() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppDimensions.radiusVeryLarge),
      color: Colors.white.withValues(alpha: .80),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .08),
          blurRadius: 20,
          spreadRadius: 0.0,
          offset: const Offset(0.0, 10.0), // shadow direction: bottom right
        )
      ],
    );
  }

  static BoxDecoration buildCircularButtonDecoration_for_productDetails() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: .80),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .08),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0.0, 10.0), // shadow direction: bottom right
        )
      ],
    );
  }
}
