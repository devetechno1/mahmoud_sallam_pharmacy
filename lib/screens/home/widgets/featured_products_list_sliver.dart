import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_config.dart';
import '../../../data_model/product_mini_response.dart';
import '../../../presenter/home_provider.dart';
import '../../product/featured_products.dart';
import 'featured_products/custom_horizontal_products_list_widget.dart';

class FeaturedProductsListSliver extends StatelessWidget {
  const FeaturedProductsListSliver({super.key});

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
          selector: (_, p) => (
                featuredProductList:
                    UnmodifiableListView(p.featuredProductList),
                isFeaturedProductInitial: p.isFeaturedProductInitial,
                totalFeaturedProductData: p.totalFeaturedProductData,
              ),
          builder: (context, p, child) {
            if (!p.isFeaturedProductInitial && p.featuredProductList.isEmpty)
              return emptyWidget;
            return CustomHorizontalProductsListSectionWidget(
                     onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeaturedProducts(),
                ),
              )
            },
              title: 'featured_products_ucf'.tr(context: context),
              isProductInitial: p.isFeaturedProductInitial,
              productList: p.featuredProductList,
              numberOfTotalProducts: p.totalFeaturedProductData,
              onArriveTheEndOfList:
                  context.read<HomeProvider>().fetchFeaturedProducts,
            );
          }),
    );
  }
}
