import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../my_theme.dart';

class SplashAnimatedImage extends StatelessWidget {
  const SplashAnimatedImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: AppDimensions.paddingSupSmall,
          ),
          child: Container(
              height: 200,
              width: 200,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: MyTheme.white,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusSmall,
                ),
              ),
              child: TweenAnimationBuilder(
                duration: const Duration(seconds: 2),
                tween: Tween<double>(begin: 0.3, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  AppImages.splashScreenLogo,
                  filterQuality: FilterQuality.high,
                ),
              )),
        ),
        // Padding(
        //   padding:
        //       const EdgeInsets.only(bottom: AppDimensions.paddingSmallExtra),
        //   child: AnimatedTextKit(
        //     isRepeatingAnimation: false,
        //     animatedTexts: [
        //       TyperAnimatedText(
        //         'app_name'.tr(context: context),
        //         textStyle: const TextStyle(
        //           fontSize: 20.0,
        //           fontWeight: FontWeight.bold,
        //           color: Colors.white,
        //         ),
        //         speed: const Duration(milliseconds: 100),
        //       ),
        //     ],
        //   ),
        // )
      ],
    );
  }
}
