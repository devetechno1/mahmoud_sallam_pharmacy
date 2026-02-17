import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/product_mini_response.dart';

import '../../../../app_config.dart';
import '../../../../custom/featured_products/product_vertical_list_widget.dart';

class CustomVerticalProductsListSectionWidget extends StatelessWidget {
  const CustomVerticalProductsListSectionWidget({
    super.key,
    required this.title,
    required this.isProductInitial,
    required this.productList,
    required this.numberOfTotalProducts,
    required this.onArriveTheEndOfList,
    this.priceTextStyle,
    this.nameTextStyle,
  });

  final String title;
  final bool isProductInitial;
  final List<Product> productList;

  final int numberOfTotalProducts;
  final void Function() onArriveTheEndOfList;
  final TextStyle? priceTextStyle;
  final TextStyle? nameTextStyle;
  @override
  Widget build(BuildContext context) {
    if (!isProductInitial && productList.isEmpty) return emptyWidget;
    return Container(
      width: double.maxFinite,
      margin:
          const EdgeInsets.only(top: AppDimensions.paddingSupSmall, bottom: 5),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 20,
              start: 20,
              bottom: 10,
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xff000000),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ProductVerticalListWidget(
            isProductInitial: isProductInitial,
            productList: productList,
            numberOfTotalProducts: numberOfTotalProducts,
            onArriveTheEndOfList: onArriveTheEndOfList,
            nameTextStyle: nameTextStyle,
            priceTextStyle: priceTextStyle,
          ),
        ],
      ),
    );
  }
}
