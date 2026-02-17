import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../helpers/shimmer_helper.dart';
import '../../../my_theme.dart';

// ignore: must_be_immutable
class ProductSliderImageWidget extends StatefulWidget {
  final List<String>? productImageList;
  final CarouselSliderController? carouselController;
  int? currentImage;
  ProductSliderImageWidget({
    Key? key,
    this.productImageList,
    this.carouselController,
    this.currentImage,
  }) : super(key: key);

  @override
  State<ProductSliderImageWidget> createState() =>
      _ProductSliderImageWidgetState();
}

class _ProductSliderImageWidgetState extends State<ProductSliderImageWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.productImageList!.isEmpty) {
      return ShimmerHelper().buildBasicShimmer(height: 190.0);
    } else {
      return Stack(
        children: [
          Positioned.fill(
            child: CarouselItemCoverWidget(
              productImageList: widget.productImageList,
              currentImage: widget.currentImage,
              carouselController: widget.carouselController,
              onPageChanged: (index, reason) {
                setState(() {
                  widget.currentImage = index;
                });
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB7B2B2).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSmallExtra),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.productImageList!.length,
                    (index) => Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.currentImage == index
                            ? Colors.black.withValues(alpha: 0.9)
                            : const Color(0xff484848).withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

class CarouselItemCoverWidget extends StatelessWidget {
  const CarouselItemCoverWidget({
    super.key,
    this.productImageList,
    this.carouselController,
    this.currentImage,
    this.onPageChanged,
  });

  final List<String>? productImageList;
  final CarouselSliderController? carouselController;
  final int? currentImage;
  final Function(int, CarouselPageChangedReason)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    final imgs = productImageList ?? const <String>[];
    final startIndex = (currentImage ?? 0).clamp(0, imgs.isEmpty ? 0 : imgs.length - 1);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppDimensions.phoneMaxWidth),
      child: CarouselSlider(
        carouselController: carouselController,
        options: CarouselOptions(
          aspectRatio: 355 / 375,
          viewportFraction: 1,
          initialPage: 0,
          autoPlay: imgs.length > 1,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(milliseconds: 1000),
          autoPlayCurve: Curves.easeInExpo,
          enlargeCenterPage: false,
          scrollDirection: Axis.horizontal,
          onPageChanged: onPageChanged,
        ),
        items: imgs.map(
          (i) {
            return Builder(
              builder: (BuildContext context) {
                return InkWell(
                  onTap: () {
                    openPhotoDialog(
                      context,
                      imgs,
                      startIndex,
                    );
                  },
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: FadeInImage.assetNetwork(
                      placeholder: AppImages.placeholderRectangle,
                      image: i,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                );
              },
            );
          },
        ).toList(),
      ),
    );
  }

  Future<void> openPhotoDialog(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) async {
    if (images.isEmpty) return;

    final pageController = PageController(initialPage: initialIndex);

    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext dialogContext) {
        int current = initialIndex;

        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              insetPadding:
                  const EdgeInsets.all(AppDimensions.paddingDefault),
              child: Stack(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(AppDimensions.paddingDefault),
                    decoration: BoxDecoration(
                      color: MyTheme.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radius),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radius),
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: images.length,
                        onPageChanged: (i) => setState(() => current = i),
                        itemBuilder: (context, index) {
                          final url = images[index];
                          return InteractiveViewer(
                            panEnabled: true,
                            minScale: 1.0,
                            maxScale: 4.0,
                            child: Image.network(
                              url,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // close button
                  Positioned(
                    top: AppDimensions.paddingHalfSmall,
                    right: AppDimensions.paddingHalfSmall,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: MyTheme.medium_grey_50,
                        shape: BoxShape.circle,
                      ),
                      width: 40,
                      height: 40,
                      child: IconButton(
                        icon: const Icon(Icons.clear, color: MyTheme.white),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: AppDimensions.paddingHalfSmall,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSmallExtra,
                          vertical: AppDimensions.paddingHalfSmall,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${current + 1} / ${images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
