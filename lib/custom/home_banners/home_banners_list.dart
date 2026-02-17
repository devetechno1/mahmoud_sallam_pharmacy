import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../data_model/slider_response.dart';
import '../../services/navigation_service.dart';
import '../aiz_image.dart';
import '../dynamic_size_image_banner.dart';

class HomeBannersList extends StatefulWidget {
  final bool isBannersInitial;
  final List<AIZSlider> bannersImagesList;
  final double fallbackAspectRatio;
  final double aspectRatio;
  final double viewportFraction;
  final bool padEnds;
  final bool? enlargeCenterPage;
  final bool makeOneBannerDynamicSize;
  final CenterPageEnlargeStrategy enlargeStrategy;

  const HomeBannersList({
    Key? key,
    required this.isBannersInitial,
    this.aspectRatio = 1.1,
    required this.bannersImagesList,
    this.fallbackAspectRatio = 2.0,
    this.viewportFraction = 0.49,
    this.padEnds = false,
    this.enlargeCenterPage = false,
    this.makeOneBannerDynamicSize = true,
    this.enlargeStrategy = CenterPageEnlargeStrategy.scale,
  }) : super(key: key);

  @override
  State<HomeBannersList> createState() => _HomeBannersListState();
}

class _HomeBannersListState extends State<HomeBannersList> {
  late PageController _pageController;
  int _currentPage = 0;
  final Map<int, double> _aspectByIndex = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);

    if (widget.bannersImagesList.isNotEmpty) {
      _resolveAspect(0, widget.bannersImagesList[0].photo);
    }
  }

  @override
  void didUpdateWidget(covariant HomeBannersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bannersImagesList != widget.bannersImagesList &&
        widget.bannersImagesList.isNotEmpty) {
      _aspectByIndex.clear();
      _currentPage = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // _pageController.jumpToPage(0);
        _resolveAspect(0, widget.bannersImagesList[0].photo);
      });
    }

    if (oldWidget.viewportFraction != widget.viewportFraction) {
      final oldController = _pageController;
      _pageController = PageController(
        initialPage: _currentPage,
        viewportFraction: widget.viewportFraction,
      );
      oldController.dispose();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _resolveAspect(int index, String? url) {
    if (url == null || url.isEmpty) return;
    if (_aspectByIndex.containsKey(index)) return;
    final img = Image.network(url);
    final stream = img.image.resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    listener = ImageStreamListener((info, _) {
      final w = info.image.width.toDouble();
      final h = info.image.height.toDouble();
      if (w > 0 && h > 0) {
        _aspectByIndex[index] = w / h;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
      stream.removeListener(listener!);
    }, onError: (_, __) {
      stream.removeListener(listener!);
    });
    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isBannersInitial && widget.bannersImagesList.isEmpty) {
      return const LoadingImageBannerWidget();
    }
    if (widget.bannersImagesList.isEmpty) {
      return const SizedBox();
    }
    if (widget.bannersImagesList.length == 1 &&
        widget.makeOneBannerDynamicSize) {
      return DynamicSizeImageBanner(
        urlToOpen: widget.bannersImagesList.first.url,
        photo: widget.bannersImagesList.first.photo,
      );
    }

    final canScroll = widget.bannersImagesList.length > 1;
    final currentAspect =
        widget.aspectRatio > 0 ? widget.aspectRatio : widget.fallbackAspectRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * widget.viewportFraction - 16;
        final cardHeight = cardWidth / currentAspect;

        return Container(
          // duration: const Duration(milliseconds: 100),
          height: cardHeight,
          alignment: Alignment.topCenter,
          child: PageView.builder(
            controller: _pageController,
            padEnds: widget.padEnds,
            physics: canScroll
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: widget.bannersImagesList.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _resolveAspect(i, widget.bannersImagesList[i].photo);
            },
            itemBuilder: (context, index) {
              final item = widget.bannersImagesList[index];
              _resolveAspect(index, item.photo); // هتتجاهل لو اتحسبت قبل كده

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusNormal),
                    boxShadow: [
                      BoxShadow(
                        // استخدم withOpacity لمتوافقية أحسن
                        color: const Color(0xff000000).withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusNormal),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusNormal),
                      onTap: () => NavigationService.handleUrls(
                        item.url,
                        context: context,
                      ),
                      child: AIZImage.radiusImage(item.photo, 2),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}











// import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';

// import '../../data_model/slider_response.dart';
// import '../../services/navigation_service.dart';
// import '../aiz_image.dart';
// import '../dynamic_size_image_banner.dart';

// class HomeBannersList extends StatelessWidget {
//   final bool isBannersInitial;
//   final List<AIZSlider> bannersImagesList;
//   final double aspectRatio;
//   final double viewportFraction;
//   final bool padEnds;
//   final bool? enlargeCenterPage;

//   /// if banners list contain one banner ... it show the banner with it's real aspect ratio
//   final bool makeOneBannerDynamicSize;
//   final CenterPageEnlargeStrategy enlargeStrategy;

//   const HomeBannersList({
//     Key? key,
//     required this.isBannersInitial,
//     required this.bannersImagesList,
//     this.aspectRatio = 2,
//     this.viewportFraction = 0.49,
//     this.padEnds = false,
//     this.enlargeCenterPage = false,
//     this.makeOneBannerDynamicSize = true,
//     this.enlargeStrategy = CenterPageEnlargeStrategy.scale,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // When data is loading and no images are available
//     if (isBannersInitial && bannersImagesList.isEmpty) {
//       return const LoadingImageBannerWidget();
//     }

//     // When banner images are available
//     else if (bannersImagesList.isNotEmpty) {
//       if (bannersImagesList.length == 1 && makeOneBannerDynamicSize) {
//         return DynamicSizeImageBanner(
//           urlToOpen: bannersImagesList.first.url,
//           photo: bannersImagesList.first.photo,
//         );
//       }
//       final bool canScroll = bannersImagesList.length > 2;

//       return Center(
//         child: CarouselSlider(
//           options: CarouselOptions(
            
//             aspectRatio: aspectRatio,
//             viewportFraction: viewportFraction,
//             initialPage: 0,
//             padEnds: padEnds,
//             enlargeCenterPage: enlargeCenterPage,
//             enlargeStrategy: enlargeStrategy,
//             enableInfiniteScroll: canScroll,
//             autoPlay: canScroll,
//           ),
//           items: bannersImagesList.map((i) {
//             return Container(
//               margin: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xff000000).withValues(alpha: 0.1),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
//                 child: InkWell(
//                   onTap: () =>
//                       NavigationService.handleUrls(i.url, context: context),
//                   child: AIZImage.radiusImage(i.photo, 6),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     } else {
//       return const SizedBox();
//     }
//   }
// }
