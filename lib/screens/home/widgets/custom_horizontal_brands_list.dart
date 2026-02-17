import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/brands_horizontal_list_widget.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/brand_response.dart';
import 'package:flutter/material.dart';

class CustomHorizontalBrandsListSectionWidget extends StatelessWidget {
  const CustomHorizontalBrandsListSectionWidget({
    super.key,
    required this.title,
    required this.isBrandsInitial,
    required this.brandsList,
    required this.numberOfTotalBrands,
    required this.onArriveTheEndOfList,
    this.priceTextStyle,
    this.nameTextStyle,
  });

  final String title;
  final bool isBrandsInitial;
  final List<Brands> brandsList;

  final int numberOfTotalBrands;
  final void Function() onArriveTheEndOfList;
  final TextStyle? priceTextStyle;
  final TextStyle? nameTextStyle;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 305,
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
          Flexible(
            child: BrandHorizontalListWidget(
              isBrandsInitial: isBrandsInitial,
              brandsList: brandsList,
              numberOfTotalBrands: numberOfTotalBrands,
              onArriveTheEndOfList: onArriveTheEndOfList,
            ),
          ),
        ],
      ),
    );
  }
}
