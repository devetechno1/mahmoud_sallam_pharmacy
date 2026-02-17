import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../constants/app_dimensions.dart';
import '../../data_model/slider_response.dart';
import '../../services/navigation_service.dart';
import '../aiz_image.dart';
import '../dynamic_size_image_banner.dart';

class HomeBannersListCircle extends StatelessWidget {
  final bool isBannersInitial;
  final List<AIZSlider> bannersImagesList;
  final double aspectRatio;
  final double viewportFraction;
  final bool padEnds;
  final bool? enlargeCenterPage;

  /// if banners list contain one banner ... it show the banner with it's real aspect ratio
  final bool makeOneBannerDynamicSize;
  final CenterPageEnlargeStrategy enlargeStrategy;

  const HomeBannersListCircle({
    Key? key,
    required this.isBannersInitial,
    required this.bannersImagesList,
    this.aspectRatio = 2,
    this.viewportFraction = 0.49,
    this.padEnds = false,
    this.enlargeCenterPage = false,
    this.makeOneBannerDynamicSize = true,
    this.enlargeStrategy = CenterPageEnlargeStrategy.scale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // When data is loading and no images are available
    if (isBannersInitial && bannersImagesList.isEmpty) {
      return const LoadingImageBannerWidget();
    }

    // When banner images are available
    else if (bannersImagesList.isNotEmpty) {
      if (bannersImagesList.length == 1 && makeOneBannerDynamicSize) {
        return DynamicSizeImageBanner(
          urlToOpen: bannersImagesList.first.url,
          photo: bannersImagesList.first.photo,
        );
      }
      final bool canScroll = bannersImagesList.length > 2;

      return Center(
        child: CarouselSlider(
          options: CarouselOptions(
            aspectRatio: aspectRatio,
            viewportFraction: viewportFraction,
            initialPage: 0,
            padEnds: padEnds,
            enlargeCenterPage: enlargeCenterPage,
            enlargeStrategy: enlargeStrategy,
            enableInfiniteScroll: canScroll,
            autoPlay: canScroll,
          ),
          items: bannersImagesList.map((i) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                color: Colors.grey.withValues(alpha: 0.1),
              ),
              margin: const EdgeInsets.all(AppDimensions.paddingHalfSmall),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSupSmall,
                  vertical: AppDimensions.paddingSupSmall),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100.0),
                  onTap: () =>
                      NavigationService.handleUrls(i.url, context: context),
                  child: AIZImage.radiusImage(
                    i.photo,
                    6,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return emptyWidget;
    }
  }
}
