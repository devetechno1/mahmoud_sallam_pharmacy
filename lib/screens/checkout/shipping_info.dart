import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/enum_classes.dart';
import 'package:active_ecommerce_cms_demo_app/custom/fade_network_image.dart';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/delivery_info_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/num_ex.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/cart_provider.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/address_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/shipping_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/checkout/checkout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_config.dart';
import '../../custom/wholesale_text_widget.dart';
import '../../ui_elements/prescription_card.dart';
import '../product/product_details.dart';

class ShippingInfo extends StatefulWidget {
  final String? guestCheckOutShippingAddress;

  const ShippingInfo({
    Key? key,
    this.guestCheckOutShippingAddress,
  }) : super(key: key);

  @override
  _ShippingInfoState createState() => _ShippingInfoState();
}

class _ShippingInfoState extends State<ShippingInfo> {
  final ScrollController _mainScrollController = ScrollController();
  final List<SellerWithShipping> _sellerWiseShippingOption = [];
  List<DeliveryInfoResponse> _deliveryInfoList = [];
  String? _shipping_cost_string = ". . .";
  // Boolean variables
  bool _isFetchDeliveryInfo = false;
  bool _isFetchShippingCost = false;
  //double variables
  double mWidth = 0;
  double mHeight = 0;

  fetchAll() {
    getDeliveryInfo();
  }

  getDeliveryInfo() async {
    _deliveryInfoList = await (ShippingRepository().getDeliveryInfo());
    _isFetchDeliveryInfo = true;

    _deliveryInfoList.forEach((element) {
      final shippingOption = AppConfig.businessSettingsData.carrierBaseShipping
          ? ShippingOption.Carrier
          : ShippingOption.HomeDelivery;
      int? shippingId;
      if (AppConfig.businessSettingsData.carrierBaseShipping &&
          element.carriers!.data!.isNotEmpty &&
          !(element.cartItems
                  ?.every((element2) => element2.isDigital ?? false) ??
              false)) {
        shippingId = element.carriers!.data!.first.id;
      }
      print(
          "AppConfig.businessSettingsData.carrierBaseShipping{AppConfig.businessSettingsData.carrierBaseShipping}");

      _sellerWiseShippingOption
          .add(SellerWithShipping(element.ownerId, shippingOption, shippingId));
    });
    getSetShippingCost();
    setState(() {});
  }

  Future<void> getSetShippingCost() async {
    var shippingCostResponse;
    shippingCostResponse = await AddressRepository()
        .getShippingCostResponse(shipping_type: _sellerWiseShippingOption);

    if (shippingCostResponse.result == true) {
      _shipping_cost_string = shippingCostResponse.value_string;
    } else {
      _shipping_cost_string = "0.0";
    }
    _isFetchShippingCost = true;
    setState(() {});
  }

  void resetData() {
    clearData();
    fetchAll();
  }

