import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import '../../custom/toast_component.dart';
import '../../data_model/product_mini_response.dart';
import '../../helpers/grid_responsive.dart';
import '../../helpers/shared_value_helper.dart';
import '../../helpers/shimmer_helper.dart';
import '../../my_theme.dart';
import '../../repositories/coupon_repository.dart';
import '../../ui_elements/product_card.dart';

class CouponProducts extends StatefulWidget {
  final String? code;
  final int? id;

  const CouponProducts({
    Key? key,
    this.code,
    this.id,
  }) : super(key: key);

  @override
  State<CouponProducts> createState() => _CouponProductsState();
}

class _CouponProductsState extends State<CouponProducts> {
  ScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          (app_language_rtl.$ ?? false) ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context, widget.code),
        body: buildCouponProductList(context),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context, String? code) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
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
      title: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              code ?? 'no_code'.tr(context: context),
              style: const TextStyle(
                  fontSize: 16,
                  color: MyTheme.dark_font_grey,
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                if (code != null) {
                  Clipboard.setData(ClipboardData(text: code)).then((_) {
                    ToastComponent.showDialog(
                      'copied_ucf'.tr(context: context),
                    );
                  });
                }
              },
              icon: const Icon(
                color: Colors.black,
                Icons.copy,
                size: 18.0,
              ),
            ),
          ],
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  FutureBuilder<ProductMiniResponse> buildCouponProductList(context) {
    final int cross = GridResponsive.columnsForWidth(context);
    return FutureBuilder(
        future: CouponRepository().getCouponProductList(id: widget.id),
        builder: (context, AsyncSnapshot<ProductMiniResponse> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('an_error_occurred'.tr(context: context)));
          } else if (snapshot.hasData) {
            final productResponse = snapshot.data;
            if (productResponse?.products == null ||
                productResponse!.products!.isEmpty) {
              return Center(
                  child: Text('no_products_found'.tr(context: context)));
            }
            return SingleChildScrollView(
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                itemCount: productResponse.products!.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(
                    top: AppDimensions.paddingLarge,
                    bottom: AppDimensions.paddingSupSmall,
                    left: 18,
                    right: 18),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final product = productResponse.products![index];
                  return ProductCard(
                    id: product.id,
                    slug: product.slug ?? 'no-slug',
                    image: product.thumbnail_image,
                    name: product.name ?? 'Unnamed Product',
                    main_price: product.main_price ?? '0',
                    stroked_price: product.stroked_price,
                    has_discount: product.has_discount ?? false,
                    discount: product.discount,
                    isWholesale: product.isWholesale ?? false,
                  );
                },
              ),
            );
          } else {
            return ShimmerHelper().buildProductGridShimmer(
                crossAxisCount: cross, scontroller: _scrollController);
          }
        });
  }
}
