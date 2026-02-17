import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../helpers/grid_responsive.dart';
import '../../repositories/auction_products_repository.dart';

class AuctionProducts extends StatefulWidget {
  const AuctionProducts({
    Key? key,
  }) : super(key: key);

  @override
  _AuctionProductsState createState() => _AuctionProductsState();
}

class _AuctionProductsState extends State<AuctionProducts> {
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _xcrollController = ScrollController();

  //init
  bool _dataFetch = false;
  final List<dynamic> _auctionProductItems = [];
  int _page = 1;
  int? _totalData = 0;

  bool _showLoadingContainer = false;

  @override
  void initState() {
    super.initState();
    fetchData();

    _xcrollController.addListener(() {
      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
          _showLoadingContainer = true;
        });
        fetchData();
      }
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  reset() {
    _dataFetch = false;
    _auctionProductItems.clear();
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    setState(() {});
  }

  fetchData() async {
    final auctionProductResponse =
        await AuctionProductsRepository().getAuctionProducts(page: _page);
    _auctionProductItems.addAll(auctionProductResponse.products!);
    _totalData = auctionProductResponse.meta!.total;
    _dataFetch = true;
    _showLoadingContainer = false;

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
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        body: Stack(
          children: [
            body(),
            Align(
                alignment: Alignment.bottomCenter,
                child: buildLoadingContainer())
          ],
        ),
      ),
    );
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _auctionProductItems.length
            ? 'no_more_products_ucf'.tr(context: context)
            : 'loading_more_products_ucf'.tr(context: context)),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: MyTheme.mainColor,
      centerTitle: false,
      leading: UsefulElements.backButton(),
      title: Text(
        'auction_product_screen_title'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget body() {
    final int crossProducts = GridResponsive.columnsForWidth(context);
    if (!_dataFetch) {
      return ShimmerHelper().buildProductGridShimmer(
        scontroller: _mainScrollController,
        crossAxisCount: crossProducts,
      );
    }

    if (_auctionProductItems.isEmpty) {
      return Center(
        child: Text('no_data_is_available'.tr(context: context)),
      );
    }
    return RefreshIndicator(
      onRefresh: _onPageRefresh,
      child: SingleChildScrollView(
        controller: _xcrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: _auctionProductItems.length,
          shrinkWrap: true,
          padding:
              const EdgeInsets.only(top: 0.0, bottom: 10, left: 18, right: 18),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // 3
            return ProductCard(
                identifier: 'auction',
                id: _auctionProductItems[index].id,
                slug: _auctionProductItems[index].slug,
                image: _auctionProductItems[index].thumbnail_image,
                name: _auctionProductItems[index].name,
                main_price: _auctionProductItems[index].main_price,
                stroked_price: _auctionProductItems[index].stroked_price,
                isWholesale: false,
                // discount: _auctionlProductItems[index].discount,
                has_discount: false);
          },
        ),
      ),
    );
  }
}
