import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';

abstract final class ShowMySnackBar {
  const ShowMySnackBar();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? call(
    String content, {
    Duration? duration,
    TextStyle? style,
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    final BuildContext? context = OneContext().context;
    if (context == null) return null;
    final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    scaffold.clearSnackBars();
    return scaffold.showSnackBar(
      SnackBar(
        width: 400,
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: style ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: backgroundColor == null ? null : Colors.white,
              ),
        ),
        action: action,
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppDimensions.paddingDefault),
        duration: duration ?? const Duration(milliseconds: 4000),
        actionOverflowThreshold: 1,
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? success(
    String content,
  ) {
    return call(content, backgroundColor: Colors.green);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      reRequestPermissionToast({
    required String text,
    required String actionText,
    required void Function() onPressed,
  }) {
    return call(
      text,
      duration: const Duration(seconds: 5),
      backgroundColor: Theme.of(OneContext().context!).colorScheme.error,
      action: SnackBarAction(
        label: actionText,
        onPressed: onPressed,
        backgroundColor: Colors.white,
        textColor: Theme.of(OneContext().context!).primaryColor,
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? error(
    String text,
  ) {
    return call(
      text,
      duration: const Duration(seconds: 4),
      backgroundColor: Theme.of(OneContext().context!).colorScheme.error,
    );
  }
}
