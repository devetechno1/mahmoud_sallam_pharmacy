import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/flash_deal_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/main_helpers.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/flash_deal_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/flash_deal/flash_deal_products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

class FlashDealList extends StatefulWidget {
  @override
  _FlashDealListState createState() => _FlashDealListState();
}

class _FlashDealListState extends State<FlashDealList> {
  final List<CountdownTimerController> _timerControllerList = [];

  DateTime convertTimeStampToDateTime(int timeStamp) {
    final dateToTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return dateToTimeStamp;
  }

  @override
  Widget build(BuildContext context) {
    // print("object");
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: buildAppBar(context),
        backgroundColor: MyTheme.mainColor,
        body: buildFlashDealList(context),
      ),
    );
  }

  Widget buildFlashDealList(context) {
    return FutureBuilder<FlashDealResponse>(
      future: FlashDealRepository().getFlashDeals(),
      builder: (context, AsyncSnapshot<FlashDealResponse> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'network_error'.tr(context: context),
              ),
            );
          } else if (snapshot.data == null) {
            return Container(
              child: Center(
                  child: Text(
                'no_data_is_available'.tr(context: context),
              )),
            );
          } else if (snapshot.hasData) {
            final FlashDealResponse flashDealResponse = snapshot.data!;
            return SingleChildScrollView(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 20,
                  );
                },
                itemCount: flashDealResponse.flashDeals!.length,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return buildFlashDealListItem(flashDealResponse, index);
                },
              ),
            );
          }
        }
        return buildShimmer();
      },
    );
  }

  CustomScrollView buildShimmer() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 20,
              );
            },
            itemCount: 20,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return buildFlashDealListItemShimmer();
            },
          ),
        )
      ],
    );
  }

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

  Container buildFlashDealListItem(FlashDealResponse flashDealResponse, index) {
    final DateTime end = convertTimeStampToDateTime(
        flashDealResponse.flashDeals![index].date!); // YYYY-mm-dd
    final DateTime now = DateTime.now();
    final int diff = end.difference(now).inMilliseconds;
    final int endTime = diff + now.millisecondsSinceEpoch;

    void onEnd() {}

    final CountdownTimerController timeController =
        CountdownTimerController(endTime: endTime, onEnd: onEnd);
    _timerControllerList.add(timeController);

    return Container(
      // color: MyTheme.amber,
      height: 340,
      child: CountdownTimer(
        controller: _timerControllerList[index],
        widgetBuilder: (_, CurrentRemainingTime? time) {
          return GestureDetector(
            onTap: () {
              if (time == null) {
                ToastComponent.showDialog(
                  'flash_deal_has_ended'.tr(context: context),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return FlashDealProducts(
                        slug: flashDealResponse.flashDeals![index].slug,
                      );
                    },
                  ),
                );
              }
            },
            //flash deals time,product card
            child: Stack(
              children: [
                buildFlashDealBanner(flashDealResponse, index),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: DeviceInfo(context).width,
                    height: 198,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    //decoration: BoxDecorations.buildBoxDecoration_1(),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusHalfSmall),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ]),
                    child: Column(
                      children: [
                        Center(
                            child: time == null
                                ? Text(
                                    'ended_ucf'.tr(context: context),
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  )
                                : buildTimerRow(time)),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Container(
                              padding: const EdgeInsetsDirectional.only(
                                  top: 0, start: 2, bottom: 17),
                              width: 460,
                              child: Wrap(
                                runSpacing: 10,
                                spacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runAlignment: WrapAlignment.spaceBetween,
                                alignment: WrapAlignment.start,
                                direction: Axis.vertical,
                                children: List.generate(
                                  flashDealResponse.flashDeals![index].products!
                                      .products!.length,
                                  (productIndex) {
                                    return buildFlashDealsProductItem(
                                        flashDealResponse, index, productIndex);
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Container buildFlashDealListItemShimmer() {
    return Container(
      height: 340,
      child: Stack(
        children: [
          buildFlashDealBannerShimmer(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: DeviceInfo(context).width,
              height: 196,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Column(
                children: [
                  Container(
                    child: buildTimerRowRowShimmer(),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      padding:
                          const EdgeInsets.only(top: 0, left: 2, bottom: 16),
                      width: 460,
                      child: Wrap(
                        //spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runAlignment: WrapAlignment.spaceBetween,
                        alignment: WrapAlignment.start,

                        children: List.generate(6, (productIndex) {
                          return buildFlashDealsProductItemShimmer();
                        }),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFlashDealsProductItem(
      flashDealResponse, flashDealIndex, productIndex) {
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 10),
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        color: const Color(0xffF6F7F8),
        borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 2,
          ),
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  AppDimensions.radiusSmallExtra), // Rounding the image corners
              child: Container(
                height: 46,
                width: 44,
                child: FadeInImage(
                  placeholder: const AssetImage(AppImages.placeholder),
                  image: NetworkImage(
                    flashDealResponse.flashDeals[flashDealIndex].products
                        .products[productIndex].image,
                  ),
                  fit: BoxFit
                      .cover, // Ensures the image fits within the rounded corners
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: AppDimensions.paddingSupSmall),
            child: Text(
              convertPrice(flashDealResponse.flashDeals[flashDealIndex].products
                  .products[productIndex].price),
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget buildFlashDealsProductItemShimmer() {
    return Container(
      margin: const EdgeInsets.only(left: AppDimensions.paddingSupSmall),
      height: 50,
      width: 136,
      decoration: BoxDecoration(
        color: const Color(0xffF6F7F8),
        borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusHalfSmall),
                bottomLeft: Radius.circular(AppDimensions.radiusHalfSmall),
              ),
            ),
            child: ShimmerHelper().buildBasicShimmerCustomRadius(
              height: 46,
              width: 44,
              radius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusHalfSmall),
                bottomLeft: Radius.circular(AppDimensions.radiusHalfSmall),
              ),
            ),
          ),
          Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSupSmall),
              child: ShimmerHelper().buildBasicShimmer(height: 15, width: 60))
        ],
      ),
    );
  }

  Container buildFlashDealBanner(flashDealResponse, index) {
    return Container(
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/placeholder_rectangle.png',
        image: flashDealResponse.flashDeals[index].banner,
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
          //  SizedBox(width: 10), // Circular timer for Days (handling null)
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
                'days'.tr(context: context),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              )
            ],
          ),
          const SizedBox(
            width: 12,
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
            width: 5,
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
          Column(
            children: [
              Image.asset(
                "assets/flash_deal.png",
                height: 20,
                color: MyTheme.golden,
              ),
              const SizedBox(
                height: 12,
              )
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                'shop_more_ucf'.tr(context: context),
                style: const TextStyle(fontSize: 10, color: Color(0xffA8AFB3)),
              ),
              const SizedBox(
                width: 3,
              ),
              const Icon(
                Icons.arrow_forward_outlined,
                size: 10,
                color: MyTheme.grey_153,
              ),
              const SizedBox(
                width: 10,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildTimerRowRowShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Icon(
          //   Icons.watch_later_outlined,
          //   color: MyTheme.grey_153,
          // ),
          const SizedBox(
            width: 10,
          ),
          // ShimmerHelper().buildBasicShimmerCustomRadius(
          //     height: 30,
          //     width: 30,
          //     radius: BorderRadius.circular(AppDimensions.radiusaHalfsmall),
          //     color: MyTheme.shimmer_base),
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
            "assets/flash_deal.png",
            height: 20,
            color: MyTheme.golden,
          ),
          const Spacer(),
          InkWell(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    'shop_more_ucf'.tr(context: context),
                    style:
                        const TextStyle(fontSize: 10, color: Color(0xffA8AFB3)),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  const Icon(
                    Icons.arrow_forward_outlined,
                    size: 10,
                    color: MyTheme.grey_153,
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ))
        ],
      ),
    );
  }

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

  Widget timerContainer(Widget child) {
    return Container(
      constraints: const BoxConstraints(minWidth: 30, minHeight: 24),
      child: child,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppDimensions.paddingHalfSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: UsefulElements.backButton(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'flash_deals_ucf'.tr(context: context),
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
