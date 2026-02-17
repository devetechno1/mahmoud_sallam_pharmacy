import 'package:flutter/material.dart';

import 'animated_image.dart';
import 'splash_animated_image.dart';
import 'splash_animated_scale_widget.dart';
import 'splash_animated_text_widget.dart';

enum SplashScreenType {
  splashAnimatedTextWidget,
  splashAnimatedScaleWidget,
  splashAnimatedImageWidget,
  AnimatedImage;

  Widget get splashScreenWidget {
    switch (this) {
      case splashAnimatedTextWidget:
        return const AnimatedTextWidget();
      case splashAnimatedScaleWidget:
        return const AnimatedScaleIconWidget();
      case splashAnimatedImageWidget:
        return const AnimatedImageWidget();
      case AnimatedImage:
        return const SplashAnimatedImage();
    }
  }

  Color screenBackgroundColor(BuildContext context) {
    switch (this) {
      case splashAnimatedTextWidget:
        return Theme.of(context).primaryColor;
      case splashAnimatedScaleWidget:
        return Theme.of(context).primaryColor;
      case splashAnimatedImageWidget:
        return Theme.of(context).primaryColor;
      case AnimatedImage:
        return Theme.of(context).primaryColor;
    }
  }
}
