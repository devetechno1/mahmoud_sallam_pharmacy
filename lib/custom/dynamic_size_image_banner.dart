import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

import '../app_config.dart';
import '../helpers/shimmer_helper.dart';
import '../services/navigation_service.dart';
import 'aiz_image.dart';

class DynamicSizeImageBanner extends StatefulWidget {
  final String? urlToOpen;
  final String? photo;
  final double radius;

  const DynamicSizeImageBanner({
    Key? key,
    required this.urlToOpen,
    required this.photo,
    this.radius = 0,
  }) : super(key: key);

  @override
  State<DynamicSizeImageBanner> createState() => _DynamicSizeImageBannerState();
}

class _DynamicSizeImageBannerState extends State<DynamicSizeImageBanner> {
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _getImageSize();
  }

  void _getImageSize() {
    final Image image = Image.network(widget.photo ?? '');
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        if (mounted)
          setState(() {
            _aspectRatio = info.image.width / info.image.height;
          });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photo == null || widget.photo!.isEmpty) {
      return emptyWidget;
    }
    return Align(
      child: ConstrainedBox(
        constraints:  BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.4,
        ),
        child: InkWell(
          onTap: () =>
              NavigationService.handleUrls(widget.urlToOpen, context: context),
          child: _aspectRatio == null
              ? const LoadingImageBannerWidget()
              : AspectRatio(
                  aspectRatio: _aspectRatio!,
                  child: AIZImage.radiusImage(widget.photo, widget.radius),
                ),
        ),
      ),
    );
  }
}

class LoadingImageBannerWidget extends StatelessWidget {
  const LoadingImageBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppDimensions.paddingMedium,
          right: AppDimensions.paddingMedium,
          top: 10,
          bottom: 20),
      child: ShimmerHelper().buildBasicShimmer(height: 120),
    );
  }
}
