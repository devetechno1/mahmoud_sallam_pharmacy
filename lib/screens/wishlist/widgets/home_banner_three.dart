import 'package:active_ecommerce_cms_demo_app/custom/aiz_image.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app_config.dart';
import '../../../data_model/slider_response.dart';
import '../../../helpers/shimmer_helper.dart';
import '../../../my_theme.dart';

class HomeBannerThree extends StatelessWidget {
  const HomeBannerThree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.select<HomeProvider,
        ({bool isBannerOneInitial, List<AIZSlider> bannerOneImageList})>(
      (HomeProvider provider) => (
        bannerOneImageList: provider.bannerOneImageList,
        isBannerOneInitial: provider.isBannerOneInitial,
      ),
    );
    if (homeProvider.isBannerOneInitial &&
        homeProvider.bannerOneImageList.isEmpty) {
      return Padding(
          padding: const EdgeInsets.only(
              left: AppDimensions.paddingMedium,
              right: AppDimensions.paddingMedium,
              top: 10,
              bottom: 20),
          child: ShimmerHelper().buildBasicShimmer(height: 120));
    } else if (homeProvider.bannerOneImageList.isNotEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 0.5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 156,
            aspectRatio: 1.1,
            viewportFraction: 0.43,
            initialPage: 0,
            padEnds: false,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 2),
            autoPlayAnimationDuration: const Duration(milliseconds: 300),
            onPageChanged: (index, reason) {
              // Optionally handle page change
            },
          ),
          items: homeProvider.bannerOneImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: 156,
                  height: 156,
                  child: InkWell(
                    onTap: () {
                      final url =
                          i.url?.split(AppConfig.DOMAIN_PATH).last ?? "";
                      print(url);
                      GoRouter.of(context).go(url);
                    },
                    child: AIZImage.radiusImage(i.photo, 6),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    } else if (!homeProvider.isBannerOneInitial &&
        homeProvider.bannerOneImageList.isEmpty) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            'no_carousel_image_found'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }
}
