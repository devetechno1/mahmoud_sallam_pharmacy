import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/confirm_dialog.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/enum_classes.dart';
import 'package:active_ecommerce_cms_demo_app/custom/info_dialog.dart';

import 'package:active_ecommerce_cms_demo_app/custom/loading.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/order_detail_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/main_helpers.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/order_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/refund_request_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/checkout/checkout.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:active_ecommerce_cms_demo_app/screens/refund_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../data_model/order_item_response.dart';
import '../../data_model/order_mini_response.dart';
import '../../ui_elements/prescription_card.dart';
import 'download_bill.dart';

class OrderDetails extends StatefulWidget {
  final int? id;
  final bool from_notification;
  final bool go_back;

  const OrderDetails(
      {Key? key, this.id, this.from_notification = false, this.go_back = true})
      : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final ScrollController _mainScrollController = ScrollController();
  final _steps = [
    'pending',
    'confirmed',
    'on_delivery',
    'picked_up',
    'on_the_way',
    'delivered'
  ];

  final TextEditingController _refundReasonController = TextEditingController();
  bool _showReasonWarning = false;

  //init
  int _stepIndex = 0;
  final ReceivePort _port = ReceivePort();
  DetailedOrder? _orderDetails;
  final List<OrderItem> _orderedItemList = [];
  bool _orderItemsInit = false;

  OrderItem? prescriptionOrder;

  @override
  void dispose() {
    _refundReasonController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    fetchAll();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    _port.listen(
      (dynamic data) {
        if (data[2] >= 100) {
          ToastComponent.showDialog(
            "File has downloaded successfully.",
          );
        }
        setState(() {});
      },
    );

    super.initState();

    print(widget.id);
  }

  fetchAll() {
    fetchOrderDetails();
    fetchOrderedItems();
  }

  fetchOrderDetails() async {
    final orderDetailsResponse =
        await OrderRepository().getOrderDetails(id: widget.id);

    if (orderDetailsResponse!.detailed_orders!.isNotEmpty) {
      _orderDetails = orderDetailsResponse.detailed_orders![0];
      setStepIndex(_orderDetails!.delivery_status);
    }

    setState(() {});
  }

  setStepIndex(key) {
    _stepIndex = _steps.indexOf(key);
    setState(() {});
  }

  fetchOrderedItems() async {
    final orderItemResponse =
        await OrderRepository().getOrderItems(id: widget.id);
    _orderedItemList.addAll(orderItemResponse.ordered_items ?? []);
    for (int i = 0; i < _orderedItemList.length; i++) {
      if (_orderedItemList[i].isPrescription) {
        prescriptionOrder = _orderedItemList[i];
        _orderedItemList.removeAt(i);
        break;
      } else {
        prescriptionOrder = null;
      }
    }
    _orderItemsInit = true;

    setState(() {});
  }

