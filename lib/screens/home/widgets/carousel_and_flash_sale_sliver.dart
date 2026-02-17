import 'package:flutter/material.dart';

import '../../../custom/home_carousel_slider.dart';
import '../../../custom/pirated_widget.dart';
import 'flash_sale.dart';

/// PiratedWidget -> HomeCarouselSlider -> FlashSale
class CarouselAndFlashSaleSliver extends StatelessWidget {
  const CarouselAndFlashSaleSliver({
    super.key,
    this.isFlashSaleCircle = false,
    this.flashSaleBackgroundColor,
    this.flashSaleDefaultTextColor,
  });
  final bool isFlashSaleCircle;
  final Color? flashSaleBackgroundColor;
  final Color? flashSaleDefaultTextColor;

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: [
        const PiratedWidget(),
        const SizedBox(height: 10),

        // Header Banner
        const HomeCarouselSlider(),

        const SizedBox(height: 16),

        // Flash Sale Section
        FlashSale(
          isCircle: isFlashSaleCircle,
          backgroundColor: flashSaleBackgroundColor,
          defaultTextColor: flashSaleDefaultTextColor,
        )
      ],
    );
  }
}
