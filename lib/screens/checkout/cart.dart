import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/text_styles.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/cart_counter.dart';
import 'package:animated_text_lerp/animated_text_lerp.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:provider/provider.dart';

import '../../app_config.dart';
import '../../custom/cart_seller_item_list_widget.dart';
import '../../presenter/cart_provider.dart';
import '../../ui_elements/prescription_card.dart';

class Cart extends StatelessWidget {
  const Cart(
      {Key? key,
      this.has_bottomnav,
      this.from_navigation = false,
      this.counter})
      : super(key: key);
  final bool? has_bottomnav;
  final bool from_navigation;
  final CartCounter? counter;

  @override
  Widget build(BuildContext context) {
    return _Cart(
      counter: counter,
      from_navigation: from_navigation,
      has_bottomnav: has_bottomnav,
    );
  }
}

class _Cart extends StatefulWidget {
  const _Cart(
      {Key? key,
      this.has_bottomnav,
      this.from_navigation = false,
      this.counter})
      : super(key: key);
  final bool? has_bottomnav;
  final bool from_navigation;
  final CartCounter? counter;

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<_Cart> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).initState(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cartProvider, _) {
      final int currentQuantity = cartQuantityProduct.value =
          cartProvider.shopList.firstOrNull?.cartItems?.length ?? 0;

      return Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        body: Stack(
          children: [
            RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () => cartProvider.onRefresh(context),
              displacement: 0,
              child: CustomScrollView(
                controller: cartProvider.mainScrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // AnimatedContainer(
                        //   duration: const Duration(milliseconds: 300),
                        //   height:
                        //       cartProvider.isMinOrderQuantityNotEnough ? 25 : 0,
                        //   width: double.maxFinite,
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 20, vertical: 3),
                        //   color: Theme.of(context).primaryColor,
                        //   child: FittedBox(
                        //     fit: BoxFit.scaleDown,
                        //     child: RichText(
                        //       text: TextSpan(
                        //           style: const TextStyle(color: Colors.white),
                        //           children: [
                        //             TextSpan(
                        //                 text:
                        //                     '${'minimum_order_qty_is'.tr(context: context)} ${AppConfig.businessSettingsData.minimumOrderQuantity} , '),
                        //             TextSpan(
                        //                 text:
                        //                     'remaining'.tr(context: context)),
                        //             TextSpan(
                        //                 text:
                        //                     ' ${AppConfig.businessSettingsData.minimumOrderQuantity - (cartProvider.shopList.firstOrNull?.cartItems?.length ?? 0)} '),
                        //           ]),
                        //     ),
                        //   ),
                        // ),
                        // AnimatedContainer(
                        //   duration: const Duration(milliseconds: 300),
                        //   height:
                        //       cartProvider.isMinOrderAmountNotEnough ? 25 : 0,
                        //   width: double.maxFinite,
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 20, vertical: 3),
                        //   color: Theme.of(context).primaryColor,
                        //   child: FittedBox(
                        //     fit: BoxFit.scaleDown,
                        //     child: RichText(
                        //       text: TextSpan(
                        //           style: const TextStyle(color: Colors.white),
                        //           children: [
                        //             TextSpan(
                        //                 text:
                        //                     '${'minimum_order_amount_is'.tr(context: context)} ${AppConfig.businessSettingsData.minimumOrderAmount} , '),
                        //             TextSpan(
                        //                 text:
                        //                     'remaining'.tr(context: context)),
                        //             TextSpan(
                        //                 text:
                        //                     ' ${AppConfig.businessSettingsData.minimumOrderAmount - cartProvider.cartTotal} '),
                        //           ]),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 30),
                        Align(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 900),
                            child: LinearOrderProgress(
                              value: AppConfig
                                  .businessSettingsData.minimumOrderAmount,
                              total: cartProvider.cartTotal,
                              isLoading: cartProvider.isInitial,
                              showProgress:
                                  cartProvider.isMinOrderAmountNotEnough,
                              title: 'minimum_order_amount_with_remaining'.tr(
                                context: context,
                                args: {
                                  "minAmount":
                                      "${AppConfig.businessSettingsData.minimumOrderAmount}",
                                  "remaining":
                                      "${(AppConfig.businessSettingsData.minimumOrderAmount - cartProvider.cartTotal).abs()}",
                                },
                              ),
                            ),
                          ),
                        ),
                        if (cartProvider.isMinOrderAmountNotEnough &&
                            cartProvider.isMinOrderQuantityNotEnough)
                          const SizedBox(height: AppDimensions.paddingNormal),
                        Align(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 900),
                            child: LinearOrderProgress(
                              value: AppConfig
                                  .businessSettingsData.minimumOrderQuantity
                                  .toDouble(),
                              total: currentQuantity.toDouble(),
                              isLoading: cartProvider.isInitial,
                              showProgress:
                                  cartProvider.isMinOrderQuantityNotEnough,
                              title: 'minimum_order_quantity_with_remaining'.tr(
                                context: context,
                                args: {
                                  "minquantity":
                                      "${AppConfig.businessSettingsData.minimumOrderQuantity}",
                                  "remaining":
                                      "${(AppConfig.businessSettingsData.minimumOrderQuantity - currentQuantity).abs()}",
                                },
                              ),
                            ),
                          ),
                        ),

                        // if (!cartProvider.isInitial &&
                        //     quantityProgress < 1.0) ...[
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20),
                        //   child: Stack(
                        //     alignment: Alignment.center,
                        //     children: [

                        //       LinearProgressIndicator(
                        //         value: quantityProgress,
                        //         minHeight: 20,
                        //         backgroundColor: Colors.grey[300],
                        //         color: Theme.of(context).primaryColor,
                        //       ),
                        //       Text(
                        //         '${(quantityProgress * 100).toStringAsFixed(0)}%',
                        //         style: const TextStyle(
                        //           color: Colors.white,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: AppDimensions.paddingVeryExtraLarge,
                        //       vertical: AppDimensions.paddingSmall),
                        //   child: FittedBox(
                        //     child: RichText(
                        //       text: TextSpan(
                        //         style: const TextStyle(color: Colors.black),
                        //         children: [
                        //           TextSpan(
                        //               text:
                        //                   '${'minimum_order_qty_is'.tr(context: context)} ${AppConfig.businessSettingsData.minimumOrderQuantity} , '),
                        //           TextSpan(
                        //               text:
                        //                   'remaining'.tr(context: context)),
                        //           TextSpan(
                        //               text:
                        //                   ' ${AppConfig.businessSettingsData.minimumOrderQuantity - currentQuantity} '),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // ],
                        buildCartSellerList(cartProvider, context),
                        SizedBox(height: widget.has_bottomnav! ? 140 : 100),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: buildBottomContainer(cartProvider),
            )
          ],
        ),
      );
    });
  }

  Container buildBottomContainer(CartProvider cartProvider) {
    final bool canProceed = cartProvider.shopList.isNotEmpty ||
        cartProvider.prescriptionItem != null;
    return Container(
      decoration: const BoxDecoration(
        color: MyTheme.mainColor,
      ),

      height: widget.has_bottomnav!
          ? AppConfig.businessSettingsData.isPrescriptionActive
              ? 240
              : 200
          : 120,
      //color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusHalfSmall),
                  color: MyTheme.soft_accent_color),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'total_amount_ucf'.tr(context: context),
                      style: const TextStyle(
                          color: MyTheme.dark_font_grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AnimatedNumberText<double>(
                        double.tryParse(
                              cartProvider.cartTotalString
                                  .replaceAll(RegExp('[^0-9.]'), ''),
                            ) ??
                            0.0,
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        formatter: (value) => '${value.toStringAsFixed(2)}',
                      )),
                ],
              ),
            ),
            Container(
              height: 58,
              width: (MediaQuery.sizeOf(context).width - 48),
              // width: (MediaQuery.sizeOf(context).width - 48) * (2 / 3),
              margin: const EdgeInsets.only(top: AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: cartProvider.shopList.isNotEmpty
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                borderRadius: app_language_rtl.$!
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radiusHalfSmall),
                        bottomLeft:
                            Radius.circular(AppDimensions.radiusHalfSmall),
                        topRight:
                            Radius.circular(AppDimensions.radiusHalfSmall),
                        bottomRight:
                            Radius.circular(AppDimensions.radiusHalfSmall),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radiusHalfSmall),
                        bottomLeft:
                            Radius.circular(AppDimensions.radiusHalfSmall),
                        topRight:
                            Radius.circular(AppDimensions.radiusHalfSmall),
                        bottomRight:
                            Radius.circular(AppDimensions.radiusHalfSmall),
                      ),
              ),
              child: Btn.basic(
                minWidth: MediaQuery.sizeOf(context).width,
                color: canProceed
                    ? Theme.of(context).primaryColor
                    : MyTheme.grey_153,
                shape: app_language_rtl.$!
                    ? const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(AppDimensions.radiusHalfSmall),
                          bottomLeft:
                              Radius.circular(AppDimensions.radiusHalfSmall),
                          topRight: Radius.circular(0.0),
                          bottomRight: Radius.circular(0.0),
                        ),
                      )
                    : const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0.0),
                          bottomLeft: Radius.circular(0.0),
                          topRight:
                              Radius.circular(AppDimensions.radiusHalfSmall),
                          bottomRight:
                              Radius.circular(AppDimensions.radiusHalfSmall),
                        ),
                      ),
                child: Text(
                  'proceed_to_shipping_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
                onPressed: canProceed
                    ? () => cartProvider.onPressProceedToShipping(context)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      leading: Builder(
        builder: (context) => widget.from_navigation
            ? UsefulElements.backToMain(go_back: false)
            : UsefulElements.backButton(),
      ),
      centerTitle: widget.from_navigation,
      title: Text(
        'shopping_cart_ucf'.tr(context: context),
        style: TextStyles.buildAppBarTexStyle(),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      scrolledUnderElevation: 0.0,
    );
  }

  Widget buildCartSellerList(CartProvider cartProvider, context) {
    const EdgeInsets padding = EdgeInsets.fromLTRB(20, 10, 20, 0);
    if (cartProvider.isInitial &&
        cartProvider.shopList.isEmpty &&
        cartProvider.prescriptionItem == null) {
      return SingleChildScrollView(
          padding: padding,
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (cartProvider.shopList.isNotEmpty ||
        cartProvider.prescriptionItem != null) {
      const TextStyle titleTextStyle = TextStyle(
        color: MyTheme.dark_font_grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      );
      return SingleChildScrollView(
        child: Column(
          spacing: 26,
          children: [
            if (cartProvider.prescriptionItem != null)
              const PrescriptionCardCart(
                padding: padding,
                titleTextStyle: titleTextStyle,
              ),
            ListView.separated(
              padding: padding,
              separatorBuilder: (context, index) => const SizedBox(height: 26),
              itemCount: cartProvider.shopList.length,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingNormal,
                      ),
                      child: Row(
                        children: [
                          Text(
                            cartProvider.shopList[index].name ?? '',
                            style: titleTextStyle,
                          ),
                          const Spacer(),
                          AnimatedNumberText<double>(
                            double.tryParse(
                                  cartProvider.shopList[index].subTotal
                                          ?.replaceAll(RegExp('[^0-9.]'), '') ??
                                      '0.0',
                                ) ??
                                0.0, // fallback value لو فشل التحويل

                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            formatter: (value) =>
                                '${value.toStringAsFixed(2)} ${SystemConfig.systemCurrency?.symbol ?? ''}',
                          ),
                        ],
                      ),
                    ),
                    CartSellerItemListWidget(
                      sellerIndex: index,
                      cartProvider: cartProvider,
                      context: context,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    } else if (!cartProvider.isInitial && cartProvider.shopList.isEmpty) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: Center(
          child: Text(
            'cart_is_empty'.tr(context: context),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: MyTheme.font_grey,
                ),
          ),
        ),
      );
    }
    return emptyWidget;
  }
}

class LinearOrderProgress extends StatefulWidget {
  const LinearOrderProgress({
    super.key,
    required this.value,
    required this.total,
    required this.isLoading,
    required this.title,
    required this.showProgress,
  });

  final double value;
  final double total;
  final bool isLoading;
  final String title;
  final bool showProgress;

  @override
  State<LinearOrderProgress> createState() => _LinearOrderProgressState();
}

class _LinearOrderProgressState extends State<LinearOrderProgress> {
  late bool showProgress = !widget.isLoading;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        isReady = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (widget.total / widget.value).clamp(0.0, 1.0);
    if (progress >= 1.0 && showProgress && !widget.showProgress) {
      Future.delayed(
        const Duration(milliseconds: AppDimensions.animationDefaultInMillis),
        () {
          setState(() {
            showProgress = false;
          });
        },
      );
    } else if (progress < 1 && !showProgress && widget.showProgress) {
      setState(() {
        showProgress = true;
      });
    } else if (showProgress && !widget.showProgress) {
      setState(() {
        showProgress = false;
      });
    }
    return AnimatedCrossFade(
      crossFadeState:
          showProgress ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 100),
      secondChild: emptyWidget,
      firstChild: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: isReady
                      ? Tween<double>(begin: 1, end: progress)
                      : Tween<double>(begin: 0, end: progress),
                  duration: const Duration(
                    milliseconds: AppDimensions.animationDefaultInMillis,
                  ),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 20,
                      backgroundColor: Colors.grey[300],
                      color: Theme.of(context).primaryColor,
                    );
                  },
                ),
                // Text(
                //   '${(progress * 100).toStringAsFixed(0)}%',
                //   style: const TextStyle(
                //     color: Colors.white,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                AnimatedNumberText<double>(
                  progress * 100,
                  duration: const Duration(
                    milliseconds: AppDimensions.animationDefaultInMillis,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  formatter: (value) => '${value.toStringAsFixed(0)}%',
                ),
              ],
            ),
            AnimatedStringText(
              widget.title,
              duration: const Duration(
                milliseconds: AppDimensions.animationDefaultInMillis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
