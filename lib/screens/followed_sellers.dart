import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/followed_sellers_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../custom/box_decorations.dart';
import '../custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import '../custom/style.dart';
import '../custom/toast_component.dart';
import '../helpers/shimmer_helper.dart';
import '../my_theme.dart';
import '../repositories/shop_repository.dart';
import 'seller_details.dart';

class FollowedSellers extends StatefulWidget {
  const FollowedSellers({Key? key}) : super(key: key);

  @override
  State<FollowedSellers> createState() => _FollowedSellersState();
}

class _FollowedSellersState extends State<FollowedSellers> {
  List<SellerInfo> sellers = [];
  int page = 1;
  bool _isShopsInitial = false;
  bool _hasMoreData = true;

  final ScrollController _scrollController = ScrollController();

  Future fetchShopData() async {
    final shopResponse = await ShopRepository().followedList(page: page);
    // print(shopResponse.data!.length);
    sellers.addAll(shopResponse.data!);
    _isShopsInitial = true;
    if (shopResponse.meta!.lastPage == page) {
      _hasMoreData = false;
    }
    setState(() {});
  }

  Future removedFollow(id) async {
    final shopResponse = await ShopRepository().followedRemove(id);

    if (shopResponse.result) {
      reset();
    }
    ToastComponent.showDialog(shopResponse.message);
  }

  clearData() {
    sellers = [];
    page = 1;
    _isShopsInitial = false;
    _hasMoreData = true;
    setState(() {});
  }

  Future reset() async {
    clearData();
    return fetchShopData();
  }

  @override
  void initState() {
    fetchShopData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_hasMoreData) page++;
        // _showLoadingContainer = true;
        fetchShopData();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.mainColor,
      appBar: AppBar(
        title: Text(
          'followed_sellers_ucf'.tr(context: context),
          style: MyStyle.appBarStyle,
        ),
        backgroundColor: MyTheme.mainColor,
        scrolledUnderElevation: 0.0,
        iconTheme: const IconThemeData(color: MyTheme.dark_font_grey),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          //  clearData();
          return reset();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: bodyContainer(),
        ),
      ),
    );
  }

  Widget bodyContainer() {
    if (_isShopsInitial) {
      if (sellers.isNotEmpty)
        return GridView.builder(
          // 2
          //addAutomaticKeepAlives: true,
          itemCount: sellers.length,
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.7),
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingLarge,
              bottom: AppDimensions.paddingSupSmall,
              left: 18,
              right: 18),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            // 3
            return shopModel(sellers[index]);
          },
        );
      else
        return Container(
          height: DeviceInfo(context).height,
          child: Center(
            child: Text('no_data_is_available'.tr(context: context)),
          ),
        );
    } else {
      return buildShimmer();
    }
  }

  Widget shopModel(SellerInfo sellerInfo) {
    return Container(
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SellerDetails(
                    slug: sellerInfo.shopSlug ?? "",
                  );
                }));
              },
              child: Container(
                  width: double.infinity,
                  height: 100,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppDimensions.radiusDefault),
                          bottom: Radius.zero),
                      child: FadeInImage.assetNetwork(
                        placeholder: AppImages.placeholder,
                        image: sellerInfo.shopLogo!,
                        fit: BoxFit.scaleDown,
                        imageErrorBuilder: (BuildContext errorContext,
                            Object obj, StackTrace? st) {
                          return Image.asset(AppImages.placeholder);
                        },
                      ))),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  sellerInfo.shopName!,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                      color: MyTheme.dark_font_grey,
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Container(
                height: 15,
                child: RatingBar(
                    ignoreGestures: true,
                    initialRating:
                        double.parse(sellerInfo.shopRating.toString()),
                    maxRating: 5,
                    direction: Axis.horizontal,
                    itemSize: 15.0,
                    itemCount: 5,
                    ratingWidget: RatingWidget(
                      full: const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      half: const Icon(Icons.star_half),
                      empty: const Icon(Icons.star,
                          color: Color.fromRGBO(224, 224, 225, 1)),
                    ),
                    onRatingUpdate: (newValue) {}),
              ),
            ),
            InkWell(
              onTap: () {
                removedFollow(sellerInfo.shopId);
              },
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'unfollow_ucf'.tr(context: context),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                        color: Color.fromRGBO(230, 46, 4, 1),
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SellerDetails(
                    slug: sellerInfo.shopSlug ?? "",
                  );
                }));
              },
              child: Container(
                  height: 23,
                  width: 103,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber),
                      color: MyTheme.amber,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusHalfSmall)),
                  child: Text(
                    'visit_store_ucf'.tr(context: context),
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w500),
                  )),
            )
          ]),
    );
  }

  Widget buildShimmer() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1,
        crossAxisCount: 3,
      ),
      itemCount: 18,
      padding: const EdgeInsets.only(
          left: AppDimensions.paddingMedium,
          right: AppDimensions.paddingMedium),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecorations.buildBoxDecoration_1(),
          child: ShimmerHelper().buildBasicShimmer(),
        );
      },
    );
  }
}
