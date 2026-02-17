import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/product_card.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../custom/useful_elements.dart';
import '../../helpers/grid_responsive.dart';
import '../../helpers/shared_value_helper.dart';
import '../../helpers/shimmer_helper.dart';
import '../../my_theme.dart';

class LastViewProduct extends StatefulWidget {
  const LastViewProduct({Key? key}) : super(key: key);

  @override
  State<LastViewProduct> createState() => _LastViewProductState();
}

class _LastViewProductState extends State<LastViewProduct> {
  //init
  bool _dataFetch = false;
  final dynamic _lastViewProducts = [];
  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  reset() {
    _dataFetch = false;
    _lastViewProducts.clear();
    setState(() {});
  }

  fetchData() async {
    final lastViewProductResponse = await ProductRepository().lastViewProduct();

    _lastViewProducts.addAll(lastViewProductResponse.products);
    _dataFetch = true;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: body(),
      ),
    );
  }

  Widget body() {
     final   int  cross = GridResponsive.columnsForWidth(context);
    if (!_dataFetch) {
      return ShimmerHelper()
          .buildProductGridShimmer(
            crossAxisCount: cross,
            scontroller: _mainScrollController);
    }

    if (_lastViewProducts.length == 0) {
      return Center(
        child: Text('no_data_is_available'.tr(context: context)),
      );
    }
    return RefreshIndicator(
      onRefresh: _onPageRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: _lastViewProducts.length,
          shrinkWrap: true,
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingSupSmall,
              bottom: AppDimensions.paddingSupSmall,
              left: 18,
              right: 18),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // 3
            return ProductCard(
              id: _lastViewProducts[index].id,
              slug: _lastViewProducts[index].slug,
              image: _lastViewProducts[index].thumbnail_image,
              name: _lastViewProducts[index].name,
              main_price: _lastViewProducts[index].main_price,
              stroked_price: _lastViewProducts[index].stroked_price,
              has_discount: _lastViewProducts[index].has_discount,
              discount: _lastViewProducts[index].discount,
              isWholesale: _lastViewProducts[index].isWholesale,
              flatdiscount: _lastViewProducts[index].flatdiscount,
            );
          },
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: UsefulElements.backButton(),
      title: Text(
        'last_view_product_ucf'.tr(context: context),
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
