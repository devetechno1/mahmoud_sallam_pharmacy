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

import '../../custom/paged_view/models/page_result.dart';
import '../../custom/paged_view/paged_view.dart';

class FeaturedProducts extends StatefulWidget {
  @override
  _FeaturedProductsState createState() => _FeaturedProductsState();
}

class _FeaturedProductsState extends State<FeaturedProducts> {
Future<PageResult<Product>> _fetchProducts(int page ) async {
  final res = await ProductRepository().getFeaturedProducts(page: page,paginate: "");
        if (res.success != true) throw "Not Success";

  final list = res.products ?? [];
  final hasMore = list.isNotEmpty; 
  return PageResult<Product>(data: list, hasMore: hasMore);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.mainColor,
      appBar: buildAppBar(context),
      body: PagedView<Product>(
        fetchPage: _fetchProducts,
        layout: PagedLayout.masonry,
        gridCrossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        padding: const EdgeInsets.only(
          top: AppDimensions.paddingLarge,
          bottom: AppDimensions.paddingSupSmall,
          left: 18,
          right: 18,
        ),
        itemBuilder: (context, product, index) {
          return ProductCard(
            id: product.id,
            slug: product.slug!,
            image: product.thumbnail_image,
            name: product.name,
            main_price: product.main_price,
            stroked_price: product.stroked_price,
            has_discount: product.has_discount!,
            discount: product.discount,
            isWholesale: product.isWholesale,
            flatdiscount: product.flatdiscount,
          );
        },
        loadingItemBuilder: (_, index) {
          return ShimmerHelper.loadingItemBuilder(index);
        },
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor, scrolledUnderElevation: 0.0,
      // centerTitle: true,
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
        'featured_products_ucf'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
