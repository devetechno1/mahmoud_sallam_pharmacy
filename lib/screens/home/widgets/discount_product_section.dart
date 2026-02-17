import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/featured_products/custom_horizontal_products_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:provider/provider.dart';

import '../../../app_config.dart';
import '../../../data_model/product_mini_response.dart';
import '../../../presenter/home_provider.dart';
import '../../product/discounted_products.dart';

class DiscountProductSectionSliver extends StatelessWidget {
  const DiscountProductSectionSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<
          HomeProvider,
          ({
            bool isBestSellingProductInitial,
            UnmodifiableListView<Product> discountedProductList,
            int totalBestSellingProductData,
          })>(
        selector: (_, p) => (
          isBestSellingProductInitial: p.isBestSellingProductInitial,
          discountedProductList: UnmodifiableListView(p.discountedProductList),
          totalBestSellingProductData: p.totalBestSellingProductData,
        ),
        builder: (context, p, child) {
          if (!p.isBestSellingProductInitial &&
              p.discountedProductList.isEmpty) return emptyWidget;
          return CustomHorizontalProductsListSectionWidget(
                     onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiscountedProducts(),
                ),
              )
            },
            title: 'discount_products'.tr(context: context),
            isProductInitial: p.isBestSellingProductInitial,
            productList: p.discountedProductList,
            numberOfTotalProducts: p.totalBestSellingProductData,
            onArriveTheEndOfList:
                context.read<HomeProvider>().fetchDiscountProducts,
          );
        },
      ),
    );
  }
}
