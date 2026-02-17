import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/category_products.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data_model/category_response.dart';

import '../../my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

class FeaturedCategoriesWidget extends StatelessWidget {
  const FeaturedCategoriesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ({
      UnmodifiableListView<Category> featuredCategoryList,
      bool isCategoryInitial
    }) p = context.select<
        HomeProvider,
        ({
          bool isCategoryInitial,
          UnmodifiableListView<Category> featuredCategoryList
        })>(
      (provider) => (
        featuredCategoryList:
            UnmodifiableListView(provider.featuredCategoryList),
        isCategoryInitial: provider.isCategoryInitial,
      ),
    );
    if (p.isCategoryInitial && p.featuredCategoryList.isEmpty) {
      // Handle shimmer loading here (if no categories loaded yet)
      return SizedBox(
        height: 387,
        child: ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
          crossAxisCount: 2,
          aspectRatio: 1,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          item_count: 10,
          mainAxisExtent: 170.0,
        ),
      );
    } else if (p.featuredCategoryList.isNotEmpty) {
      return SizedBox(
        height: 230,
        child: GridView.builder(
          padding: const EdgeInsets.only(
              left: AppDimensions.paddingLarge,
              right: AppDimensions.paddingLarge,
              top: 11,
              bottom: 24),
          scrollDirection: Axis.horizontal,
          itemCount: p.featuredCategoryList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1, // Ensures square boxes
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 170.0),
          itemBuilder: (context, index) {
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CategoryProducts(
                          name: p.featuredCategoryList[index].name ?? '',
                          slug: p.featuredCategoryList[index].slug ?? '',
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusNormal,
                              ),
                              child: FadeInImage.assetNetwork(
                                placeholder: AppImages.placeholder,
                                image:
                                    p.featuredCategoryList[index].coverImage ??
                                        '',
                                fit: BoxFit.cover,
                              ),
                            )),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          p.featuredCategoryList[index].name ?? '',
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
        ),
      );
    } else if (!p.isCategoryInitial && p.featuredCategoryList.isEmpty) {
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
