import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../app_config.dart';
import '../helpers/grid_responsive.dart';
import '../helpers/shared_value_helper.dart';
import '../helpers/shimmer_helper.dart';
import '../my_theme.dart';
import '../repositories/product_repository.dart';
import '../ui_elements/product_card.dart';

class InhouseProducts extends StatefulWidget {
  const InhouseProducts({Key? key}) : super(key: key);

  @override
  State<InhouseProducts> createState() => _InhouseProductsState();
}

class _InhouseProductsState extends State<InhouseProducts> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _xcrollController = ScrollController();

  final List<dynamic> _inhouseProductList = [];
  bool _isFetch = true;
  int _page = 1;
  int? _totalData = 0;
  bool _showLoadingContainer = false;

  fetchData() async {
    final productResponse =
        await ProductRepository().getInHouseProducts(page: _page);
    _inhouseProductList.addAll(productResponse.products!);
    _isFetch = false;
    _totalData = productResponse.meta!.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  reset() {
    _inhouseProductList.clear();
    _isFetch = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();

    _xcrollController.addListener(() {
      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
        });
        _showLoadingContainer = true;
        fetchData();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: Stack(
          children: [
            buildInhouserProductList(context),
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
        child: Text(_totalData == _inhouseProductList.length
            ? 'no_more_products_ucf'.tr(context: context)
            : 'loading_more_products_ucf'.tr(context: context)),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
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
        'in_house_products_ucf'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget buildInhouserProductList(context) {
    final int cross = GridResponsive.columnsForWidth(context);
    if (_isFetch && _inhouseProductList.isEmpty) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildProductGridShimmer(crossAxisCount: cross , scontroller: _scrollController));
    } else if (_inhouseProductList.isNotEmpty) {
      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        displacement: 0,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          controller: _xcrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: MasonryGridView.count(
            crossAxisCount: cross,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            itemCount: _inhouseProductList.length,
            shrinkWrap: true,
            padding: const EdgeInsets.only(
                top: AppDimensions.paddingLarge,
                bottom: AppDimensions.paddingSupSmall,
                left: 18,
                right: 18),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ProductCard(
                id: _inhouseProductList[index].id,
                slug: _inhouseProductList[index].slug,
                image: _inhouseProductList[index].thumbnail_image,
                name: _inhouseProductList[index].name,
                main_price: _inhouseProductList[index].main_price,
                stroked_price: _inhouseProductList[index].stroked_price,
                has_discount: _inhouseProductList[index].has_discount,
                discount: _inhouseProductList[index].discount,
                isWholesale: _inhouseProductList[index].isWholesale,
              );
            },
          ),
        ),
      );
    } else if (_totalData == 0) {
      return Center(child: Text('no_data_is_available'.tr(context: context)));
    } else {
      return emptyWidget; // should never be happening
    }
  }
}
