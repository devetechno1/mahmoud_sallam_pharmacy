import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_images.dart';
import '../data_model/cart_response.dart';
import '../presenter/cart_provider.dart';
import '../screens/main.dart';
import 'image_viewer_page.dart';

class PrescriptionCardCart extends StatelessWidget {
  const PrescriptionCardCart({
    super.key,
    required this.titleTextStyle,
    required this.padding,
  });

  final EdgeInsets padding;
  final TextStyle titleTextStyle;

  @override
  Widget build(BuildContext context) {
    final CartItem? prescriptionItem = context.select(
      (CartProvider provider) => provider.prescriptionItem,
    );

    return PrescriptionCard(
      canAddMore: true,
      padding: padding,
      titleTextStyle: titleTextStyle,
      onDelete: (id) => onDeleteAt(id, context),
      images: prescriptionItem?.prescriptionImages ?? [],
    );
  }

  Future<void> onDeleteAt(String id, BuildContext context) async {
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).removePrescription(id, context);
  }
}

class PrescriptionCard extends StatelessWidget {
  const PrescriptionCard({
    super.key,
    required this.images,
    this.titleTextStyle,
    this.onDelete,
    required this.canAddMore,
    required this.padding,
  });
  final bool canAddMore;
  final EdgeInsets padding;
  final TextStyle? titleTextStyle;
  final List<PrescriptionImages> images;
  final void Function(String id)? onDelete;

  @override
  Widget build(BuildContext context) {
    const double dimension = 130.0;
    const Radius radius = Radius.circular(AppDimensions.radiusSmall);
    const BorderRadius borderRadius = BorderRadius.all(radius);

    int calcNumber = 0;
    if (canAddMore) calcNumber = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppDimensions.paddingNormal,
      children: [
        Padding(
          padding: padding,
          child: Text(
            'prescription'.tr(context: context),
            style: titleTextStyle,
          ),
        ),
        SizedBox(
          height: dimension,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: padding,
            itemCount: images.length + calcNumber,
            separatorBuilder: (context, index) => const SizedBox(
              width: AppDimensions.paddingDefault,
            ),
            itemBuilder: (context, index) {
              final int i = images.length - index - 1 + calcNumber;
              if (i == images.length) {
                return SizedBox(
                  width: dimension,
                  child: InkWell(
                    onTap: () {
                      addPrescriptionFN(
                        context,
                        Provider.of<HomeProvider>(context, listen: false).presc,
                      );
                    },
                    radius: AppDimensions.radiusSmall,
                    borderRadius: borderRadius,
                    child: const DottedBorder(
                      options: RoundedRectDottedBorderOptions(radius: radius),
                      child: Center(child: Icon(Icons.add)),
                    ),
                  ),
                );
              }

              final PrescriptionImages x = images[i];
              return SizedBox(
                width: dimension,
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Stack(
                    fit: StackFit.loose,
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () => canAddMore
                              ? onOpenViewer(i, images)
                              : onOpenViewer(index, images.reversed.toList()),
                          child: Hero(
                            tag: "${x.image}",
                            transitionOnUserGestures: true,
                            child: ClipRRect(
                              borderRadius: borderRadius,
                              child: Material(
                                type: MaterialType.transparency,
                                child: CachedNetworkImage(
                                  imageUrl: x.image,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Image.asset(
                                    AppImages.placeholder,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (onDelete != null)
                        IconButton.filled(
                          onPressed: () => onDelete!(x.id),
                          style: IconButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                            backgroundColor:
                                Colors.blueGrey.withValues(alpha: 0.5),
                          ),
                          icon: const Icon(Icons.delete_outline),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void onOpenViewer(int i, List<PrescriptionImages> imgs) {
    Navigator.push(
      OneContext().context!,
      MaterialPageRoute(
        builder: (_) => ImageViewerPage.prescription(
          imgs,
          initialIndex: i,
          heroTags:
              List.generate(imgs.length, (index) => "${imgs[index].image}"),
        ),
      ),
    );
  }
}
