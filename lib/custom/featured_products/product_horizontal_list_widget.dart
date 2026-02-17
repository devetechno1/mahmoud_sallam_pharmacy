import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../app_config.dart';
import '../../helpers/shimmer_helper.dart';
import '../../ui_elements/mini_product_card.dart';

import 'package:active_ecommerce_cms_demo_app/data_model/product_mini_response.dart';

class ProductHorizontalListWidget extends StatelessWidget {
  final bool isProductInitial;
  final List<Product> productList;
  final int numberOfTotalProducts;
  final void Function() onArriveTheEndOfList;
  final TextStyle? priceTextStyle;
  final TextStyle? nameTextStyle;
  const ProductHorizontalListWidget({
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
    if (isProductInitial && productList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
            right: AppDimensions.paddingLarge, left: 20, top: 15),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingDefault),
                  child: ShimmerHelper().buildBasicShimmer(
                      height: 120.0,
                      width: (MediaQuery.sizeOf(context).width - 64) / 3)),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingDefault),
                  child: ShimmerHelper().buildBasicShimmer(
                      height: 120.0,
                      width: (MediaQuery.sizeOf(context).width - 64) / 3)),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingDefault),
                  child: ShimmerHelper().buildBasicShimmer(
                      height: 120.0,
                      width: (MediaQuery.sizeOf(context).width - 160) / 3)),
            ),
          ],
        ),
      );
    } else if (productList.isNotEmpty) {
      return Container(
        // height: 230,
        alignment: Alignment.center,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              if (numberOfTotalProducts > productList.length)
                onArriveTheEndOfList();
            }
            return true;
          },
          child: ListView.separated(
            padding: const EdgeInsets.only(
                right: AppDimensions.paddingLarge, left: 15, top: 10),
            separatorBuilder: (context, index) => const SizedBox(
              width: 12,
            ),
            itemCount: numberOfTotalProducts > productList.length
                ? productList.length + 1
                : productList.length,
            scrollDirection: Axis.horizontal,
            //itemExtent: 135,

            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemBuilder: (context, index) {
              return (index == productList.length)
                  ? SpinKitFadingFour(
                      itemBuilder: (BuildContext context, int index) {
                        return const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                  : MiniProductCard(
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
                      discount: productList[index].discount,
                      flatdiscount: productList[index].flatdiscount,
                    );
            },
          ),
        ),
      );
    } else {
      return emptyWidget;
    }
  }
}
