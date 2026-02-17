import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:one_context/one_context.dart';

import '../app_config.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../main.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<bool> handleUrls(
    String? url, {
    BuildContext? context,
    bool useGo = false,
    FutureOr<void> Function()? callBackDeepLink,
    FutureOr<void> Function()? callBackURL,
    FutureOr<void> Function()? callBackError,
  }) async {
    if (url?.isNotEmpty != true) return false;
    context ??= OneContext().context!;
    final Uri? uri = Uri.tryParse(url ?? '');
    try {
      if (uri != null) {
        if (uri.host == AppConfig.DOMAIN_PATH) {
          if (uri.paramPath.contains("/mobile-page")) return false;
          await callBackDeepLink?.call();
          if (useGo) {
            context.go(uri.paramPath);
          } else {
            context.push(uri.paramPath);
          }
          return true;
        } else {
          await callBackURL?.call();
          return await launchUrl(uri);
        }
      } else {
        throw 'invalidURL'.tr(context: context);
      }
    } catch (e, st) {
      await callBackError?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      recordError(e, st);

      return false;
    }
  }

/*

    Not using this as One context is used

    https://stackoverflow.com/questions/66139776/get-the-global-context-in-flutter/66140195

    Create the class. Here it named as NavigationService

    class NavigationService {
    static GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

    }

    Set the navigatorKey property of MaterialApp in the main.dart

    Widget build(BuildContext context) {
      return MaterialApp(
        navigatorKey: NavigationService.navigatorKey, // set property
      )
    }

    Great! Now you can use anywhere you want e.g.

    print("---print context:
      ${NavigationService.navigatorKey.currentContext}");


  */
}

extension URIExtension on Uri {
  String get paramPath => "$path${hasQuery ? '?$query' : ''}";
}
