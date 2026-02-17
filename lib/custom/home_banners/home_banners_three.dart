import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data_model/slider_response.dart';
import '../../presenter/home_provider.dart';
import 'home_banners_list.dart';

class HomeBannersThree extends StatelessWidget {
  const HomeBannersThree({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.select<HomeProvider,
        ({bool isBannerThreeInitial, UnmodifiableListView<AIZSlider> bannerThreeImageList})>(
      (provider) => (
        bannerThreeImageList: UnmodifiableListView(provider.bannerThreeImageList),
        isBannerThreeInitial: provider.isBannerThreeInitial,
      ),
    );
    return HomeBannersList(
      bannersImagesList: p.bannerThreeImageList,
      isBannersInitial: p.isBannerThreeInitial,
    );
  }
}