  reset() {
    _stepIndex = 0;
    _orderDetails = null;
    _orderedItemList.clear();
    _orderItemsInit = false;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  _onPressCancelOrder(id) async {
    Loading.show(context);
    final response = await OrderRepository().cancelOrder(id: id);
    Loading.close();
    if (response.result) {
      _onPageRefresh();
    }
    ToastComponent.showDialog(response.message);
  }

  _onPressReorder(id) async {
    Loading.show(context);
    final response = await OrderRepository().reOrder(id: id);
    Loading.close();
    Widget success = const SizedBox.shrink(), failed = const SizedBox.shrink();
    print(response.successMsgs.toString());
    print(response.failedMsgs.toString());
    if (response.successMsgs!.isNotEmpty) {
      success = Text(
        response.successMsgs?.join("\n") ?? "",
        style: TextStyle(fontSize: 14, color: MyTheme.green_light),
      );
    }
    if (response.failedMsgs!.isNotEmpty) {
      failed = Text(
        response.failedMsgs?.join("\n") ?? "",
        style: const TextStyle(fontSize: 14, color: Colors.red),
      );
    }

    InfoDialog.show(
        title: 'info_ucf'.tr(context: context),
        content: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              success,
              const SizedBox(
                height: 3,
              ),
              failed
            ],
          ),
        ));
  }

  dynamic _showCancelDialog(id) {
    return ConfirmDialog.show(
      context,
      title: 'pleaseEnsureUs'.tr(context: context),
      message: 'do_you_want_to_cancel_this_order'.tr(context: context),
      yesText: 'yes_ucf'.tr(context: context),
      noText: 'no_ucf'.tr(context: context),
      pressYes: () {
        _onPressCancelOrder(id);
      },
    );
  }

  Future _make_re_payment(String amount) {
    const String currencyPattern = r"^[A-Z]{3}(?:[,.]?)";
    final String amountWithoutCountryCode =
        amount.replaceAll(RegExp(r'[^\d.,]+'), '');
    ;

    double convertToDouble(String amountStr) {
      final String amountWithoutCurrency =
          amountStr.replaceAll(RegExp(currencyPattern), "");

      try {
        return double.parse(amountWithoutCurrency.replaceAll(
            ",", "")); // Replace comma with empty string
      } on FormatException catch (e) {
        print("Invalid double format: $e");
        return double.nan; // Or throw an exception if preferred
      }
    }

    final double convertedAmount = convertToDouble(amountWithoutCountryCode);
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Checkout(
          title: 'order_repayment'.tr(context: context),
          rechargeAmount: convertedAmount,
          paymentFor: PaymentFor.OrderRePayment,
          order_id: _orderDetails!.id,
        ),
      ),
    );
  }

  onPressOfflinePaymentButton() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Checkout(
        order_id: widget.id,
        title: 'checkout_ucf'.tr(context: context),
        list: "offline",
        paymentFor: PaymentFor.ManualPayment,
        //offLinePaymentFor: OffLinePaymentFor.Order,
        rechargeAmount:
            double.parse(_orderDetails!.plane_grand_total.toString()),
      );
    })).then((value) {
      onPopped(value);
    });
  }

  Future onTapAskRefund(itemId, itemName, orderCode) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Row(
                          children: [
                            Text('product_name_ucf'.tr(context: context),
                                style: const TextStyle(
                                    color: MyTheme.font_grey, fontSize: 12)),
                            Container(
                              width: 225,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppDimensions.paddingSmall),
                                child: Text(itemName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        color: MyTheme.font_grey,
                                        fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Row(
                          children: [
                            Text('order_code_ucf'.tr(context: context),
                                style: const TextStyle(
                                    color: MyTheme.font_grey, fontSize: 12)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppDimensions.paddingSmall),
                              child: Text(orderCode,
                                  style: const TextStyle(
                                      color: MyTheme.font_grey, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Row(
                          children: [
                            Text("${'reason_ucf'.tr(context: context)} *",
                                style: const TextStyle(
                                    color: MyTheme.font_grey, fontSize: 12)),
                            _showReasonWarning
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                    ),
                                    child: Text(
                                        'reason_cannot_be_empty'
                                            .tr(context: context),
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 12)),
                                  )
                                : emptyWidget,
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 55,
                          child: TextField(
                            controller: _refundReasonController,
                            autofocus: false,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                hintText:
                                    'enter_reason_ucf'.tr(context: context),
                                hintStyle: const TextStyle(
                                    fontSize: 12.0,
                                    color: MyTheme.textfield_grey),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyTheme.textfield_grey,
                                      width: 0.5),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(AppDimensions.radiusSmall),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyTheme.textfield_grey,
                                      width: 1.0),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(AppDimensions.radiusSmall),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 8.0, top: 16.0, bottom: 16.0)),
                          ),
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
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 30,
                        color: const Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSmall),
                            side: const BorderSide(
                                color: MyTheme.light_grey, width: 1.0)),
                        child: Text(
                          'close_all_capital'.tr(context: context),
                          style: const TextStyle(
                            color: MyTheme.font_grey,
                          ),
                        ),
                        onPressed: () {
                          _refundReasonController.clear();
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingExtraLarge),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 30,
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSmall),
                            side: const BorderSide(
                                color: MyTheme.light_grey, width: 1.0)),
                        child: Text(
                          'submit_ucf'.tr(context: context),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          onPressSubmitRefund(itemId, setState);
                        },
                      ),
                    )
                  ],
                )
              ],
            );
          });
        });
  }

  shoWReasonWarning(setState) {
    setState(() {
      _showReasonWarning = true;
    });
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _showReasonWarning = false;
      });
    });
  }

  Future<void> onPressSubmitRefund(itemId, setState) async {
    final reason = _refundReasonController.text.toString();

    if (reason == "") {
      shoWReasonWarning(setState);
      return;
    }

    final refundRequestSendResponse = await RefundRequestRepository()
        .getRefundRequestSendResponse(id: itemId, reason: reason);

    if (refundRequestSendResponse.result == false) {
      ToastComponent.showDialog(
        refundRequestSendResponse.message,
      );
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;
    _refundReasonController.clear();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        refundRequestSendResponse.message,
        style: const TextStyle(color: MyTheme.font_grey),
      ),
      backgroundColor: MyTheme.soft_accent_color,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'show_request_list_ucf'.tr(context: context),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return RefundRequest();
          })).then((value) {
            onPopped(value);
          });
        },
        textColor: Theme.of(context).primaryColor,
        disabledTextColor: Colors.grey,
      ),
    ));

    reset();
    fetchAll();
    setState(() {});
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.from_notification || widget.go_back == false) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Main();
          }));
          return Future<bool>.value(false);
        } else {
          return Future<bool>.value(true);
        }
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          body: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            onRefresh: _onPageRefresh,
            child: CustomScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 20.0),
                      child: _orderDetails != null
                          ? buildTimeLineTiles()
                          : buildTimeLineShimmer()),
                ),
                SliverList(
                    delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 18.0, right: 18.0, bottom: 20.0),
                    child: _orderDetails != null
                        ? buildOrderDetailsTopCard()
                        : ShimmerHelper().buildBasicShimmer(height: 150.0),
                  ),
                ])),
                SliverList(
                    delegate: SliverChildListDelegate([
                  Center(
                    child: Text(
                      'ordered_product_ucf'.tr(context: context),
                      style: const TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 18.0, right: 18.0, top: 14.0),
                      child: _orderedItemList.isEmpty &&
                              _orderItemsInit &&
                              prescriptionOrder == null
                          ? ShimmerHelper().buildBasicShimmer(height: 100.0)
                          : (_orderedItemList.isNotEmpty ||
                                  prescriptionOrder != null
                              ? buildOrderdProductList()
                              : Container(
                                  height: 100,
                                  child: Text(
                                    'ordered_product_ucf'.tr(context: context),
                                    style: const TextStyle(
                                        color: MyTheme.font_grey),
                                  ),
                                )))
                ])),
                SliverList(
                    delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 75,
                        ),
                        buildBottomSection()
                      ],
                    ),
                  )
                ])),
                SliverList(
                    delegate:
                        SliverChildListDelegate([buildPaymentButtonSection()]))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded buildBottomSection() {
    return Expanded(
      child: _orderDetails != null
          ? Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            'sub_total_all_capital'.tr(context: context),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          convertPrice(_orderDetails!.subtotal!),
                          style: const TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            'tax_all_capital'.tr(context: context),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          convertPrice(_orderDetails!.tax!),
                          style: const TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            'shipping_cost_all_capital'.tr(context: context),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          convertPrice(_orderDetails!.shipping_cost!),
                          style: const TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            'discount_all_capital'.tr(context: context),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          convertPrice(_orderDetails!.coupon_discount!),
                          style: const TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
                const Divider(),
                Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          child: Text(
                            'grand_total_all_capital'.tr(context: context),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          convertPrice(_orderDetails!.grand_total!),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
              ],
            )
          : ShimmerHelper().buildBasicShimmer(height: 100.0),
    );
  }

  Column buildTimeLineShimmer() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ShimmerHelper().buildBasicShimmer(height: 40, width: 40.0),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ShimmerHelper().buildBasicShimmer(height: 40, width: 40.0),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ShimmerHelper().buildBasicShimmer(height: 40, width: 40.0),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ShimmerHelper().buildBasicShimmer(height: 40, width: 40.0),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ShimmerHelper().buildBasicShimmer(height: 20, width: 250.0),
        )
      ],
    );
  }

  SizedBox buildTimeLineTiles() {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TimelineTile(
            axis: TimelineAxis.vertical,
            alignment: TimelineAlign.end,
            isFirst: true,
            startChild: Container(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width:
                        _orderDetails!.delivery_status == "pending" ? 36 : 30,
                    height:
                        _orderDetails!.delivery_status == "pending" ? 36 : 30,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmallExtra),
                      border: Border.all(color: Colors.redAccent, width: 2),

                      //shape: BoxShape.rectangle,
                    ),
                    child: const Icon(
                      Icons.list_alt,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                        height: 1.0,
                        width: MediaQuery.sizeOf(context).width * .4,
                        color: MyTheme.medium_grey_50),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmallExtra,
                    ),
                    child: Text(
                      'order_placed'.tr(context: context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: MyTheme.font_grey),
                    ),
                  ),
                ],
              ),
            ),
            indicatorStyle: IndicatorStyle(
              color: _stepIndex >= 0 ? Colors.green : MyTheme.medium_grey,
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingSmallExtra),
              iconStyle: _stepIndex >= 0
                  ? IconStyle(
                      color: Colors.white, iconData: Icons.check, fontSize: 16)
                  : null,
            ),
            afterLineStyle: _stepIndex >= 1
                ? const LineStyle(
                    color: Colors.green,
                    thickness: 5,
                  )
                : const LineStyle(
                    color: MyTheme.medium_grey,
                    thickness: 4,
                  ),
          ),
          TimelineTile(
            axis: TimelineAxis.vertical,
            alignment: TimelineAlign.end,
            startChild: Container(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width:
                        _orderDetails!.delivery_status == "confirmed" ? 36 : 30,
                    height:
                        _orderDetails!.delivery_status == "confirmed" ? 36 : 30,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmallExtra),
                      border: Border.all(color: Colors.blue, width: 2),

                      //shape: BoxShape.rectangle,
                    ),
                    child: const Icon(
                      Icons.thumb_up_sharp,
                      color: Colors.blue,
                      size: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                        height: 1.0,
                        width: MediaQuery.sizeOf(context).width * .4,
                        color: MyTheme.medium_grey_50),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmallExtra,
                    ),
                    child: Text(
                      'confirmed_ucf'.tr(context: context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: MyTheme.font_grey),
                    ),
                  )
                ],
              ),
            ),
            indicatorStyle: IndicatorStyle(
              color: _stepIndex >= 1 ? Colors.green : MyTheme.medium_grey,
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingSmallExtra),
              iconStyle: _stepIndex >= 1
                  ? IconStyle(
                      color: Colors.white, iconData: Icons.check, fontSize: 16)
                  : null,
            ),
            beforeLineStyle: _stepIndex >= 1
                ? const LineStyle(
                    color: Colors.green,
                    thickness: 5,
                  )
                : const LineStyle(
                    color: MyTheme.medium_grey,
                    thickness: 4,
                  ),
            afterLineStyle: _stepIndex >= 2
                ? const LineStyle(
                    color: Colors.green,
                    thickness: 5,
                  )
                : const LineStyle(
                    color: MyTheme.medium_grey,
                    thickness: 4,
                  ),
          ),
          TimelineTile(
            axis: TimelineAxis.vertical,
            alignment: TimelineAlign.end,
            startChild: Container(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: _orderDetails!.delivery_status == "on_the_way"
                        ? 36
                        : 30,
                    height: _orderDetails!.delivery_status == "on_the_way"
                        ? 36
                        : 30,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmallExtra),
                      border: Border.all(color: Colors.amber, width: 2),

                      //shape: BoxShape.rectangle,
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                        height: 1.0,
                        width: MediaQuery.sizeOf(context).width * .4,
                        color: MyTheme.medium_grey_50),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmallExtra,
                    ),
                    child: Text(
                      'on_the_way_ucf'.tr(context: context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: MyTheme.font_grey),
                    ),
                  )
                ],
              ),
            ),
            indicatorStyle: IndicatorStyle(
              color: _stepIndex >= 2 ? Colors.green : MyTheme.medium_grey,
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingSmallExtra),
              iconStyle: _stepIndex >= 2
                  ? IconStyle(
                      color: Colors.white, iconData: Icons.check, fontSize: 16)
                  : null,
            ),
            beforeLineStyle: _stepIndex >= 2
                ? const LineStyle(
                    color: Colors.green,
                    thickness: 5,
                  )
                : const LineStyle(
                    color: MyTheme.medium_grey,
                    thickness: 4,
                  ),
            afterLineStyle: _stepIndex >= 5
                ? const LineStyle(
                    color: Colors.green,
                    thickness: 5,
                  )
                : const LineStyle(
                    color: MyTheme.medium_grey,
                    thickness: 4,
                  ),
          ),
          TimelineTile(
            axis: TimelineAxis.vertical,
            alignment: TimelineAlign.end,
            isLast: true,
            startChild: Container(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width:
                        _orderDetails!.delivery_status == "delivered" ? 36 : 30,
                    height:
                        _orderDetails!.delivery_status == "delivered" ? 36 : 30,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmallExtra),
                      border: Border.all(color: Colors.purple, width: 2),

                      //shape: BoxShape.rectangle,
                    ),
                    child: const Icon(
                      Icons.done_all,
                      color: Colors.purple,
                      size: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                        height: 1.0,
                        width: MediaQuery.sizeOf(context).width * .4,
                        color: MyTheme.medium_grey_50),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmallExtra,
                    ),
                    child: Text(
                      'delivered_ucf'.tr(context: context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: MyTheme.font_grey),
                    ),
                  )
                ],
              ),
            ),
            indicatorStyle: IndicatorStyle(
              color: _stepIndex >= 5 ? Colors.green : MyTheme.medium_grey,
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingSmallExtra),
              iconStyle: _stepIndex >= 5
                  ? IconStyle(
                      color: Colors.white, iconData: Icons.check, fontSize: 16)
                  : null,
            ),
            beforeLineStyle: _stepIndex >= 5
                ? const LineStyle(
                    color: Colors.green,
                    thickness: 5,
                  )
                : const LineStyle(
                    color: MyTheme.medium_grey,
                    thickness: 4,
                  ),
          ),
        ],
      ),
    );
  }

  Container buildOrderDetailsTopCard() {
    return Container(
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'order_code_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  'shipping_method_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Row(
                children: [
                  Text(
                    _orderDetails!.code!,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    _orderDetails!.shipping_type_string!,
                    style: const TextStyle(
                      color: MyTheme.grey_153,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  'order_date_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  'payment_method_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Row(
                children: [
                  Text(
                    _orderDetails!.date!,
                    style: const TextStyle(
                      color: MyTheme.grey_153,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _orderDetails!.payment_type!,
                    style: const TextStyle(
                      color: MyTheme.grey_153,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  'payment_status_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  'delivery_status_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8.0),
                    child: Text(
                      _orderDetails!.payment_status_string!,
                      style: TextStyle(
                        color: _orderDetails?.paymentStatus?.color,
                      ),
                    ),
                  ),
                  buildPaymentStatusCheckContainer(
                      _orderDetails!.paymentStatus),
                  const Spacer(),
                  Text(
                    _orderDetails!.delivery_status_string!,
                    style: const TextStyle(
                      color: MyTheme.grey_153,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  _orderDetails!.shipping_address != null
                      ? 'shipping_address_ucf'.tr(context: context)
                      : 'pickup_point_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  'total_amount_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _orderDetails!.shipping_address != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AddressText(
                                title: 'name_ucf'.tr(context: context),
                                body: _orderDetails?.shipping_address?.name,
                              ),
                              _AddressText(
                                title: 'email_ucf'.tr(context: context),
                                body: _orderDetails?.shipping_address?.email,
                              ),
                              _AddressText(
                                title: 'address_ucf'.tr(context: context),
                                body: _orderDetails?.shipping_address?.address,
                              ),
                              _AddressText(
                                title: 'city_ucf'.tr(context: context),
                                body: _orderDetails?.shipping_address?.city,
                              ),
                              _AddressText(
                                title: 'state_ucf'.tr(context: context),
                                body: _orderDetails?.shipping_address?.state,
                              ),
                              _AddressText(
                                title: 'country_ucf'.tr(context: context),
                                body: _orderDetails?.shipping_address?.country,
                              ),
                              _AddressText(
                                title: 'phone_ucf'.tr(context: context),
                                body: _orderDetails?.shipping_address?.phone,
                              ),
                              _AddressText(
                                title: 'postal_code'.tr(context: context),
                                body: _orderDetails
                                    ?.shipping_address?.postal_code,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AddressText(
                                title: 'name_ucf'.tr(context: context),
                                body: _orderDetails?.pickupPoint?.name,
                              ),
                              _AddressText(
                                title: 'address_ucf'.tr(context: context),
                                body: _orderDetails?.pickupPoint?.address,
                              ),
                              _AddressText(
                                title: 'phone_ucf'.tr(context: context),
                                body: _orderDetails?.pickupPoint?.phone,
                              ),
                            ],
                          ),
                  ),
                  const Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        convertPrice(_orderDetails!.grand_total!),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      if (_orderedItemList.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Btn.basic(
                          minWidth: 60,
                          onPressed: () {
                            _onPressReorder(_orderDetails!.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSmall),
                                border: Border.all(color: MyTheme.light_grey)),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.refresh,
                                  color: MyTheme.grey_153,
                                  size: 16,
                                ),
                                Text(
                                  're_order_ucf'.tr(context: context),
                                  style: const TextStyle(
                                      color: MyTheme.grey_153, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppDimensions.paddingSmall),
                      DownloadBill(orderId: _orderDetails?.id ?? -1),
                    ],
                  ),
                ],
              ),
            ),
            if (_orderDetails!.delivery_status == "pending" &&
                _orderDetails!.paymentStatus == PaymentStatusEnum.unpaid)
              Btn.basic(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minWidth: DeviceInfo(context).width,
                  color: MyTheme.font_grey,
                  onPressed: () {
                    _showCancelDialog(_orderDetails!.id);
                  },
                  child: Text(
                    'cancel_order_ucf'.tr(context: context),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  )),
            if (_orderDetails!.delivery_status == "pending" &&
                _orderDetails!.paymentStatus == PaymentStatusEnum.unpaid)
              Btn.basic(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minWidth: DeviceInfo(context).width,
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    // _showCancelDialog(_orderDetails!.id);
                    _make_re_payment(_orderDetails!.grand_total ?? '');
                  },
                  child: Text(
                    'order_repayment'.tr(context: context),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  )),
          ],
        ),
      ),
    );
  }

  Container buildOrderedProductItemsCard(index) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Text(
                _orderedItemList[index].product_name ?? '',
                maxLines: 2,
                textDirection:
                    (_orderedItemList[index].product_name ?? '').direction,
                style: const TextStyle(
                  color: MyTheme.font_grey,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Row(
                children: [
                  Text(
                    _orderedItemList[index].quantity.toString() + " x ",
                    style: const TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  _orderedItemList[index].variation != "" &&
                          _orderedItemList[index].variation != null
                      ? Text(
                          _orderedItemList[index].variation!,
                          style: const TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        )
                      : Text(
                          'item_all_lower'.tr(context: context),
                          style: const TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                  const Spacer(),
                  Text(
                    convertPrice(_orderedItemList[index].price ?? '0'),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            _orderedItemList[index].refund_section == true &&
                    _orderedItemList[index].refund_button == true
                ? InkWell(
                    onTap: () {
                      onTapAskRefund(
                          _orderedItemList[index].id,
                          _orderedItemList[index].product_name,
                          _orderDetails!.code);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'ask_for_refund_ucf'.tr(context: context),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Icon(
                              Icons.rotate_left,
                              color: Theme.of(context).primaryColor,
                              size: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : emptyWidget,
            _orderedItemList[index].refund_section == true &&
                    _orderedItemList[index].refund_label != ""
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'refund_status_ucf'.tr(context: context),
                            style: const TextStyle(color: MyTheme.font_grey),
                          ),
                          Text(
                            _orderedItemList[index].refund_label ?? '',
                            style: TextStyle(
                                color: getRefundRequestLabelColor(
                                    _orderedItemList[index]
                                        .refund_request_status)),
                          ),
                        ],
                      ),
                    ],
                  )
                : emptyWidget
          ],
        ),
      ),
    );
  }

  Color getRefundRequestLabelColor(status) {
    if (status == 0) {
      return Colors.blue;
    } else if (status == 2) {
      return Colors.orange;
    } else if (status == 1) {
      return Colors.green;
    } else {
      return MyTheme.font_grey;
    }
  }

  Container buildOrderdProductList() {
    return Container(
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) =>
              const Divider(color: MyTheme.medium_grey),
          itemCount: prescriptionOrder != null
              ? _orderedItemList.length + 1
              : _orderedItemList.length,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          reverse: true,
          itemBuilder: (context, index) {
            if (index == _orderedItemList.length) {
              return PrescriptionCard(
                canAddMore: false,
                padding: EdgeInsets.zero,
                images: prescriptionOrder?.prescriptionImages ?? [],
              );
            }
            return buildOrderedProductItemsCard(index);
          },
        ),
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
            onPressed: () {
              if (widget.from_notification || widget.go_back == false) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const Main();
                }));
              } else {
                return Navigator.pop(context);
              }
            }),
      ),
      title: Text(
        'order_details_ucf'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Padding buildPaymentButtonSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _orderDetails != null && _orderDetails!.manually_payable!
              ? Btn.basic(
                  color: MyTheme.soft_accent_color,
                  child: Text(
                    'make_offline_payment_ucf'.tr(context: context),
                    style: const TextStyle(color: MyTheme.font_grey),
                  ),
                  onPressed: () {
                    onPressOfflinePaymentButton();
                  },
                )
              : emptyWidget,
        ],
      ),
    );
  }

  Container buildPaymentStatusCheckContainer(PaymentStatusEnum? paymentStatus) {
    return Container(
      height: 16,
      width: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
          color: paymentStatus?.color),
      child: Icon(paymentStatus?.icon, color: Colors.white, size: 10),
    );
  }
}

class _AddressText extends StatelessWidget {
  const _AddressText({
    required this.title,
    required this.body,
  });
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    if (body?.trim().isNotEmpty != true) return const SizedBox.shrink();
    return Text(
      "$title: $body",
      maxLines: 3,
      style: const TextStyle(color: MyTheme.grey_153),
    );
  }
}
