import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../data_model/slider_response.dart';
import 'home_banners_list.dart';

class HomeBannersListAnimation extends StatelessWidget {
  final bool isBannersInitial;
  final List<AIZSlider> bannersImagesList;
  final double aspectRatio;
  final double viewportFraction;
  final bool canScroll;

  const HomeBannersListAnimation({
    Key? key,
    required this.isBannersInitial,
    required this.bannersImagesList,
    this.aspectRatio = 2,
    this.viewportFraction = 0.49,
    this.canScroll = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeBannersList(
      makeOneBannerDynamicSize: false,
      enlargeCenterPage: true,
      padEnds: true,
      aspectRatio: 2.4,
      viewportFraction: 0.7,
      enlargeStrategy: CenterPageEnlargeStrategy.zoom,
      isBannersInitial: isBannersInitial,
      bannersImagesList: bannersImagesList,
    );
  }
}
