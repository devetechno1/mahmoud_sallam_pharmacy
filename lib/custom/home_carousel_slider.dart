import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_model/slider_response.dart';
import '../presenter/home_provider.dart';
import 'home_banners/home_banners_list.dart';

class HomeCarouselSlider extends StatelessWidget {
  const HomeCarouselSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<HomeProvider,
        ({bool isCarouselInitial, UnmodifiableListView<AIZSlider> carouselImageList})>(
      selector: (_, provider) => (
        isCarouselInitial: provider.isCarouselInitial,
        carouselImageList: UnmodifiableListView(provider.carouselImageList),
      ),
      builder: (context, p, child) {
        return HomeBannersList(
          isBannersInitial: p.isCarouselInitial,
          bannersImagesList: p.carouselImageList,
          aspectRatio: 338 / 140,
          viewportFraction: 1,
        );
      },
    );
  }
}
