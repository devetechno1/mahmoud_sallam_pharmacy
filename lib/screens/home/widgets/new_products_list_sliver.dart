import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:provider/provider.dart';
import '../../../app_config.dart';
import '../../../data_model/product_mini_response.dart';
import '../../../presenter/home_provider.dart';
import '../../product/featured_products.dart';
import '../../product/new_products.dart';
import 'featured_products/custom_horizontal_products_list_widget.dart';

// TODO:# change to new products not featured

class NewProductsListSliver extends StatelessWidget {
  const NewProductsListSliver({super.key});

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
                isFeaturedProductInitial: p.isFeaturedProductInitial,
                featuredProductList: UnmodifiableListView(p.featuredProductList),
                totalFeaturedProductData: p.totalFeaturedProductData,
              ),
          builder: (context, s, child) {
            if (!s.isFeaturedProductInitial && s.featuredProductList.isEmpty)
              return emptyWidget;
            return CustomHorizontalProductsListSectionWidget(
              onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewProducts(),
                ),
              )
            },
              title: 'new_products'.tr(context: context),
              isProductInitial: s.isFeaturedProductInitial,
              productList: s.featuredProductList,
              numberOfTotalProducts: s.totalFeaturedProductData,
              onArriveTheEndOfList:
                  context.read<HomeProvider>().fetchFeaturedProducts,
              //  nameTextStyle: ,
              //pricesTextStyle:
            );
          }),
    );
  }
}
