import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data_model/slider_response.dart';
import '../../presenter/home_provider.dart';
import 'home_banners_list.dart';

class HomeBannersTwo extends StatelessWidget {
  const HomeBannersTwo({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.select<
        HomeProvider,
        ({
          bool isBannerTwoInitial,
          UnmodifiableListView<AIZSlider> bannerTwoImageList
        })>(
      (provider) => (
        bannerTwoImageList: UnmodifiableListView(provider.bannerTwoImageList),
        isBannerTwoInitial: provider.isBannerTwoInitial,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      child: HomeBannersList(
        bannersImagesList: p.bannerTwoImageList,
        isBannersInitial: p.isBannerTwoInitial,
      ),
    );
  }
}
