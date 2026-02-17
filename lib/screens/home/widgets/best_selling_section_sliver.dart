import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/featured_products/custom_horizontal_products_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:provider/provider.dart';

import '../../../app_config.dart';
import '../../../data_model/product_mini_response.dart';
import '../../../presenter/home_provider.dart';
import '../../product/top_selling_products.dart';

class BestSellingSectionSliver extends StatelessWidget {
  const BestSellingSectionSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<
          HomeProvider,
          ({
            bool isBestSellingProductInitial,
            UnmodifiableListView<Product> bestSellingProductList,
            int totalBestSellingProductData,
          })>(
        selector: (_, p) => (
          isBestSellingProductInitial: p.isBestSellingProductInitial,
          bestSellingProductList: UnmodifiableListView(p.bestSellingProductList),
          totalBestSellingProductData: p.totalBestSellingProductData,
        ),
        builder: (context, p, child) {
          if (!p.isBestSellingProductInitial &&
              p.bestSellingProductList.isEmpty) return emptyWidget;
          return CustomHorizontalProductsListSectionWidget(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TopSellingProducts(),
                ),
              )
            },
            title: 'best_selling'.tr(context: context),
            isProductInitial: p.isBestSellingProductInitial,
            productList: p.bestSellingProductList,
            numberOfTotalProducts: p.totalBestSellingProductData,
            onArriveTheEndOfList:
                context.read<HomeProvider>().fetchBestSellingProducts,
          );
        },
      ),
    );
  }
}
