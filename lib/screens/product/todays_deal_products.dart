import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/product_mini_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/product_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../app_config.dart';
import '../../helpers/grid_responsive.dart';

class TodaysDealProducts extends StatefulWidget {
  @override
  _TodaysDealProductsState createState() => _TodaysDealProductsState();
}

class _TodaysDealProductsState extends State<TodaysDealProducts> {
  ScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        body: buildProductList(context),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
              app_language_rtl.$!
                  ? CupertinoIcons.arrow_right
                  : CupertinoIcons.arrow_left,
              color: MyTheme.dark_grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'todays_deal_ucf'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  FutureBuilder<ProductMiniResponse> buildProductList(context) {
     final   int  cross = GridResponsive.columnsForWidth(context);
    return FutureBuilder(
      future: ProductRepository().getTodaysDealProducts(),
      builder: (context, AsyncSnapshot<ProductMiniResponse> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return emptyWidget;
          } else if (snapshot.data!.products!.isEmpty) {
            return Container(
              child: Center(
                  child: Text(
                'no_data_is_available'.tr(context: context),
              )),
            );
          } else if (snapshot.hasData) {
            final productResponse = snapshot.data;
            return SingleChildScrollView(
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                itemCount: productResponse!.products!.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(
                    top: AppDimensions.paddingLarge,
                    bottom: AppDimensions.paddingSupSmall,
                    left: 18,
                    right: 18),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ProductCard(
                    id: productResponse.products![index].id,
                    slug: productResponse.products![index].slug!,
                    image: productResponse.products![index].thumbnail_image,
                    name: productResponse.products![index].name,
                    main_price: productResponse.products![index].main_price,
                    stroked_price:
                        productResponse.products![index].stroked_price,
                    has_discount:
                        productResponse.products![index].has_discount!,
                    discount: productResponse.products![index].discount,
                    isWholesale: productResponse.products![index].isWholesale,
                  );
                },
              ),
            );
          }
        }

        return ShimmerHelper()
            .buildProductGridShimmer(
              crossAxisCount: cross,
              scontroller: _scrollController);
      },
    );
  }
}
