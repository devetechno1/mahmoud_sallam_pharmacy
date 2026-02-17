import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_config.dart';
import '../../data_model/flash_deal_response.dart';
import '../dynamic_size_image_banner.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

class FlashDealBanner extends StatelessWidget {

  const FlashDealBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ({List<FlashDealResponseDatum> banners, bool isFlashDealInitial}) p =
        context.select<HomeProvider,
            ({bool isFlashDealInitial, UnmodifiableListView<FlashDealResponseDatum> banners})>(
      (provider) => (
        banners: UnmodifiableListView(provider.banners),
        isFlashDealInitial: provider.isFlashDealInitial,
      ),
    );

    // When data is loading and no images are available
    if (p.isFlashDealInitial && p.banners.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
            left: AppDimensions.paddingMedium,
            right: AppDimensions.paddingMedium,
            top: 10,
            bottom: 20),
        child: ShimmerHelper().buildBasicShimmer(height: 120),
      );
    }

    // When banner images are available
    else if (p.banners.isNotEmpty) {
      return CarouselSlider(
        options: CarouselOptions(
          height: 237,
          aspectRatio: 1,
          viewportFraction: .60,
          initialPage: 0,
          padEnds: false,
          enableInfiniteScroll: true,
          autoPlay: true,
          onPageChanged: (index, reason) {
            // Optionally handle page change
          },
        ),
        items: p.banners.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Padding(
                padding:
                    const EdgeInsetsDirectional.only(start: 12, bottom: 10),
                child: FlashBannerWidget(bannerLink: i.banner, slug: i.slug),
              );
            },
          );
        }).toList(),
      );
    }

    // When images are not found and loading is complete
    else if (!p.isFlashDealInitial && p.banners.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            'no_carousel_image_found'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    }

    // Default container if no condition matches
    else {
      return const SizedBox(height: 100);
    }
  }
}

class FlashBannerWidget extends StatelessWidget {
  const FlashBannerWidget({
    super.key,
    required this.bannerLink,
    required this.slug,
  });
  final String? bannerLink;
  final String? slug;

  @override
  Widget build(BuildContext context) {
    return DynamicSizeImageBanner(
      urlToOpen: "${AppConfig.RAW_BASE_URL}/flash-deal/$slug",
      photo: bannerLink,
      radius: 10,
    );
  }
}
