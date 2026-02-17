import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/brand_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../app_config.dart';
import '../helpers/shimmer_helper.dart';
import '../ui_elements/mini_product_card.dart';

class BrandHorizontalListWidget extends StatelessWidget {
  final bool isBrandsInitial;
  final List<Brands> brandsList;
  final int numberOfTotalBrands;
  final void Function() onArriveTheEndOfList;
  final TextStyle? priceTextStyle;
  final TextStyle? nameTextStyle;
  const BrandHorizontalListWidget({
    Key? key,
    required this.isBrandsInitial,
    required this.brandsList,
    required this.numberOfTotalBrands,
    required this.onArriveTheEndOfList,
    this.priceTextStyle,
    this.nameTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isBrandsInitial && brandsList.isEmpty) {
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
    } else if (brandsList.isNotEmpty) {
      return Container(
        // height: 230,
        alignment: Alignment.center,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              if (numberOfTotalBrands > brandsList.length)
                onArriveTheEndOfList();
            }
            return true;
          },
          child: ListView.separated(
            padding: const EdgeInsets.only(
                right: AppDimensions.paddingLarge, left: 20, top: 15),
            separatorBuilder: (context, index) => const SizedBox(
              width: 12,
            ),
            itemCount: numberOfTotalBrands > brandsList.length
                ? brandsList.length + 1
                : brandsList.length,
            scrollDirection: Axis.horizontal,
            //itemExtent: 135,

            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            itemBuilder: (context, index) {
              return (index == brandsList.length)
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
                      id: brandsList[index].id,
                      slug: brandsList[index].slug ?? '',
                      image: brandsList[index].logo,
                      name: brandsList[index].name,
                      main_price: brandsList[index].name,
                      priceTextStyle: priceTextStyle,
                      nameTextStyle: nameTextStyle,
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
