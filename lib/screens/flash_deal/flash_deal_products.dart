import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/flash_deal_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/product_mini_response.dart'
    as productMini;
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/flash_deal_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';

import 'package:active_ecommerce_cms_demo_app/ui_elements/product_card_black.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../helpers/grid_responsive.dart';

class FlashDealProducts extends StatefulWidget {
  const FlashDealProducts({
    Key? key,
    required this.slug,
  }) : super(key: key);
  final String? slug;

  @override
  _FlashDealProductsState createState() => _FlashDealProductsState();
}

class _FlashDealProductsState extends State<FlashDealProducts> {
  CountdownTimerController? countdownTimerController;
  Future<productMini.ProductMiniResponse>? _future;

  late List<productMini.Product> _searchList;
  late List<productMini.Product> _fullList;
  ScrollController? _scrollController;

  FlashDealResponseDatum? flashDealInfo;

  // String timeText(String txt, {default_length = 3}) {
  //   var blank_zeros = default_length == 3 ? "000" : "00";
  //   var leading_zeros = "";
  //   if (txt != null) {
  //     if (default_length == 3 && txt.length == 1) {
  //       leading_zeros = "00";
  //     } else if (default_length == 3 && txt.length == 2) {
  //       leading_zeros = "0";
  //     } else if (default_length == 2 && txt.length == 1) {
  //       leading_zeros = "0";
  //     }
  //   }

  //   var newtxt = (txt == null || txt == "" || txt == null.toString())
  //       ? blank_zeros
  //       : txt;

  //   if (default_length > txt.length) {
  //     newtxt = leading_zeros + newtxt;
  //   }
  //   //print(newtxt);

  //   return newtxt;
  // }
  String timeText(String txt, {default_length = 3}) {
    final blankZeros = default_length == 3 ? "000" : "00";
    var leadingZeros = "";
    if (default_length == 3 && txt.length == 1) {
      leadingZeros = "00";
    } else if (default_length == 3 && txt.length == 2) {
      leadingZeros = "0";
    } else if (default_length == 2 && txt.length == 1) {
      leadingZeros = "0";
    }

    var newtxt = (txt == "" || txt == null.toString()) ? blankZeros : txt;

    if (default_length > txt.length) {
      newtxt = leadingZeros + newtxt;
    }

    return newtxt;
  }

  getInfo() async {
    final res = await FlashDealRepository().getFlashDealInfo(widget.slug);
    print(res.toJson());
    if (res.flashDeals?.isNotEmpty ?? false) {
      flashDealInfo = res.flashDeals?.first;

      final DateTime end =
          convertTimeStampToDateTime(flashDealInfo!.date!); // YYYY-mm-dd
      final DateTime now = DateTime.now();
      final int diff = end.difference(now).inMilliseconds;
      final int endTime = diff + now.millisecondsSinceEpoch;

      void onEnd() {}

      countdownTimerController =
          CountdownTimerController(endTime: endTime, onEnd: onEnd);
    }
    setState(() {});
  }

  DateTime convertTimeStampToDateTime(int timeStamp) {
    final dateToTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return dateToTimeStamp;
  }

  @override
  void initState() {
    // TODO: implement initState
    getInfo();
    _future = ProductRepository().getFlashDealProducts(widget.slug);
    _searchList = [];
    _fullList = [];
    super.initState();
  }

  // _buildSearchList(searchKey) async {
  //   _searchList.clear();
  //   //print(_fullList.length);

