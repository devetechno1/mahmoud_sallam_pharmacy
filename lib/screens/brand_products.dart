import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/product_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_config.dart';
import '../custom/paged_view/models/page_result.dart';
import '../custom/paged_view/paged_view.dart';
import '../data_model/product_mini_response.dart';
import '../helpers/shared_value_helper.dart';

class BrandProducts extends StatefulWidget {
  const BrandProducts({Key? key, required this.slug}) : super(key: key);
  final String slug;

  @override
  _BrandProductsState createState() => _BrandProductsState();
}
class _BrandProductsState extends State<BrandProducts> {
  // final ScrollController _scrollController = ScrollController();
  // final ScrollController _xcrollController = ScrollController();

  final PagedViewController<Product> _productsController =
      PagedViewController<Product>();
  final TextEditingController _searchController = TextEditingController();

  // final List<dynamic> _productList = [];
  // bool _isInitial = true;
  // int _page = 1;

  // int? _totalData = 0;
  // bool _showLoadingContainer = false;
  String _searchKey = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // fetchData();

    // _xcrollController.addListener(() {
    //   if (_xcrollController.position.pixels ==
    //       _xcrollController.position.maxScrollExtent) {
    //     setState(() {
    //       _page++;
    //     });
    //     _showLoadingContainer = true;
    //     fetchData();
    //   }
    // });
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   // _scrollController.dispose();
  //   // _xcrollController.dispose();
  //   super.dispose();
  // }

  // Future<void> fetchData() async {
  //   final productResponse = await ProductRepository()
  //       .getBrandProducts(slug: widget.slug, page: _page, name: _searchKey);
  //   _productList.addAll(productResponse.products!);
  //   _isInitial = false;
  //   _totalData = productResponse.meta!.total;
  //   _showLoadingContainer = false;
  //   setState(() {});
  // }
  Future<PageResult<Product>> _fetchProductBrand(int page) async {
    try {
      final ProductMiniResponse res = await ProductRepository()
          .getBrandProducts(slug: widget.slug, page: page, name: _searchKey);
      final List<Product> list = res.products ?? [];
      final bool hasMore = list.isNotEmpty;
      return PageResult<Product>(data: list, hasMore: hasMore);
    } catch (_) {
      return const PageResult<Product>(data: [], hasMore: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.mainColor,
      appBar: buildAppBar(context),
      body: buildProductList(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            app_language_rtl.$!
                ? CupertinoIcons.arrow_right
                : CupertinoIcons.arrow_left,
            color: MyTheme.dark_grey,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Container(
        width: 250,
        child: TextField(
          controller: _searchController,
          onTap: () {},
          onChanged: (txt) {
            final String trimmed = txt.trim();
            if (trimmed == _searchKey) return;
            _searchKey = trimmed;
            if(trimmed.isEmpty){
              _productsController.reset();
            }
          },
          onSubmitted: onSearch,
          autofocus: true,
          decoration: InputDecoration(
              hintText: "${'search_product_here'.tr(context: context)} : ",
              hintStyle: const TextStyle(
                  fontSize: 14.0, color: MyTheme.textfield_grey),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: MyTheme.white, width: 0.0),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: MyTheme.white, width: 0.0),
              ),
              contentPadding: const EdgeInsets.all(0.0)),
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: IconButton(
            icon: const Icon(Icons.search, color: MyTheme.dark_grey),
            onPressed: () => onSearch(_searchController.text),
          ),
        ),
      ],
    );
  }

  void onSearch(String txt) {
    final String trimmed = txt.trim();
    if (trimmed == _searchKey) return;
    _searchKey = trimmed;
    _productsController.reset();
  }

  Widget buildProductList() {
    return PagedView<Product>(
      controller: _productsController,
      fetchPage: _fetchProductBrand,
      layout: PagedLayout.masonry,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      responsiveGrid: false,
      gridCrossAxisCount: 3,
      padding: const EdgeInsets.only(
        top: AppDimensions.paddingDefault,
        bottom: AppDimensions.paddingSupSmall,
        left: AppDimensions.paddingMedium,
        right: AppDimensions.paddingMedium,
      ),
      itemBuilder: (context, product, index) {
        return ProductCard(
          id: product.id,
          slug: product.slug ?? "",
          image: product.thumbnail_image,
          name: product.name,
          main_price: product.main_price,
          stroked_price: product.stroked_price,
          has_discount: product.has_discount == true,
          discount: product.discount,
          isWholesale: product.isWholesale,
          searchedText: _searchKey,
          flatdiscount: product.flatdiscount,
        );
      },
    );
  }
}
