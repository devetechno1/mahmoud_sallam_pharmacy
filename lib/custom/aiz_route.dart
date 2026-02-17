import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/otp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_config.dart';
import '../data_model/otp_provider_model.dart';

class AIZRoute {
  static Otp otpRoute(
    BuildContext context,
    String? emailOrPhone,
    OTPProviderModel? provider,
  ) =>
      Otp(
        title: 'verifyYourAccount'.tr(context: context),
        isPhone: provider != null,
        fromRegistration: false,
        emailOrPhone: emailOrPhone,
        provider: provider,
      );

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget route,
    String? emailOrPhone,
    OTPProviderModel? provider,
    bool isPhone,
  ) {
    if (_isMailVerifiedRoute(route)) {
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => otpRoute(
            context,
            emailOrPhone,
            getProvider(isPhone, provider),
          ),
        ),
      );
    }
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => route));
  }

  static Future<T?> slideLeft<T extends Object?>(
    BuildContext context,
    Widget route,
    String? emailOrPhone,
    OTPProviderModel? provider,
    bool isPhone,
  ) {
    if (_isMailVerifiedRoute(route)) {
      return Navigator.push(
        context,
        _leftTransition<T>(
          otpRoute(
            context,
            emailOrPhone,
            getProvider(isPhone, provider),
          ),
        ),
      );
    }

    return Navigator.push(context, _leftTransition<T>(route));
  }

  static OTPProviderModel? getProvider(
    bool isPhone,
    OTPProviderModel? provider,
  ) {
    return isPhone
        ? provider ?? AppConfig.businessSettingsData.otpProviders.firstOrNull
        : null;
  }

  static Future<T?> slideRight<T extends Object?>(
    BuildContext context,
    Widget route,
    String? emailOrPhone,
    OTPProviderModel? provider,
    bool isPhone,
  ) {
    if (_isMailVerifiedRoute(route)) {
      return Navigator.push(
        context,
        _rightTransition<T>(
          otpRoute(
            context,
            emailOrPhone,
            getProvider(isPhone, provider),
          ),
        ),
      );
    }
    return Navigator.push(context, _rightTransition<T>(route));
  }

  static Route<T> _leftTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = !(app_language_rtl.$!)
            ? const Offset(-1.0, 0.0)
            : const Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route<T> _rightTransition<T extends Object?>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage rightTransition(Widget page) {
    return CustomTransitionPage(
      child: page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = !(app_language_rtl.$!)
            ? const Offset(1.0, 0.0)
            : const Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static bool _isMailVerifiedRoute(Widget widget) {
    // bool mailVerifiedRoute = true;
    // mailVerifiedRoute = <Type>[SelectAddress, Address, Profile]
    //     .any((element) => widget.runtimeType == element);
    if (is_logged_in.$ &&
        // mailVerifiedRoute &&
        SystemConfig.systemUser != null) {
      final bool isMailVerified =
          SystemConfig.systemUser!.emailVerified ?? false;

      if (isMailVerified) {
        return false;
      } else {
        if (SystemConfig.systemUser!.phone != null) {
          if (!AppConfig.businessSettingsData.mustOtp) return false;
        }
        return true;
      }

      // return !isMailVerified;
    }
    return false;
  }
}
