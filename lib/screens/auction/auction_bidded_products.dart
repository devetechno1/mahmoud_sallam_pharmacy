import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auction_products_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/checkout/cart.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../../custom/my_widget.dart';
import '../../custom/toast_component.dart';
import '../../custom/useful_elements.dart';
import '../../data_model/auction_bidded_products.dart';
import '../../helpers/main_helpers.dart';
import '../../helpers/shared_value_helper.dart';
import '../../helpers/shimmer_helper.dart';
import '../../my_theme.dart';
import '../../repositories/cart_repository.dart';

class AuctionBiddedProducts extends StatefulWidget {
  const AuctionBiddedProducts({Key? key}) : super(key: key);

  @override
  State<AuctionBiddedProducts> createState() => _AuctionBiddedProductsState();
}

class _AuctionBiddedProductsState extends State<AuctionBiddedProducts> {
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0);
  bool _isDataFetch = false;
  double mHeight = 0.0, mWidht = 0.0;
  int _page = 1;
  bool _showMoreProductLoadingContainer = false;
  List<AuctionBiddedProduct> _biddedList = [];
  resetAll() {
    cleanAll();
    fetchAll();
  }

  cleanAll() {
    _isDataFetch = false;
    _showMoreProductLoadingContainer = false;
    _biddedList = [];
    _page = 1;

    setState(() {});
  }

  getBiddedList() async {
    final biddedResponse =
        await AuctionProductsRepository().getAuctionBiddedProducts(page: _page);
    if (biddedResponse.data!.isEmpty) {
      ToastComponent.showDialog(
        'no_more_products_ucf'.tr(context: context),
      );
    }
    _biddedList.addAll(biddedResponse.data!);
    _showMoreProductLoadingContainer = false;
    _isDataFetch = true;
    setState(() {});
  }

  scrollControllerPosition() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _showMoreProductLoadingContainer = true;
        setState(() {
          _page++;
        });
        getBiddedList();
      }
    });
  }

  fetchAll() {
    getBiddedList();
    setState(() {});
  }

  Future<void> addToCart(id) async {
    final cartAddResponse =
        await CartRepository().getCartAddResponse(id, "", 1);

    if (cartAddResponse.result == false) {
      ToastComponent.showDialog(
        cartAddResponse.message,
      );
      return;
    } else {
      resetAll();
      fetchAll();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const Cart(
          has_bottomnav: false,
        );
      })).then((value) {
        resetAll();
      });
    }
  }

  @override
  void initState() {
    scrollControllerPosition();
    fetchAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: () async {
            resetAll();
            // Future.delayed(Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  child: _isDataFetch
                      ? productsContainer()
                      : ShimmerHelper()
                          .buildListShimmer(item_count: 20, item_height: 80.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget productsContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _biddedList.length + 1,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index == _biddedList.length) {
                return moreProductLoading();
              }
              return auctionProductItem(
                index: index,
                productId: _biddedList[index].id,
                name: _biddedList[index].name,
                imageUrl: _biddedList[index].thumbnailImage,
                myBid: _biddedList[index].myBid,
                highestBid: _biddedList[index].highestBid,
                endDate: _biddedList[index].auctionEndDate,
                action: _biddedList[index].action,
                isBuyable: _biddedList[index].isBuyable,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget auctionProductItem({
    int? index,
    int? productId,
    String? name,
    String? imageUrl,
    String? myBid,
    String? highestBid,
    String? endDate,
    String? action,
    bool? isBuyable,
  }) {
    return MyWidget.customCardView(
      elevation: 5,
      backgroundColor: MyTheme.white,
      height: 140,
      width: mWidht,
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      borderColor: MyTheme.light_grey,
      borderRadius: 6,
      child: Row(
        children: [
          Container(
            child: MyWidget.imageWithPlaceholder(
              width: 84.0,
              height: 140.0,
              fit: BoxFit.fitHeight,
              url: imageUrl!,
              radius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusSmallExtra),
                bottomLeft: Radius.circular(AppDimensions.radiusSmallExtra),
              ),
            ),
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: AppDimensions.paddingSmall,
                  bottom: AppDimensions.paddingSmall,
                  left: AppDimensions.paddingSmall),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 250,
                        ),
                        child: Text(
                          name!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: MyTheme.font_grey,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'auction_my_bid_ucf'.tr(context: context),
                        style: const TextStyle(
                            fontSize: 12,
                            color: MyTheme.font_grey,
                            fontWeight: FontWeight.w400),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppDimensions.paddingDefault),
                            child: Text(convertPrice(myBid!),
                                style: const TextStyle(
                                    fontSize: 12, color: MyTheme.grey_153)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'auction_highest_bid_ucf'.tr(context: context),
                        style: const TextStyle(
                            fontSize: 12,
                            color: MyTheme.font_grey,
                            fontWeight: FontWeight.w400),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppDimensions.paddingDefault),
                            child: Text(convertPrice(highestBid!),
                                style: const TextStyle(
                                    fontSize: 12, color: MyTheme.grey_153)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('auction_end_date_ucf'.tr(context: context),
                          style: const TextStyle(
                              fontSize: 12,
                              color: MyTheme.font_grey,
                              fontWeight: FontWeight.w400)),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppDimensions.paddingDefault),
                            child: Text(endDate!,
                                style: const TextStyle(
                                    fontSize: 12, color: MyTheme.grey_153)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("",
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w400)),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppDimensions.paddingDefault),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: MyTheme.noColor,
                                  backgroundColor: isBuyable!
                                      ? Theme.of(context).primaryColor
                                      : MyTheme.noColor,
                                  disabledForegroundColor: Colors.blue,
                                ),
                                child: Text(
                                  action!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: isBuyable
                                          ? MyTheme.white
                                          : Theme.of(context).primaryColor),
                                ),
                                onPressed: () {
                                  if (isBuyable) {
                                    addToCart(productId);
                                  }
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget moreProductLoading() {
    return _showMoreProductLoadingContainer
        ? Container(
            alignment: Alignment.center,
            child: const SizedBox(
              height: 40,
              width: 40,
              child: Row(
                children: [
                  SizedBox(
                    width: 2,
                    height: 2,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          )
        : const SizedBox(
            height: 5,
            width: 5,
          );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: UsefulElements.backButton(),
      title: Text(
        'all_bidded_products'.tr(context: context),
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
