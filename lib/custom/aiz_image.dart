import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AIZImage {
  static Widget basicImage(String url, {BoxFit fit = BoxFit.cover}) {
    return CachedNetworkImage(
      fit: fit,
      imageUrl: url,
      progressIndicatorBuilder: (context, string, progress) {
        return Image.asset(
          AppImages.placeholderRectangle,
          fit: BoxFit.cover,
        );
      },
      // placeholder:(BuildContext context,error){
      //   return Image.asset('assets/images/342x632.jpg',fit: BoxFit.cover,);
      // } ,
      // progressIndicatorBuilder: (context, url, downloadProgress) =>
      //     CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => Image.asset(
        AppImages.placeholderRectangle,
        fit: BoxFit.cover,
      ),
    );
  }

  static Widget radiusImage(String? url, double radius,
      {BoxFit fit = BoxFit.cover, bool isShadow = true}) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: CachedNetworkImageProvider(
                url ?? "",
              ),
              fit: fit,
              onError: (obj, e) {
                //  return AssetImage("assets/placeholder_rectangle.png");
              }),
          borderRadius: BorderRadius.circular(radius),
          color: Colors.white,
          boxShadow: isShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 20,
                    spreadRadius: 0.0,
                    offset: const Offset(
                        0.0, 10.0), // shadow direction: bottom right
                  )
                ]
              : []),
    );
  }
}
