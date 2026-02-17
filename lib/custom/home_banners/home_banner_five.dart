import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data_model/slider_response.dart';
import '../../presenter/home_provider.dart';
import 'home_banners_list.dart';

class HomeBannersFive extends StatelessWidget {
  const HomeBannersFive({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.select<HomeProvider,
        ({bool isBannerFiveInitial, UnmodifiableListView<AIZSlider> bannerFiveImageList})>(
      (provider) => (
        bannerFiveImageList: UnmodifiableListView(provider.bannerFiveImageList),
        isBannerFiveInitial: provider.isBannerFiveInitial,
      ),
    );
    return HomeBannersList(
      bannersImagesList: p.bannerFiveImageList,
      isBannersInitial: p.isBannerFiveInitial,
    );
  }
}
