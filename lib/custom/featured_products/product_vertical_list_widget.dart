import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../app_config.dart';
import '../../helpers/shimmer_helper.dart';
import '../../ui_elements/mini_product_card.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/product_mini_response.dart';

class ProductVerticalListWidget extends StatelessWidget {
  final bool isProductInitial;
  final List<Product> productList;
  final int numberOfTotalProducts;
  final void Function() onArriveTheEndOfList;
  final TextStyle? priceTextStyle;
  final TextStyle? nameTextStyle;

  const ProductVerticalListWidget({
    Key? key,
    required this.isProductInitial,
    required this.productList,
    required this.numberOfTotalProducts,
    required this.onArriveTheEndOfList,
    this.priceTextStyle,
    this.nameTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const itemWidth = 160.0;
    if (isProductInitial && productList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            // maxCrossAxisExtent: itemWidth,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.55,
          ),
          itemBuilder: (context, index) => ShimmerHelper().buildBasicShimmer(
            height: 180.0,
            width: itemWidth,
          ),
        ),
      );
    } else if (productList.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: numberOfTotalProducts > productList.length
              ? productList.length + 1
              : productList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            // maxCrossAxisExtent: itemWidth,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.55,
          ),
          itemBuilder: (context, index) {
            if (index == productList.length &&
                numberOfTotalProducts > productList.length) {
              onArriveTheEndOfList();
              return Center(
                child: SpinKitFadingFour(
                  size: 30.0,
                  itemBuilder: (BuildContext context, int index) {
                    return const DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white),
                    );
                  },
                ),
              );
            }

            return MiniProductCard(
              id: productList[index].id,
              slug: productList[index].slug ?? '',
              image: productList[index].thumbnail_image,
              name: productList[index].name,
              main_price: productList[index].main_price,
              stroked_price: productList[index].stroked_price,
              has_discount: productList[index].has_discount,
              isWholesale: productList[index].isWholesale,
              priceTextStyle: priceTextStyle,
              nameTextStyle: nameTextStyle,
            );
          },
        ),
      );
    } else {
      return emptyWidget;
    }
  }
}
