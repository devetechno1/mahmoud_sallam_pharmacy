import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data_model/slider_response.dart';
import '../../presenter/home_provider.dart';
import 'home_banners_list.dart';

class HomeBannersOne extends StatelessWidget {
  const HomeBannersOne({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.select<
        HomeProvider,
        ({
          bool isBannerOneInitial,
          UnmodifiableListView<AIZSlider> bannerOneImageList
        })>(
      (provider) => (
        bannerOneImageList: UnmodifiableListView(provider.bannerOneImageList),
        isBannerOneInitial: provider.isBannerOneInitial,
      ),
    );
    return HomeBannersList(
      bannersImagesList: p.bannerOneImageList,
      isBannersInitial: p.isBannerOneInitial,
    );
  }
}
