import "package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart";
import "package:active_ecommerce_cms_demo_app/my_theme.dart";
import "package:flutter/material.dart";
import "package:one_context/one_context.dart";

import "../app_config.dart";

class Btn {
  static Widget basic({
    Color color = const Color.fromARGB(0, 0, 0, 0),
    bool isLoading = false,
    OutlinedBorder shape = const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.radiusNormal))),
    Widget child = emptyWidget,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    double? minWidth,
    Color? disabledBackgroundColor,
    void Function()? onPressed,
  }) {
    //if (width != null && height != null)
    return TextButton(
      style: TextButton.styleFrom(
        padding: padding,
        backgroundColor: color,
        // primary: MyTheme.noColor,
        minimumSize: minWidth == null ? null : Size(minWidth, 10),
        disabledBackgroundColor: disabledBackgroundColor ??
            Theme.of(OneContext().context!).disabledColor,
        shape: shape,
      ),
      child: child,
      onPressed: isLoading ? null : () => onPressed?.call(),
    );
  }

  static Widget minWidthFixHeight(
      {required minWidth,
      required double height,
      color,
      shape,
      required child,
      dynamic onPressed}) {
    return TextButton(
      style: TextButton.styleFrom(
          foregroundColor: MyTheme.noColor,
          minimumSize: Size(minWidth.toDouble(), height.toDouble()),
          backgroundColor: onPressed != null ? color : MyTheme.grey_153,
          shape: shape,
          disabledForegroundColor: Colors.blue),
      child: child,
      onPressed: onPressed,
    );
  }

  static Widget maxWidthFixHeight(
      {required maxWidth,
      required height,
      color,
      shape,
      required child,
      dynamic onPressed}) {
    return TextButton(
      style: TextButton.styleFrom(
          // primary: MyTheme.noColor,
          maximumSize: Size(maxWidth, height),
          backgroundColor: color,
          shape: shape),
      child: child,
      onPressed: onPressed,
    );
  }
}