  void clearData() {
    _deliveryInfoList.clear();
    _sellerWiseShippingOption.clear();
    _shipping_cost_string = ". . .";
    _shipping_cost_string = ". . .";
    _isFetchDeliveryInfo = false;
    _isFetchShippingCost = false;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    clearData();
    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  void onPopped(value) {
    resetData();
  }

  void afterAddingAnAddress() {
    resetData();
  }

  void onPickUpPointSwitch() {
    _shipping_cost_string = ". . .";
    setState(() {});
  }

  void changeShippingOption(ShippingOption option, index) {
    if (option.index == 1) {
      if (_deliveryInfoList.first.pickupPoints!.isNotEmpty) {
        _sellerWiseShippingOption[index].shippingId =
            _deliveryInfoList.first.pickupPoints!.first.id;
      } else {
        _sellerWiseShippingOption[index].shippingId = 0;
      }
    }
    if (option.index == 2) {
      if (_deliveryInfoList.first.carriers!.data!.isNotEmpty) {
        _sellerWiseShippingOption[index].shippingId =
            _deliveryInfoList.first.carriers!.data!.first.id;
      } else {
        _sellerWiseShippingOption[index].shippingId = 0;
      }
    }
    _sellerWiseShippingOption[index].shippingOption = option;
    getSetShippingCost();

    setState(() {});
  }

  Future<void> onPressProceed(context) async {
    var shippingCostResponse;

    final _sellerWiseShippingOptionErrors =
        _sellerWiseShippingOption.where((element) {
      print(element.shippingId);
      if ((element.shippingId == 0 || element.shippingId == null) &&
          !element.isAllDigital) {
        return true;
      }
      return false;
    });

    print(_sellerWiseShippingOptionErrors.length);
    print(jsonEncode(_sellerWiseShippingOption));

    if (_sellerWiseShippingOptionErrors.isNotEmpty &&
        AppConfig.businessSettingsData.carrierBaseShipping) {
      ToastComponent.showDialog(
        'please_choose_valid_info'.tr(context: context),
      );
      return;
    }

    shippingCostResponse = await AddressRepository()
        .getShippingCostResponse(shipping_type: _sellerWiseShippingOption);

    if (shippingCostResponse.result == false) {
      ToastComponent.showDialog(
        'network_error'.tr(context: context),
      );
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Checkout(
        title: 'checkout_ucf'.tr(context: context),
        paymentFor: PaymentFor.Order,
        guestCheckOutShippingAddress: widget.guestCheckOutShippingAddress,
      );
    })).then((value) {
      onPopped(value);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // if (is_logged_in.$ == true) {
    fetchAll();
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mHeight = MediaQuery.sizeOf(context).height;
    mWidth = MediaQuery.sizeOf(context).width;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          appBar: customAppBar(context) as PreferredSizeWidget?,
          bottomNavigationBar: buildBottomAppBar(context),
          body: buildBody(context)),
    );
  }

  RefreshIndicator buildBody(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      onRefresh: _onRefresh,
      displacement: 0,
      child: Container(
        child: buildBodyChildren(context),
      ),
    );
  }

  Widget buildBodyChildren(BuildContext context) {
    return buildCartSellerList();
  }

  Widget buildShippingListBody(sellerIndex) {
    return _sellerWiseShippingOption[sellerIndex].shippingOption !=
            ShippingOption.PickUpPoint
        ? buildHomeDeliveryORCarrier(sellerIndex)
        : buildPickupPoint(sellerIndex);
  }

  Widget buildHomeDeliveryORCarrier(sellerArrayIndex) {
    if (AppConfig.businessSettingsData.carrierBaseShipping) {
      return buildCarrierSection(sellerArrayIndex);
    } else {
      return emptyWidget;
    }
  }

  Container buildLoginWarning() {
    return Container(
        height: 100,
        child: Center(
            child: Text(
          'you_need_to_log_in'.tr(context: context),
          style: const TextStyle(color: MyTheme.font_grey),
        )));
  }

  Widget buildPickupPoint(sellerArrayIndex) {
    // if (is_logged_in.$ == false) {
    //   return buildLoginWarning();
    // } else
    if (_isFetchDeliveryInfo && _deliveryInfoList.isEmpty) {
      return buildCarrierShimmer();
    } else if (_deliveryInfoList[sellerArrayIndex].pickupPoints!.isNotEmpty) {
      return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(
          height: 14,
        ),
        itemCount: _deliveryInfoList[sellerArrayIndex].pickupPoints!.length,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildPickupPointItemCard(index, sellerArrayIndex);
        },
      );
    } else if (_isFetchDeliveryInfo &&
        _deliveryInfoList[sellerArrayIndex].pickupPoints!.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            'pickup_point_is_unavailable_ucf'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  GestureDetector buildPickupPointItemCard(pickupPointIndex, sellerArrayIndex) {
    return GestureDetector(
      onTap: () {
        if (_sellerWiseShippingOption[sellerArrayIndex].shippingId !=
            _deliveryInfoList[sellerArrayIndex]
                .pickupPoints![pickupPointIndex]
                .id) {
          _sellerWiseShippingOption[sellerArrayIndex].shippingId =
              _deliveryInfoList[sellerArrayIndex]
                  .pickupPoints![pickupPointIndex]
                  .id;
        }
        setState(() {});
        getSetShippingCost();
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1(radius: 8).copyWith(
            border: _sellerWiseShippingOption[sellerArrayIndex].shippingId ==
                    _deliveryInfoList[sellerArrayIndex]
                        .pickupPoints![pickupPointIndex]
                        .id
                ? Border.all(color: Theme.of(context).primaryColor, width: 1.0)
                : Border.all(color: MyTheme.light_grey, width: 1.0)),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingDefault),
          child: buildPickUpPointInfoItemChildren(
              pickupPointIndex, sellerArrayIndex),
        ),
      ),
    );
  }

  Column buildPickUpPointInfoItemChildren(pickupPointIndex, sellerArrayIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 75,
                child: Text(
                  'address_ucf'.tr(context: context),
                  style: const TextStyle(
                    fontSize: 13,
                    color: MyTheme.dark_font_grey,
                  ),
                ),
              ),
              Container(
                width: 175,
                child: Text(
                  _deliveryInfoList[sellerArrayIndex]
                      .pickupPoints![pickupPointIndex]
                      .name!,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 13,
                      color: MyTheme.dark_grey,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              buildShippingSelectMarkContainer(
                  _sellerWiseShippingOption[sellerArrayIndex].shippingId ==
                      _deliveryInfoList[sellerArrayIndex]
                          .pickupPoints![pickupPointIndex]
                          .id)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 75,
                child: Text(
                  'phone_ucf'.tr(context: context),
                  style: const TextStyle(
                    fontSize: 13,
                    color: MyTheme.dark_font_grey,
                  ),
                ),
              ),
              Container(
                width: 200,
                child: Text(
                  _deliveryInfoList[sellerArrayIndex]
                      .pickupPoints![pickupPointIndex]
                      .phone!,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 13,
                      color: MyTheme.dark_grey,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCarrierSection(sellerArrayIndex) {
    // if (is_logged_in.$ == false) {
    //   return buildLoginWarning();
    // } else
    if (!_isFetchDeliveryInfo) {
      return buildCarrierShimmer();
    } else if (_deliveryInfoList[sellerArrayIndex].carriers!.data!.isNotEmpty) {
      return Container(child: buildCarrierListView(sellerArrayIndex));
    } else {
      return buildCarrierNoData();
    }
  }

  Container buildCarrierNoData() {
    return Container(
      height: 100,
      child: Center(
        child: Text(
          'carrier_points_is_unavailable_ucf'.tr(context: context),
          style: const TextStyle(color: MyTheme.font_grey),
        ),
      ),
    );
  }

  Widget buildCarrierListView(sellerArrayIndex) {
    return ListView.separated(
      itemCount: _deliveryInfoList[sellerArrayIndex].carriers!.data!.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 14,
        );
      },
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        // if (_sellerWiseShippingOption[sellerArrayIndex].shippingId == 0) {
        //   _sellerWiseShippingOption[sellerArrayIndex].shippingId = _deliveryInfoList[sellerArrayIndex].carriers.data[index].id;
        //   setState(() {});
        // }
        return buildCarrierItemCard(index, sellerArrayIndex);
      },
    );
  }

  Widget buildCarrierShimmer() {
    return ShimmerHelper().buildListShimmer(item_count: 2, item_height: 50.0);
  }

  GestureDetector buildCarrierItemCard(carrierIndex, sellerArrayIndex) {
    return GestureDetector(
      onTap: () {
        if (_sellerWiseShippingOption[sellerArrayIndex].shippingId !=
            _deliveryInfoList[sellerArrayIndex]
                .carriers!
                .data![carrierIndex]
                .id) {
          _sellerWiseShippingOption[sellerArrayIndex].shippingId =
              _deliveryInfoList[sellerArrayIndex]
                  .carriers!
                  .data![carrierIndex]
                  .id;
          setState(() {});
          getSetShippingCost();
        }
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1(radius: 8).copyWith(
            border: _sellerWiseShippingOption[sellerArrayIndex].shippingId ==
                    _deliveryInfoList[sellerArrayIndex]
                        .carriers!
                        .data![carrierIndex]
                        .id
                ? Border.all(color: Theme.of(context).primaryColor, width: 1.0)
                : Border.all(color: MyTheme.light_grey, width: 1.0)),
        child: buildCarrierInfoItemChildren(carrierIndex, sellerArrayIndex),
      ),
    );
  }

  Widget buildCarrierInfoItemChildren(carrierIndex, sellerArrayIndex) {
    return Stack(
      children: [
        Container(
          width: DeviceInfo(context).width! / 1.3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyImage.imageNetworkPlaceholder(
                  height: 75.0,
                  width: 75.0,
                  radius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusHalfSmall),
                      bottomLeft:
                          Radius.circular(AppDimensions.radiusHalfSmall)),
                  url: _deliveryInfoList[sellerArrayIndex]
                      .carriers!
                      .data![carrierIndex]
                      .logo),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingSupSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: DeviceInfo(context).width! / 3,
                      child: Text(
                        _deliveryInfoList[sellerArrayIndex]
                            .carriers!
                            .data![carrierIndex]
                            .name!,
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 13,
                            color: MyTheme.dark_font_grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: AppDimensions.paddingSupSmall),
                      child: Text(
                        _deliveryInfoList[sellerArrayIndex]
                                .carriers!
                                .data![carrierIndex]
                                .transitTime
                                .toString() +
                            " " +
                            'day_ucf'.tr(context: context),
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 13,
                            color: MyTheme.dark_font_grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                child: Text(
                  _deliveryInfoList[sellerArrayIndex]
                      .carriers!
                      .data![carrierIndex]
                      .transitPrice
                      .toString(),
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 13,
                      color: MyTheme.dark_font_grey,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 16,
              )
            ],
          ),
        ),
        Positioned(
          right: 16,
          top: 10,
          child: buildShippingSelectMarkContainer(
              _sellerWiseShippingOption[sellerArrayIndex].shippingId ==
                  _deliveryInfoList[sellerArrayIndex]
                      .carriers!
                      .data![carrierIndex]
                      .id),
        )
      ],
    );
  }

  Widget buildShippingSelectMarkContainer(bool check) {
    return check
        ? Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusDefault),
                color: Colors.green),
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.check, color: Colors.white, size: 10),
            ),
          )
        : emptyWidget;
  }

  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      child: Container(
        height: 50,
        child: Btn.minWidthFixHeight(
          minWidth: MediaQuery.sizeOf(context).width,
          height: 50,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Text(
            'proceed_to_checkout'.tr(context: context),
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: () {
            onPressProceed(context);
          },
        ),
      ),
    );
  }

  Widget customAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: MyTheme.white,
      automaticallyImplyLeading: false,
      title: buildAppBarTitle(context),
      leading: UsefulElements.backButton(),
    );
  }

  Container buildAppBarTitle(BuildContext context) {
    final CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);

    return Container(
        width: MediaQuery.sizeOf(context).width - 40,
        child: Row(
          children: [
            Text(
              "${'shipping_cost_ucf'.tr(context: context)} ",
              style: const TextStyle(
                fontSize: 16,
                color: MyTheme.dark_font_grey,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            if (cartProvider.isFreeShipping && _isFetchShippingCost)
              Text(
                "${'free_shipping_ucf'.tr(context: context)}",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                "${SystemConfig.systemCurrency != null ? _shipping_cost_string!.replaceAll(SystemConfig.systemCurrency!.code!, SystemConfig.systemCurrency!.symbol!) : _shipping_cost_string}",
                style: const TextStyle(
                  fontSize: 16,
                  color: MyTheme.dark_font_grey,
                  fontWeight: FontWeight.bold,
                ),
              )
          ],
        ));
  }

  Container buildAppbarBackArrow() {
    return Container(
      width: 40,
      child: UsefulElements.backButton(),
    );
  }

  Widget buildChooseShippingOptions(BuildContext context, sellerIndex) {
    return Container(
      color: MyTheme.white,
      //MyTheme.light_grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (AppConfig.businessSettingsData.carrierBaseShipping)
            buildCarrierOption(context, sellerIndex)
          else
            buildAddressOption(context, sellerIndex),
          const SizedBox(
            width: 14,
          ),
          if (AppConfig.businessSettingsData.pickupPoint)
            buildPickUpPointOption(context, sellerIndex),
        ],
      ),
    );
  }

  Widget buildPickUpPointOption(BuildContext context, sellerIndex) {
    return Btn.basic(
      color: _sellerWiseShippingOption[sellerIndex].shippingOption ==
              ShippingOption.PickUpPoint
          ? Theme.of(context).primaryColor
          : Theme.of(context).primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
          side: BorderSide(color: Theme.of(context).primaryColor)),
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingNormal),
      onPressed: () {
        setState(() {
          changeShippingOption(ShippingOption.PickUpPoint, sellerIndex);
        });
      },
      child: Container(
        alignment: Alignment.center,
        height: 30,
        //width: (mWidth / 4) - 1,
        child: Row(
          children: [
            Radio(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (!states.contains(WidgetState.selected)) {
                    return Theme.of(context).primaryColor;
                  }
                  return MyTheme.white;
                }),
                value: ShippingOption.PickUpPoint,
                groupValue:
                    _sellerWiseShippingOption[sellerIndex].shippingOption,
                onChanged: (dynamic newOption) {
                  changeShippingOption(newOption, sellerIndex);
                }),
            //SizedBox(width: 10,),
            Text(
              'pickup_point_ucf'.tr(context: context),
              style: TextStyle(
                  fontSize: 12,
                  color:
                      _sellerWiseShippingOption[sellerIndex].shippingOption ==
                              ShippingOption.PickUpPoint
                          ? MyTheme.white
                          : Theme.of(context).primaryColor,
                  fontWeight:
                      _sellerWiseShippingOption[sellerIndex].shippingOption ==
                              ShippingOption.PickUpPoint
                          ? FontWeight.w700
                          : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddressOption(BuildContext context, sellerIndex) {
    return Btn.basic(
      color: _sellerWiseShippingOption[sellerIndex].shippingOption ==
              ShippingOption.HomeDelivery
          ? Theme.of(context).primaryColor
          : Theme.of(context).primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
          side: BorderSide(color: Theme.of(context).primaryColor)),
      padding: const EdgeInsetsDirectional.only(end: 14),
      onPressed: () {
        changeShippingOption(ShippingOption.HomeDelivery, sellerIndex);
      },
      child: Container(
        height: 30,
        // width: (mWidth / 4) - 1,
        alignment: Alignment.center,
        child: Row(
          children: [
            Radio(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (!states.contains(WidgetState.selected)) {
                    return Theme.of(context).primaryColor;
                  }
                  return MyTheme.white;
                }),
                value: ShippingOption.HomeDelivery,
                groupValue:
                    _sellerWiseShippingOption[sellerIndex].shippingOption,
                onChanged: (dynamic newOption) {
                  changeShippingOption(newOption, sellerIndex);
                }),
            Text(
              'home_delivery_ucf'.tr(context: context),
              style: TextStyle(
                  fontSize: 12,
                  color:
                      _sellerWiseShippingOption[sellerIndex].shippingOption ==
                              ShippingOption.HomeDelivery
                          ? MyTheme.white
                          : Theme.of(context).primaryColor,
                  fontWeight:
                      _sellerWiseShippingOption[sellerIndex].shippingOption ==
                              ShippingOption.HomeDelivery
                          ? FontWeight.w700
                          : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCarrierOption(BuildContext context, sellerIndex) {
    return Btn.basic(
      color: _sellerWiseShippingOption[sellerIndex].shippingOption ==
              ShippingOption.Carrier
          ? Theme.of(context).primaryColor
          : Theme.of(context).primaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
          side: BorderSide(color: Theme.of(context).primaryColor)),
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingNormal),
      onPressed: () {
        changeShippingOption(ShippingOption.Carrier, sellerIndex);
      },
      child: Container(
        height: 30,
        // width: (mWidth / 4) - 1,
        alignment: Alignment.center,
        child: Row(
          children: [
            Radio(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (!states.contains(WidgetState.selected)) {
                    return Theme.of(context).primaryColor;
                  }
                  return MyTheme.white;
                }),
                value: ShippingOption.Carrier,
                groupValue:
                    _sellerWiseShippingOption[sellerIndex].shippingOption,
                onChanged: (dynamic newOption) {
                  changeShippingOption(newOption, sellerIndex);
                }),
            Text(
              'carrier_ucf'.tr(context: context),
              style: TextStyle(
                  fontSize: 12,
                  color:
                      _sellerWiseShippingOption[sellerIndex].shippingOption ==
                              ShippingOption.Carrier
                          ? MyTheme.white
                          : Theme.of(context).primaryColor,
                  fontWeight:
                      _sellerWiseShippingOption[sellerIndex].shippingOption ==
                              ShippingOption.Carrier
                          ? FontWeight.w700
                          : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCartSellerList() {
    // if (is_logged_in.$ == false) {
    //   return Container(
    //       height: 100,
    //       child: Center(
    //           child: Text(
    //             AppLocalizations
    //                 .of(context)!
    //                 .please_log_in_to_see_the_cart_items,
    //             style: TextStyle(color: MyTheme.font_grey),
    //           )));
    // }
    // else
    if (_isFetchDeliveryInfo && _deliveryInfoList.isEmpty) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_deliveryInfoList.isNotEmpty) {
      return buildCartSellerListBody();
    } else if (_isFetchDeliveryInfo && _deliveryInfoList.isEmpty) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            'cart_is_empty'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    }
    return emptyWidget;
  }

  SingleChildScrollView buildCartSellerListBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: ListView.separated(
          padding: const EdgeInsets.only(bottom: 20),
          separatorBuilder: (context, index) => const SizedBox(
            height: 26,
          ),
          itemCount: _deliveryInfoList.length,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildCartSellerListItem(index, context);
          },
        ),
      ),
    );
  }

  Column buildCartSellerListItem(int index, BuildContext context) {
    final CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    final double difference =
        AppConfig.businessSettingsData.freeShippingMinimumOrderAmount -
            cartProvider.cartTotal;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: cartProvider.isFreeShipping && _isFetchShippingCost
              ? Text(
                  'freeShippingUnlocked'.tr(
                    context: context,
                    args: {
                      "minOrderForFreeShipping":
                          "${AppConfig.businessSettingsData.freeShippingMinimumOrderAmount}"
                    },
                  ),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                )
              : (difference > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'you_should_complete'.tr(context: context),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                        Text(
                          "$difference",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                        Text(
                          'to_take_free_shipping'.tr(context: context),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                      ],
                    )
                  : emptyWidget),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          _deliveryInfoList[index].name!,
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 16),
        ),
      ),
      buildCartSellerItemList(index),
      if (!((_deliveryInfoList[index]
          .cartItems!
          .every((element) => (element.isDigital ?? false)))))
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingMedium),
              child: Text(
                'choose_delivery_ucf'.tr(context: context),
                style: const TextStyle(
                    color: MyTheme.dark_font_grey,
                    fontWeight: FontWeight.w700,
                    fontSize: 12),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            buildChooseShippingOptions(context, index),
            const SizedBox(
              height: 10,
            ),
            buildShippingListBody(index),
          ],
        ),
    ]);
  }

  SingleChildScrollView buildCartSellerItemList(sellerIndex) {
    return SingleChildScrollView(
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(
          height: 24,
        ),
        itemCount: _deliveryInfoList[sellerIndex].cartItems!.length,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildCartSellerItemCard(index, sellerIndex);
        },
      ),
    );
  }

  Widget buildCartSellerItemCard(itemIndex, sellerIndex) {
    final CartItem item = _deliveryInfoList[sellerIndex].cartItems![itemIndex];

    if (item.isPrescription == true) {
      return PrescriptionCard(
        canAddMore: false,
        padding: EdgeInsets.all(0),
        images: item.prescriptionImages,
      );
    }

    final bool hasWholesale = makeNewVisualWholesale(item.wholesales);
    return Container(
      height: 100,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        SizedBox(
          width: 100,
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppDimensions.radiusHalfSmall),
                  right: Radius.zero),
              child: FadeInImage.assetNetwork(
                placeholder: AppImages.placeholder,
                image: item.productThumbnailImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: AppDimensions.paddingDefault,
              children: [
                Flexible(
                  child: Text(
                    item.productName!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Builder(builder: (context) {
                  // String priceWithCurrency = SystemConfig.systemCurrency != null
                  //     ? "${item.productPrice}".replaceAll(
                  //         SystemConfig.systemCurrency!.code!,
                  //         SystemConfig.systemCurrency!.symbol!)
                  //     : "${item.productPrice}";
                  // if (SystemConfig.systemCurrency?.symbol != null &&
                  //     !priceWithCurrency
                  //         .contains("${SystemConfig.systemCurrency?.symbol}")) {
                  //   priceWithCurrency +=
                  //       " ${SystemConfig.systemCurrency!.symbol!}";
                  // }
                  final String total =
                      "${((item.productPrice ?? 0) * (item.productQuantity ?? 0)).withSeparator} ${SystemConfig.systemCurrency?.symbol ?? ''}";
                  if (hasWholesale) {
                    return WholesaleTextWidget(
                      textAfter: "\n$total",
                      wholesales: item.wholesales,
                      quantity: item.productQuantity ?? 0,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    );
                  }

                  return Text(
                    item.isDigital == true && item.productQuantity == 1
                        ? "${'price_ucf'.tr(context: context)}: ${item.productPrice.withSeparator} ${SystemConfig.systemCurrency?.symbol ?? ''}"
                        : "${item.productQuantity} × ${item.productPrice.withSeparator} = $total",
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

enum ShippingOption { HomeDelivery, PickUpPoint, Carrier }

class SellerWithShipping {
  int? sellerId;
  ShippingOption shippingOption;
  int? shippingId;
  bool isAllDigital;

  SellerWithShipping(this.sellerId, this.shippingOption, this.shippingId,
      {this.isAllDigital = false});

  Map toJson() => {
        'seller_id': sellerId,
        'shipping_type': shippingOption == ShippingOption.HomeDelivery
            ? "home_delivery"
            : shippingOption == ShippingOption.Carrier
                ? "carrier"
                : "pickup_point",
        'shipping_id': shippingId,
      };
}
//
// class SellerWithForReqBody{
//   int sellerId;
//   String shippingType;
//
//   SellerWithForReqBody(this.sellerId, this.shippingType);
// }
