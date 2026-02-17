import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/text_styles.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/classified_ads_details_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/classified_ads_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/screens/brand_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/common_webview_screen.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/classified_product_mini_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../repositories/classified_product_repository.dart';

class ClassifiedAdsDetails extends StatefulWidget {
  final String? slug;

  const ClassifiedAdsDetails({Key? key, required this.slug}) : super(key: key);

  @override
  _ClassifiedAdsDetailsState createState() => _ClassifiedAdsDetailsState();
}

class _ClassifiedAdsDetailsState extends State<ClassifiedAdsDetails>
    with TickerProviderStateMixin {
  bool _showCopied = false;
  bool showPhone = false;
  int _currentImage = 0;
  final ScrollController _mainScrollController =
      ScrollController(initialScrollOffset: 0.0);

  final ScrollController _imageScrollController = ScrollController();

  double _scrollPosition = 0.0;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  //init values

  ClassifiedProductDetailsResponseDatum? _productDetails = null;

  final _productImageList = [];

  double opacity = 0;

  final List<ClassifiedAdsMiniData> _relatedProducts = [];
  bool _relatedProductInit = false;

  @override
  void dispose() {
    _mainScrollController.dispose();
    _imageScrollController.dispose();
    super.dispose();
  }

  void fetchAll() {
    fetchProductDetails();

    fetchRelatedProducts();
  }

  Future<void> fetchProductDetails() async {
    final productDetailsResponse = await ClassifiedProductRepository()
        .getClassifiedProductsDetails(widget.slug);

    if (productDetailsResponse.data!.isNotEmpty) {
      _productDetails = productDetailsResponse.data!.first;
      _productDetails!.photos!.data!.forEach((element) {
        _productImageList.add(element.url);
      });
    }

    setState(() {});
  }

  Future<void> fetchRelatedProducts() async {
    final relatedProductResponse = await ClassifiedProductRepository()
        .getClassifiedOtherAds(slug: widget.slug);

    _relatedProducts.addAll(relatedProductResponse.data!);
    // print(_relatedProducts.length.toString() + "ddd");
    _relatedProductInit = true;

    setState(() {});
  }

  void reset() {
    _currentImage = 0;
    _productImageList.clear();
    _relatedProducts.clear();
    _productDetails = null;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  onCopyTap(setState) {
    setState(() {
      _showCopied = true;
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showCopied = false;
      });
    });
  }

  Future onPressShare(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              contentPadding: const EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75.0,
                          height: 26.0,
                          color: const Color.fromRGBO(253, 253, 253, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSmall),
                              side: const BorderSide(
                                  color: Colors.black, width: 1.0)),
                          child: Text(
                            'copy_product_link_ucf'.tr(context: context),
                            style: const TextStyle(
                              color: MyTheme.medium_grey,
                            ),
                          ),
                          onPressed: () {
                            onCopyTap(setState);
                            // todo:: copy to clip board
                            // Share.(
                            //     text: _productDetails!.link);
                          },
                        ),
                      ),
                      _showCopied
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.paddingSmall),
                              child: Text(
                                'copied_ucf'.tr(context: context),
                                style: const TextStyle(
                                    color: MyTheme.medium_grey, fontSize: 12),
                              ),
                            )
                          : emptyWidget,
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75.0,
                          height: 26.0,
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSmall),
                              side: const BorderSide(
                                  color: Colors.black, width: 1.0)),
                          child: Text(
                            'share_options_ucf'.tr(context: context),
                            style: const TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            // print("share links ${_productDetails!.link}");
                            Share.share(_productDetails!.link!);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: app_language_rtl.$!
                          ? const EdgeInsets.only(
                              left: AppDimensions.paddingSmall)
                          : const EdgeInsets.only(right: 8.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 30,
                        color: const Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSmall),
                            side: const BorderSide(
                                color: MyTheme.font_grey, width: 1.0)),
                        child: Text(
                          'close_all_capital'.tr(context: context),
                          style: const TextStyle(
                            color: MyTheme.font_grey,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  @override
  void initState() {
    _mainScrollController.addListener(() {
      _scrollPosition = _mainScrollController.position.pixels;

      if (_mainScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (100 > _scrollPosition && _scrollPosition > 1) {
          opacity = _scrollPosition / 100;
        }
      }

      if (_mainScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (100 > _scrollPosition && _scrollPosition > 1) {
          opacity = _scrollPosition / 100;

          if (100 > _scrollPosition) {
            opacity = 1;
          }
        }
      }
      // print("opachity{} $_scrollPosition");

      setState(() {});
    });
    fetchAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          extendBody: true,
          body: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            onRefresh: _onPageRefresh,
            child: CustomScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: <Widget>[
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: Colors.white.withValues(alpha: opacity),
                  pinned: true,
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      Builder(
                        builder: (context) => InkWell(
                          onTap: () {
                            return Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecorations
                                .buildCircularButtonDecoration_1(),
                            width: 36,
                            height: 36,
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.arrow_left,
                                color: MyTheme.dark_font_grey,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                          opacity: _scrollPosition > 350 ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                              width: DeviceInfo(context).width! / 1.8,
                              child: Text(
                                "${_productDetails != null ? _productDetails!.name : ''}",
                                style: const TextStyle(
                                    color: MyTheme.dark_font_grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ))),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          onPressShare(context);
                        },
                        child: Container(
                          decoration:
                              BoxDecorations.buildCircularButtonDecoration_1(),
                          width: 36,
                          height: 36,
                          child: const Center(
                            child: Icon(
                              Icons.share_outlined,
                              color: MyTheme.dark_font_grey,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  expandedHeight: 375.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: buildProductSliderImageSection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    //padding: EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecorations.buildBoxDecoration_1(),
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 14, right: 14),
                          child: _productDetails != null
                              ? Text(
                                  _productDetails!.name!,
                                  style: TextStyles.smallTitleTexStyle(),
                                  maxLines: 2,
                                )
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 14, right: 14),
                          child: _productDetails != null
                              ? buildMainPriceRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 14, right: 14),
                          child: _productDetails != null
                              ? buildBrandRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 50.0,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: AppDimensions.paddingNormal),
                          child: _productDetails != null
                              ? buildSellerRow(context)
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 50.0,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 10, right: 14),
                          child: _productDetails != null
                              ? buildLocationContainer(context)
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 14, left: 10, right: 14, bottom: 20),
                          child: _productDetails != null
                              ? buildContractContainer(context)
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: MyTheme.white,
                          margin: const EdgeInsets.only(
                              top: AppDimensions.paddingSupSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  20.0,
                                  16.0,
                                  0.0,
                                ),
                                child: Text(
                                  'description_ucf'.tr(context: context),
                                  style: const TextStyle(
                                      color: MyTheme.dark_font_grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  8.0,
                                  0.0,
                                  8.0,
                                  8.0,
                                ),
                                child: _productDetails != null
                                    ? buildExpandableDescription()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8.0),
                                        child:
                                            ShimmerHelper().buildBasicShimmer(
                                          height: 60.0,
                                        )),
                              ),
                            ],
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/seller-policy",
                                page_name:
                                    'seller_policy_ucf'.tr(context: context),
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'seller_policy_ucf'.tr(context: context),
                                    style: const TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/return-policy",
                                page_name:
                                    'return_policy_ucf'.tr(context: context),
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'return_policy_ucf'.tr(context: context),
                                    style: const TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/support-policy",
                                page_name:
                                    'support_policy_ucf'.tr(context: context),
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'support_policy_ucf'.tr(context: context),
                                    style: const TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                      ]),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18.0,
                        24.0,
                        18.0,
                        0.0,
                      ),
                      child: Text(
                        'other_ads_of_ucf'.tr(context: context) +
                            " " +
                            (_productDetails != null
                                ? _productDetails!.category!
                                : ""),
                        style: const TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                        width: 400,
                        height: 240,
                        child: buildProductsMayLikeList())
                  ]),
                ),
              ],
            ),
          )),
    );
  }

  Widget buildLocationContainer(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 24,
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
            width: DeviceInfo(context).width! / 1.4,
            child: Text(
              _productDetails!.location!,
              maxLines: 1,
              style:
                  const TextStyle(fontSize: 12, color: MyTheme.dark_font_grey),
            ))
      ],
    );
  }

  Widget buildContractContainer(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.phone,
          size: 24,
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
          width: DeviceInfo(context).width! / 2,
          child: InkWell(
            onTap: () {
              showPhone = !showPhone;
              setState(() {});
            },
            child: Text(
              showPhone ? _productDetails!.phone! : "01XXXXXXXXX",
              style:
                  const TextStyle(fontSize: 12, color: MyTheme.dark_font_grey),
            ),
          ),
        ),
        const Spacer(),
        Material(
          elevation: 8,
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(50),
          child: IconButton(
              onPressed: () {
                launchUrl(Uri.parse("tel://${_productDetails!.phone}"));
              },
              icon: const Icon(
                Icons.phone_forwarded,
                color: MyTheme.white,
              )),
        )
      ],
    );
  }

  Row buildMainPriceRow() {
    return Row(
      children: [
        Text(
          _productDetails!.unitPrice!,
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget buildSellerRow(BuildContext context) {
    //print("sl:" +  _productDetails.shop_logo);
    return Container(
      color: MyTheme.light_grey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * (.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('seller_ucf'.tr(context: context),
                    style: const TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1),
                    )),
                Text(
                  _productDetails!.addedBy!,
                  style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTotalPriceRow() {
    return Container(
      height: 40,
      color: MyTheme.amber,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            child: Padding(
              padding: app_language_rtl.$!
                  ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                  : const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 75,
                child: Text(
                  'total_price_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1), fontSize: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: AppDimensions.paddingSmallExtra),
            child: Text(
              _productDetails!.unitPrice!,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Padding buildVariantShimmers() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        0.0,
        8.0,
        0.0,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? buildBrandRow() {
    return _productDetails!.brand!.id! > 0
        ? InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BrandProducts(slug: _productDetails!.brand!.slug!);
              }));
            },
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                      : const EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: 75,
                    child: Text(
                      'brand_ucf'.tr(context: context),
                      style: const TextStyle(
                          color: Color.fromRGBO(
                            153,
                            153,
                            153,
                            1,
                          ),
                          fontSize: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    _productDetails!.brand!.name!,
                    style: const TextStyle(
                        color: MyTheme.font_grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ),
              ],
            ),
          )
        : emptyWidget;
  }

  ExpandableNotifier buildExpandableDescription() {
    return ExpandableNotifier(
        child: ScrollOnExpand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expandable(
            collapsed: Container(
                height: 50, child: Html(data: _productDetails!.description)),
            expanded:
                Container(child: Html(data: _productDetails!.description)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Builder(
                builder: (context) {
                  final controller = ExpandableController.of(context)!;
                  return Btn.basic(
                    child: Text(
                      !controller.expanded
                          ? 'view_more'.tr(context: context)
                          : 'show_less_ucf'.tr(context: context),
                      style: const TextStyle(
                          color: MyTheme.font_grey, fontSize: 11),
                    ),
                    onPressed: () {
                      controller.toggle();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget buildProductsMayLikeList() {
    if (_relatedProductInit == false && _relatedProducts.isEmpty) {
      return Row(
        children: [
          Padding(
              padding: app_language_rtl.$!
                  ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                  : const EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.sizeOf(context).width - 32) / 3)),
          Padding(
              padding: app_language_rtl.$!
                  ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                  : const EdgeInsets.only(right: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.sizeOf(context).width - 32) / 3)),
          Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: ShimmerHelper().buildBasicShimmer(
                  height: 120.0,
                  width: (MediaQuery.sizeOf(context).width - 32) / 3)),
        ],
      );
    } else if (_relatedProductInit && _relatedProducts.isNotEmpty) {
      return SizedBox(
        height: 248,
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(
            width: 16,
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingDefault),
          itemCount: _relatedProducts.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return ClassifiedMiniProductCard(
              id: _relatedProducts[index].id,
              slug: widget.slug,
              image: _relatedProducts[index].thumbnailImage,
              name: _relatedProducts[index].name,
              unitPrice: _relatedProducts[index].unitPrice,
              condition: _relatedProducts[index].condition,
            );
          },
        ),
      );
    } else {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            'no_related_product'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  Future openPhotoDialog(BuildContext context, path) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                child: Stack(
              children: [
                PhotoView(
                  enableRotation: true,
                  heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
                  imageProvider: NetworkImage(path),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: const ShapeDecoration(
                      color: MyTheme.medium_grey_50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppDimensions.radius),
                          bottomRight: Radius.circular(AppDimensions.radius),
                          topRight: Radius.circular(AppDimensions.radius),
                          topLeft: Radius.circular(AppDimensions.radius),
                        ),
                      ),
                    ),
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: const Icon(Icons.clear, color: MyTheme.white),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                ),
              ],
            )),
          );
        },
      );

  Row buildProductImageSection() {
    if (_productImageList.isEmpty) {
      return Row(
        children: [
          Container(
            width: 40,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingSupSmall),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingSupSmall),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingSupSmall),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingSupSmall),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: ShimmerHelper().buildBasicShimmer(
                height: 190.0,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            width: 64,
            child: Scrollbar(
              controller: _imageScrollController,

              // isAlwaysShown: false,
              thickness: 4.0,
              child: Padding(
                padding: app_language_rtl.$!
                    ? const EdgeInsets.only(left: AppDimensions.paddingSmall)
                    : const EdgeInsets.only(right: 8.0),
                child: ListView.builder(
                    itemCount: _productImageList.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final int itemIndex = index;
                      return GestureDetector(
                        onTap: () {
                          _currentImage = itemIndex;
                          print(_currentImage);
                          setState(() {});
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusNormal),
                            border: Border.all(
                                color: _currentImage == itemIndex
                                    ? Theme.of(context).primaryColor
                                    : const Color.fromRGBO(112, 112, 112, .3),
                                width: _currentImage == itemIndex ? 2 : 1),
                            //shape: BoxShape.rectangle,
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusNormal),
                              child:
                                  /*Image.asset(
                                        singleProduct.product_images[index])*/
                                  FadeInImage.assetNetwork(
                                placeholder: AppImages.placeholder,
                                image: _productImageList[index],
                                fit: BoxFit.contain,
                              )),
                        ),
                      );
                    }),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              openPhotoDialog(context, _productImageList[_currentImage]);
            },
            child: Container(
              height: 250,
              width: MediaQuery.sizeOf(context).width - 96,
              child: Container(
                  child: FadeInImage.assetNetwork(
                placeholder: AppImages.placeholderRectangle,
                image: _productImageList[_currentImage],
                fit: BoxFit.scaleDown,
              )),
            ),
          ),
        ],
      );
    }
  }

  Widget buildProductSliderImageSection() {
    if (_productImageList.isEmpty) {
      return ShimmerHelper().buildBasicShimmer(
        height: 190.0,
      );
    } else {
      return CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
            aspectRatio: 355 / 375,
            viewportFraction: 1,
            initialPage: 0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInExpo,
            enlargeCenterPage: false,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              print(index);
              setState(() {
                _currentImage = index;
              });
            }),
        items: _productImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        openPhotoDialog(
                            context, _productImageList[_currentImage]);
                      },
                      child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: i,
                            fit: BoxFit.fitHeight,
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              _productImageList.length,
                              (index) => Container(
                                    width: 7.0,
                                    height: 7.0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImage == index
                                          ? MyTheme.font_grey
                                          : Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ))),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    }
  }

  Widget divider() {
    return Container(
      color: MyTheme.light_grey,
      height: 5,
    );
  }
}
