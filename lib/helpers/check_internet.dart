import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetHelper {
  static void listenToConnectivityChanges(BuildContext context,
      [bool isFirst = true]) {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (results.contains(ConnectivityResult.none)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              'check_your_internet_connection'.tr(context: context),
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(days: 1),
          ),
        );
      } else {
        if (!isFirst) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('success_internet_connection'.tr(context: context),
                  style: const TextStyle(color: Colors.white)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
      isFirst = false;
    });
  }
}
