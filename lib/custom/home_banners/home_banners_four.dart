import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data_model/slider_response.dart';
import '../../presenter/home_provider.dart';
import 'home_banners_list.dart';

class HomeBannersFour extends StatelessWidget {
  const HomeBannersFour({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.select<HomeProvider,
        ({bool isBannerFourInitial, UnmodifiableListView<AIZSlider> bannerFourImageList})>(
      (provider) => (
        bannerFourImageList: UnmodifiableListView(provider.bannerFourImageList),
        isBannerFourInitial: provider.isBannerThreeInitial,
      ),
    );
    return HomeBannersList(
      bannersImagesList: p.bannerFourImageList,
      isBannersInitial: p.isBannerFourInitial,
    );
  }
}