  //   if (searchKey.isEmpty) {
  //     _searchList.addAll(_fullList);
  //     setState(() {});
  //   } else {
  //     for (var i = 0; i < _fullList.length; i++) {
  //       if (StringHelper().stringContains(_fullList[i].name, searchKey)!) {
  //         _searchList.add(_fullList[i]);
  //         setState(() {});
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        body: buildProductList(context),
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
      backgroundColor: MyTheme.mainColor,
      toolbarHeight: 50,
      leading: Builder(
        builder: (context) => IconButton(
          icon: UsefulElements.backButton(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: flashDealInfo != null
          ? Text(
              '${flashDealInfo!.title}',
              style: const TextStyle(
                  color: Color(0xff3E4447),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )
          : Text('loading_ucf'.tr(context: context)),
      elevation: 0.0,
      titleSpacing: 0,
      scrolledUnderElevation: 0.0,
    );
  }

  FutureBuilder<productMini.ProductMiniResponse> buildProductList(context) {
    final int cross = GridResponsive.columnsForWidth(context);
    return FutureBuilder(
        future: _future,
        builder:
            (context, AsyncSnapshot<productMini.ProductMiniResponse> snapshot) {
          if (snapshot.hasError) {
            return emptyWidget;
          } else if (snapshot.hasData) {
            final productResponse = snapshot.data;
            if (_fullList.isEmpty) {
              _fullList.addAll(productResponse!.products!);
              _searchList.addAll(productResponse.products!);
            }

            //print('called');

            return SingleChildScrollView(
              child: Column(
                children: [
                  buildFlashDealsBanner(context),
                  MasonryGridView.count(
                    crossAxisCount: cross,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    itemCount: _searchList.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                        top: 16.0, bottom: 10, left: 18, right: 18),
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // 3
                      return ProductCardBlack(
                        id: _searchList[index].id,
                        slug: _searchList[index].slug!,
                        image: _searchList[index].thumbnail_image,
                        name: _searchList[index].name,
                        main_price: _searchList[index].main_price,
                        stroked_price: _searchList[index].stroked_price,
                        has_discount: _searchList[index].has_discount!,
                        discount: _searchList[index].discount,
                        isWholesale: _searchList[index].isWholesale ?? false,
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  headerShimmer(),
                  ShimmerHelper().buildProductGridShimmer(
                    crossAxisCount: cross,
                    scontroller: _scrollController,
                  ),
                ],
              ),
            );
          }
        });
  }

  Container buildFlashDealsBanner(BuildContext context) {
    return Container(
      //color: MyTheme.amber,
      height: 215,
      child: CountdownTimer(
        controller: countdownTimerController,
        widgetBuilder: (_, CurrentRemainingTime? time) {
          return Stack(
            children: [
              buildFlashDealBanner(),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: DeviceInfo(context).width,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusHalfSmall),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 20,
                            offset: const Offset(0, 10))
                      ]),
                  child: Column(
                    children: [
                      Container(
                        child: Center(
                            child: time == null
                                ? Text(
                                    'ended_ucf'.tr(context: context),
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  )
                                : buildTimerRow(time)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Container headerShimmer() {
    return Container(
      // color: MyTheme.amber,
      height: 215,
      child: Stack(
        children: [
          buildFlashDealBannerShimmer(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: DeviceInfo(context).width,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Container(
                child: buildTimerRowRowShimmer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildFlashDealBanner() {
    return Container(
      child: FadeInImage.assetNetwork(
        placeholder: AppImages.placeholderRectangle,
        image: flashDealInfo?.banner ?? "",
        fit: BoxFit.cover,
        width: DeviceInfo(context).width,
        height: 180,
      ),
    );
  }

  Widget buildFlashDealBannerShimmer() {
    return ShimmerHelper().buildBasicShimmerCustomRadius(
        width: DeviceInfo(context).width,
        height: 180,
        color: MyTheme.medium_grey_50);
  }

  Widget buildTimerRow(CurrentRemainingTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 5),
          Column(
            children: [
              timerCircularContainer(
                time.days ?? 0,
                365,
                timeText((time.days ?? 0).toString(), default_length: 3),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'days_ucf'.tr(context: context),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              )
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            children: [
              timerCircularContainer(
                time.hours ?? 0,
                24,
                timeText((time.hours ?? 0).toString(), default_length: 2),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'hours'.tr(context: context),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              )
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            children: [
              timerCircularContainer(
                time.min ?? 0,
                60,
                timeText((time.min ?? 0).toString(), default_length: 2),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'minutes'.tr(context: context),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              )
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            children: [
              timerCircularContainer(
                time.sec ?? 0,
                60,
                timeText((time.sec ?? 0).toString(), default_length: 2),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'seconds'.tr(context: context),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              )
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Image.asset(
            AppImages.flashDeal,
            height: 20,
            color: MyTheme.golden,
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
  //It is for Circular

  Widget timerCircularContainer(
      int currentValue, int totalValue, String timeText) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            value: currentValue / totalValue,
            backgroundColor: const Color.fromARGB(255, 240, 220, 220),
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 255, 80, 80)),
            strokeWidth: 4.0,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          timeText,
          style: const TextStyle(
            color: Color.fromARGB(228, 218, 29, 29),
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

//
  Widget buildTimerRowRowShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(
            width: 10,
          ),
          ShimmerHelper().buildCircleShimmer(height: 30, width: 30),
          const SizedBox(
            width: 12,
          ),
          ShimmerHelper().buildCircleShimmer(height: 30, width: 30),
          const SizedBox(
            width: 10,
          ),
          ShimmerHelper().buildCircleShimmer(height: 30, width: 30),
          const SizedBox(
            width: 10,
          ),
          ShimmerHelper().buildCircleShimmer(height: 30, width: 30),
          const SizedBox(
            width: 10,
          ),
          Image.asset(
            AppImages.flashDeal,
            height: 20,
            color: MyTheme.golden,
          ),
          const Spacer()
        ],
      ),
    );
  }

  Widget timerContainer(Widget child) {
    return Container(
      constraints: const BoxConstraints(minWidth: 30, minHeight: 24),
      child: child,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
