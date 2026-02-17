import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app_config.dart';
import '../../../../data_model/product_mini_response.dart';
import '../../../../presenter/home_provider.dart';
import 'custom_vertical_products.dart';

class VerticalProductsSectionSliver extends StatelessWidget {
  const VerticalProductsSectionSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<
          HomeProvider,
          ({
            bool isFeaturedProductInitial,
            UnmodifiableListView<Product> featuredProductList,
            int totalFeaturedProductData
          })>(
        selector: (_, provider) => (
          isFeaturedProductInitial: provider.isFeaturedProductInitial,
          featuredProductList: UnmodifiableListView(provider.featuredProductList),
          totalFeaturedProductData: provider.totalFeaturedProductData
        ),
        builder: (context, s, child) {
          if (!s.isFeaturedProductInitial && s.featuredProductList.isEmpty)
            return emptyWidget;
          return CustomVerticalProductsListSectionWidget(
            title: 'featured_products_ucf'.tr(context: context),
            isProductInitial: s.isFeaturedProductInitial,
            productList: s.featuredProductList,
            numberOfTotalProducts: s.totalFeaturedProductData,
            onArriveTheEndOfList:
                context.read<HomeProvider>().fetchFeaturedProducts,
          );
        },
      ),
    );
  }
}
