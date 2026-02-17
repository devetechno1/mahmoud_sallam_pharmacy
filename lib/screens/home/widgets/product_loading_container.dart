import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:provider/provider.dart';

import '../../../app_config.dart';
import '../../../data_model/product_mini_response.dart';

class ProductLoadingContainer extends StatelessWidget {
  const ProductLoadingContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final int? totalAllProductData =
        context.select<HomeProvider, int?>((p) => p.totalAllProductData);
    final List<Product> allProductList =
        context.select<HomeProvider, UnmodifiableListView<Product>>(
            (value) => UnmodifiableListView(value.allProductList));
    final bool showAllLoadingContainer = context.select<HomeProvider, bool>(
      (p) => p.showAllLoadingContainer,
    );

    if (totalAllProductData != allProductList.length) {
      return emptyWidget;
    }
    return Container(
      height: showAllLoadingContainer ? 40 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(child: Text('no_more_products_ucf'.tr(context: context))),
    );
  }
}
