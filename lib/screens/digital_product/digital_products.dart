import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';

import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auction/auction_products_details.dart';

import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../helpers/grid_responsive.dart';
import '../product/product_details.dart';

class DigitalProducts extends StatefulWidget {
  const DigitalProducts({
    Key? key,
  }) : super(key: key);

  @override
  _DigitalProductsState createState() => _DigitalProductsState();
}

class _DigitalProductsState extends State<DigitalProducts> {
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _xcrollController = ScrollController();

  //init
  bool _dataFetch = false;
  final List<dynamic> _digitalProducts = [];
  int _page = 1;
  int? _totalData = 0;

  bool _showLoadingContainer = false;

  @override
  void initState() {
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
    super.initState();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  reset() {
    _dataFetch = false;
    _digitalProducts.clear();
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    setState(() {});
  }

  fetchData() async {
    final digitalProductRes =
        await ProductRepository().getDigitalProducts(page: _page);

    _digitalProducts.addAll(digitalProductRes.products!);
    _totalData = digitalProductRes.meta!.total;
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
                child: buildLoadingContainer(),
              )
            ],
          )),
    );
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _digitalProducts.length
            ? 'no_more_products_ucf'.tr(context: context)
            : 'loading_more_products_ucf'.tr(context: context)),
      ),
    );
  }

  bool? shouldProductBoxBeVisible(productName, searchKey) {
    if (searchKey == "") {
      return true; //do not check if the search key is empty
    }
    return StringHelper().stringContains(productName, searchKey);
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: MyTheme.mainColor,
      centerTitle: false,
      leading: UsefulElements.backButton(),
      title: Padding(
        padding: const EdgeInsetsDirectional.only(end: 37),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'digital_product_ucf'.tr(context: context),
              style: const TextStyle(
                  fontSize: 16,
                  color: MyTheme.dark_font_grey,
                  fontWeight: FontWeight.bold),
            ),
            // GestureDetector(
            //   onTap: () {},
            //   child: Image.asset(
            //     'assets/search.png',
            //     height: 20,
            //   ),
            // ),
          ],
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget body() {
    final int cross = GridResponsive.columnsForWidth(context);
    if (!_dataFetch) {
      return ShimmerHelper().buildProductGridShimmer(
          crossAxisCount: cross, scontroller: _mainScrollController);
    }

    if (_digitalProducts.isEmpty) {
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
          mainAxisSpacing: 10,
          crossAxisSpacing: 14,
          itemCount: _digitalProducts.length,
          shrinkWrap: true,
          padding:
              const EdgeInsets.only(top: 0.0, bottom: 10, left: 18, right: 18),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // 3
            return DigitalProductCard(
              id: _digitalProducts[index].id,
              slug: _digitalProducts[index].slug,
              image: _digitalProducts[index].thumbnail_image,
              name: _digitalProducts[index].name,
              main_price: _digitalProducts[index].main_price,
              stroked_price: _digitalProducts[index].stroked_price,
              has_discount: _digitalProducts[index].has_discount,
              discount: _digitalProducts[index].discount,
              isWholesale: null,
            );
          },
        ),
      ),
    );
  }
}

class DigitalProductCard extends StatefulWidget {
  final dynamic identifier;
  final int? id;
  final String slug;
  final String? image;
  final String? name;
  final String? main_price;
  final String? stroked_price;
  final bool has_discount;
  final bool? isWholesale;
  final String? discount;

  const DigitalProductCard({
    Key? key,
    this.identifier,
    required this.slug,
    this.id,
    this.image,
    this.name,
    this.main_price,
    this.stroked_price,
    this.has_discount = false,
    bool? isWholesale = false, // Corrected to use isWholesale
    this.discount,
  })  : isWholesale = isWholesale, // Assigning isWholesale to isWholesale
        super(key: key);

  @override
  _DigitalProductCardState createState() => _DigitalProductCardState();
}

class _DigitalProductCardState extends State<DigitalProductCard> {
  @override
  Widget build(BuildContext context) {
    debugPrint(
        'Wholesale status: ${widget.isWholesale}'); // Debug print to check wholesale status
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return widget.identifier == 'auction'
                  ? AuctionProductsDetails(slug: widget.slug)
                  : ProductDetails(slug: widget.slug);
            },
          ),
        );
      },
      child: Container(
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(children: [
                    Container(
                      width: double.infinity,
                      child: ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusNormal),
                        child: FadeInImage.assetNetwork(
                          placeholder: AppImages.placeholder,
                          image: widget.image ?? AppImages.placeholder,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    //    if (whole_sale_addon_installed.$ && widget.isWholesale !)
                    if ((whole_sale_addon_installed.$) &&
                        (widget.isWholesale ?? false))
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: const BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  AppDimensions.radiusHalfSmall),
                              bottomLeft: Radius.circular(
                                  AppDimensions.radiusHalfSmall),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x14000000),
                                offset: Offset(-1, 1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            'wholesale'.tr(context: context),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.8,
                            ),
                            textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false),
                            softWrap: false,
                          ),
                        ),
                      ),
                  ]),
                ),
                Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          widget.name ?? 'no_name'.tr(context: context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      if (widget.has_discount)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            SystemConfig.systemCurrency != null
                                ? widget.stroked_price?.replaceAll(
                                        SystemConfig.systemCurrency!.code!,
                                        SystemConfig.systemCurrency!.symbol!) ??
                                    ''
                                : widget.stroked_price ?? '',
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: MyTheme.medium_grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 8.0),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          SystemConfig.systemCurrency != null
                              ? widget.main_price?.replaceAll(
                                      SystemConfig.systemCurrency!.code!,
                                      SystemConfig.systemCurrency!.symbol!) ??
                                  ''
                              : widget.main_price ?? '',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.has_discount)
                      Container(
                        height: 20,
                        width: 48,
                        margin: const EdgeInsets.only(
                            top: AppDimensions.paddingSmall,
                            right: AppDimensions.paddingSmall,
                            bottom: 15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusNormal),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              offset: Offset(-1, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.discount ?? '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.8,
                            ),
                            textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false),
                            softWrap: false,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
