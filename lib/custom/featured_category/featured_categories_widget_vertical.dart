import 'package:flutter/material.dart';

import '../../constants/app_dimensions.dart';
import '../../constants/app_images.dart';
import '../../helpers/grid_responsive.dart';
import '../../helpers/shimmer_helper.dart';
import '../../my_theme.dart';
import '../../screens/category_list_n_product/category_products.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

class FeatureCategoriesWidgetVertical extends StatelessWidget {
  final int crossAxisCount;
  final bool isCategoryInitial;
  final List featuredCategoryList;
  const FeatureCategoriesWidgetVertical({
    super.key,
    required this.crossAxisCount,
    required this.isCategoryInitial,
    required this.featuredCategoryList,
  });

  @override
  Widget build(BuildContext context) {
    final int cross = GridResponsive.columnsForWidth(context);
    if (isCategoryInitial && featuredCategoryList.isEmpty) {
      // Handle shimmer loading here (if no categories loaded yet)
      return ShimmerHelper().buildGridShimmerWithAxisCount(
        aspectRatio: 1,
        crossAxisCount: cross,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        item_count: 10,
        mainAxisExtent: 170.0,
      );
    } else if (featuredCategoryList.isNotEmpty) {
      // Calculate dynamic mainAxisExtent for tablets
      var width = MediaQuery.of(context).size.width;
      double mainAxisExtent = 150.0; // Default for mobile

      if (width > GridResponsive.bpSm) {
        // Tablet logic:
        // Total horizontal padding: 20 (left) + 20 (right) = 40
        // Total cross axis spacing: (crossAxisCount - 1) * 12
        // Item width = (Screen Width - Padding - Spacing) / crossAxisCount
        // Height needed = ItemWidth (image aspect ratio 1:1) + 90 (text + vertical spacing/padding estimate)

        double horizontalPadding = AppDimensions.paddingLarge * 2;
        double totalSpacing = (crossAxisCount - 1) * 12;
        double itemWidth =
            (width - horizontalPadding - totalSpacing) / crossAxisCount;
        mainAxisExtent = itemWidth + 90;
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
            left: AppDimensions.paddingLarge,
            right: AppDimensions.paddingLarge,
            top: 11,
            bottom: 24),
        scrollDirection: Axis.vertical,
        itemCount: featuredCategoryList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1, // Ensures square boxes
            crossAxisSpacing: 12,
            mainAxisSpacing: 3,
            mainAxisExtent: mainAxisExtent),
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CategoryProducts(
                        name: featuredCategoryList[index].name ?? '',
                        slug: featuredCategoryList[index].slug ?? '',
                      );
                    },
                  ),
                );
              },
              child: Container(
                child: Column(
                  children: [
                    AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff000000)
                                    .withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusNormal),
                            child: FadeInImage.assetNetwork(
                              placeholder: AppImages.placeholder,
                              image:
                                  featuredCategoryList[index].coverImage ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        featuredCategoryList[index].name ?? '',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: MyTheme.font_grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        },
      );
    } else if (!isCategoryInitial && featuredCategoryList.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            'no_category_found'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    } else {
      return Container(
        height: 100,
      );
    }
  }
}
