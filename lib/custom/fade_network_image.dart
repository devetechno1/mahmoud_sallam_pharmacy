import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:flutter/material.dart';

class MyImage {
  static Widget imageNetworkPlaceholder(
      {String? url,
      double height = 0.0,
      double elevation = 0.0,
      width = 0.0,
      BorderRadiusGeometry radius = BorderRadius.zero,
      BoxFit fit = BoxFit.cover,
      Color backgroundColor = Colors.white}) {
    return Material(
      color: backgroundColor,
      elevation: elevation,
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(borderRadius: radius),
        child: url != null && url.isNotEmpty
            ? ClipRRect(
                borderRadius: radius,
                child: FadeInImage.assetNetwork(
                  placeholder: AppImages.placeholder,
                  image: url,
                  height: height,
                  imageErrorBuilder: (context, object, stackTrace) {
                    return Container(
                      height: height,
                      width: width,
                      decoration: BoxDecoration(
                          borderRadius: radius,
                          image: const DecorationImage(
                              image: AssetImage(AppImages.placeholder),
                              fit: BoxFit.cover)),
                    );
                  },
                  width: width,
                  fit: fit,
                ),
              )
            : Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  image: const DecorationImage(
                    image: AssetImage(AppImages.placeholder),
                  ),
                ),
              ),
      ),
    );
  }
}
