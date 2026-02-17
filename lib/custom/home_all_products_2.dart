import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../constants/app_dimensions.dart';
import '../data_model/product_mini_response.dart';
import '../helpers/grid_responsive.dart';
import '../helpers/shimmer_helper.dart';
import '../presenter/home_provider.dart';
import '../ui_elements/product_card_black.dart';

class HomeAllProductsSliver extends StatelessWidget {
  const HomeAllProductsSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: AppDimensions.paddingLarge,
        bottom: AppDimensions.paddingSupSmall,
        left: AppDimensions.paddingMedium,
        right: AppDimensions.paddingMedium,
      ),
      sliver: _slivers(context),
    );
  }

  RenderObjectWidget _slivers(BuildContext context) {
    final ({
      List<Product> allProductList,
      bool isAllProductInitial,
      int totalAllProductData
    }) data = context.select<
        HomeProvider,
        ({
          UnmodifiableListView<Product> allProductList,
          int totalAllProductData,
          bool isAllProductInitial
        })>(
      (data) => (
        allProductList: UnmodifiableListView(data.allProductList),
        totalAllProductData: data.totalAllProductData,
        isAllProductInitial: data.isAllProductInitial,
      ),
    );
    final cross = GridResponsive.columnsForWidth(context);

    if (data.isAllProductInitial) {
      return ShimmerHelper()
          .buildProductSliverGridShimmer(crossAxisCount: cross);
    } else if (data.allProductList.isNotEmpty) {
      final bool isLoadingMore =
          data.allProductList.length < data.totalAllProductData;
      return SliverMasonryGrid.count(
          crossAxisCount: cross,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childCount: isLoadingMore
              ? data.allProductList.length + 2
              : data.allProductList.length,
          itemBuilder: (context, index) {
            if (index > data.allProductList.length - 1) {
              return ShimmerHelper().buildBasicShimmer(height: 200);
            }
            return ProductCardBlack(
              id: data.allProductList[index].id,
              slug: data.allProductList[index].slug ?? '',
              image: data.allProductList[index].thumbnail_image,
              name: data.allProductList[index].name,
              main_price: data.allProductList[index].main_price,
              stroked_price: data.allProductList[index].stroked_price,
              has_discount: data.allProductList[index].has_discount == true,
              discount: data.allProductList[index].discount,
              isWholesale: data.allProductList[index].isWholesale,
              flatdiscount: data.allProductList[index].flatdiscount,
            );
          });
    } else if (data.totalAllProductData == 0) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text('no_product_is_available'.tr(context: context)),
        ),
      );
    } else {
      return const SliverToBoxAdapter(); // should never be happening
    }
  }
}
