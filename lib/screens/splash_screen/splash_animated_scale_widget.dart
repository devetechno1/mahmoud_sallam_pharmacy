import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../../app_config.dart';
import '../../my_theme.dart';

class AnimatedScaleIconWidget extends StatefulWidget {
  const AnimatedScaleIconWidget({super.key});

  @override
  State<AnimatedScaleIconWidget> createState() =>
      _AnimatedScaleIconWidgetState();
}

class _AnimatedScaleIconWidgetState extends State<AnimatedScaleIconWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingSupSmall,
                  ),
                  child: Hero(
                    tag: "splashscreenImage",
                    child: Container(
                      height: 100,
                      width: 100,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: MyTheme.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSmall,
                        ),
                      ),
                      child: Image.asset(
                        AppImages.splashScreenLogo,
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingSmallExtra),
                  child: Text(
                    'app_name'.tr(context: context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
