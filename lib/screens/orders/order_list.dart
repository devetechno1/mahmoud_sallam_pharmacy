import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/main_helpers.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/order_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:active_ecommerce_cms_demo_app/screens/orders/order_details.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_config.dart';
import '../../data_model/order_mini_response.dart';

class PaymentStatus {
  String option_key;
  String name;

  PaymentStatus(this.option_key, this.name);

  static List<PaymentStatus> getPaymentStatusList() {
    return <PaymentStatus>[
      PaymentStatus('', 'all_ucf'.tr()),
      PaymentStatus('paid', 'paid_ucf'.tr()),
      PaymentStatus('unpaid', 'unpaid_ucf'.tr()),
    ];
  }
}

class DeliveryStatus {
  String option_key;
  String name;

  DeliveryStatus(this.option_key, this.name);

  static List<DeliveryStatus> getDeliveryStatusList() {
    return <DeliveryStatus>[
      DeliveryStatus('', 'all_ucf'.tr()),
      DeliveryStatus('pending', 'pending_ucf'.tr()),
      DeliveryStatus('confirmed', 'confirmed_ucf'.tr()),
      DeliveryStatus('picked_up', 'picked_up_ucf'.tr()),
      DeliveryStatus('on_the_way', 'on_the_way_ucf'.tr()),
      DeliveryStatus('delivered', 'delivered_ucf'.tr()),
    ];
  }
}

// case "picked_up":
//   return Colors.orangeAccent.shade200;
class OrderList extends StatefulWidget {
  const OrderList({Key? key, this.from_checkout = false}) : super(key: key);
  final bool from_checkout;

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _xcrollController = ScrollController();

  final List<PaymentStatus> _paymentStatusList =
      PaymentStatus.getPaymentStatusList();
  final List<DeliveryStatus> _deliveryStatusList =
      DeliveryStatus.getDeliveryStatusList();

  PaymentStatus? _selectedPaymentStatus;
  DeliveryStatus? _selectedDeliveryStatus;

  List<DropdownMenuItem<PaymentStatus>>? _dropdownPaymentStatusItems;
  List<DropdownMenuItem<DeliveryStatus>>? _dropdownDeliveryStatusItems;

  //------------------------------------
  final List<Order> _orderList = [];
  bool _isInitial = true;
  int _page = 1;
  int? _totalData = 0;
  bool _showLoadingContainer = false;
  String _defaultPaymentStatusKey = '';
  String _defaultDeliveryStatusKey = '';

  @override
  void initState() {
    init();
    super.initState();

    fetchData();

    _xcrollController.addListener(() {
      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
        });
        _showLoadingContainer = true;
        fetchData();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  init() {
    _dropdownPaymentStatusItems =
        buildDropdownPaymentStatusItems(_paymentStatusList);

    _dropdownDeliveryStatusItems =
        buildDropdownDeliveryStatusItems(_deliveryStatusList);

    for (int x = 0; x < _dropdownPaymentStatusItems!.length; x++) {
      if (_dropdownPaymentStatusItems![x].value!.option_key ==
          _defaultPaymentStatusKey) {
        _selectedPaymentStatus = _dropdownPaymentStatusItems![x].value;
      }
    }

    for (int x = 0; x < _dropdownDeliveryStatusItems!.length; x++) {
      if (_dropdownDeliveryStatusItems![x].value!.option_key ==
          _defaultDeliveryStatusKey) {
        _selectedDeliveryStatus = _dropdownDeliveryStatusItems![x].value;
      }
    }
  }

  reset() {
    _orderList.clear();
    _isInitial = true;
    _page = 1;
    _totalData = 0;
    _showLoadingContainer = false;
  }

  resetFilterKeys() {
    _defaultPaymentStatusKey = '';
    _defaultDeliveryStatusKey = '';

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    resetFilterKeys();
    for (int x = 0; x < _dropdownPaymentStatusItems!.length; x++) {
      if (_dropdownPaymentStatusItems![x].value!.option_key ==
          _defaultPaymentStatusKey) {
        _selectedPaymentStatus = _dropdownPaymentStatusItems![x].value;
      }
    }

    for (int x = 0; x < _dropdownDeliveryStatusItems!.length; x++) {
      if (_dropdownDeliveryStatusItems![x].value!.option_key ==
          _defaultDeliveryStatusKey) {
        _selectedDeliveryStatus = _dropdownDeliveryStatusItems![x].value;
      }
    }
    setState(() {});
    fetchData();
  }

  fetchData() async {
    final orderResponse = await OrderRepository().getOrderList(
        page: _page,
        payment_status: _selectedPaymentStatus!.option_key,
        delivery_status: _selectedDeliveryStatus!.option_key);
    //print("or:"+orderResponse.toJson().toString());
    _orderList.addAll(orderResponse.orders!);
    _isInitial = false;
    _totalData = orderResponse.meta!.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  List<DropdownMenuItem<PaymentStatus>> buildDropdownPaymentStatusItems(
      List _paymentStatusList) {
    final List<DropdownMenuItem<PaymentStatus>> items = [];
    for (PaymentStatus item in _paymentStatusList as Iterable<PaymentStatus>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(item.name),
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<DeliveryStatus>> buildDropdownDeliveryStatusItems(
      List _deliveryStatusList) {
    final List<DropdownMenuItem<DeliveryStatus>> items = [];
    for (DeliveryStatus item
        in _deliveryStatusList as Iterable<DeliveryStatus>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(item.name),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) return goBack();
          // Provider.of<CartProvider>(context, listen: false).onRefresh(context);
        },
        child: Directionality(
          textDirection:
              app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
              backgroundColor: MyTheme.mainColor,
              appBar: buildAppBar(context),
              body: Stack(
                children: [
                  buildOrderListList(),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: buildLoadingContainer())
                ],
              )),
        ));
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _orderList.length
            ? 'no_more_orders_ucf'.tr(context: context)
            : 'loading_more_orders_ucf'.tr(context: context)),
      ),
    );
  }

  Padding buildBottomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecorations.buildBoxDecoration_1(),
            height: 34,
            width: MediaQuery.sizeOf(context).width * .4,
            child: DropdownButton<PaymentStatus>(
              dropdownColor: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusHalfSmall),
              icon: const Icon(Icons.expand_more, color: Colors.black54),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              hint: Text(
                'all_payments_ucf'.tr(context: context),
                style: const TextStyle(
                  color: MyTheme.font_grey,
                  fontSize: 12,
                ),
              ),
              iconSize: 14,
              underline: emptyWidget,
              value: _selectedPaymentStatus,
              items: _dropdownPaymentStatusItems,
              onChanged: (PaymentStatus? selectedFilter) {
                setState(() {
                  _selectedPaymentStatus = selectedFilter;
                });
                reset();
                fetchData();
              },
            ),
          ),
          Container(
            decoration: BoxDecorations.buildBoxDecoration_1(),
            height: 34,
            width: MediaQuery.sizeOf(context).width * .4,
            child: DropdownButton<DeliveryStatus>(
              dropdownColor: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusHalfSmall),
              icon: const Icon(Icons.expand_more, color: Colors.black54),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              hint: Text(
                'all_deliveries_ucf'.tr(context: context),
                style: const TextStyle(
                  color: MyTheme.font_grey,
                  fontSize: 12,
                ),
              ),
              iconSize: 14,
              underline: emptyWidget,
              value: _selectedDeliveryStatus,
              items: _dropdownDeliveryStatusItems,
              onChanged: (DeliveryStatus? selectedFilter) {
                setState(() {
                  _selectedDeliveryStatus = selectedFilter;
                });
                reset();
                fetchData();
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(104.0),
      child: AppBar(
          centerTitle: false,
          backgroundColor: MyTheme.mainColor,
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: false,
          actions: const [emptyWidget],
          elevation: 0.0,
          titleSpacing: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: MediaQuery.viewPaddingOf(context).top >
                          30 //MediaQuery.viewPaddingOf(context).top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                      ? const EdgeInsets.only(
                          top: AppDimensions.paddingVeryExtraLarge)
                      : const EdgeInsets.only(top: 14.0),
                  child: buildTopAppBarContainer(),
                ),
                buildBottomAppBar(context)
              ],
            ),
          )),
    );
  }

  void goBack() {
    if (widget.from_checkout) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const Main();
      }));
    } else {
      return Navigator.pop(context);
    }
  }

  Widget buildTopAppBarContainer() {
    return Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            padding: EdgeInsets.zero,
            icon: UsefulElements.backIcon(),
            onPressed: goBack,
          ),
        ),
        Text(
          'purchase_history_ucf'.tr(context: context),
          style: const TextStyle(
              fontSize: 16,
              color: MyTheme.dark_font_grey,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildOrderListList() {
    if (_isInitial && _orderList.isEmpty) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: 10,
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
            child: Shimmer.fromColors(
              baseColor: MyTheme.shimmer_base,
              highlightColor: MyTheme.shimmer_highlighted,
              child: Container(
                height: 75,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          );
        },
      );
    } else if (_orderList.isNotEmpty) {
      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        displacement: 0,
        onRefresh: _onRefresh,
        child: ListView.separated(
          controller: _xcrollController,
          separatorBuilder: (context, index) => const SizedBox(
            height: 14,
          ),
          padding: const EdgeInsets.only(
            left: AppDimensions.paddingMedium,
            right: AppDimensions.paddingMedium,
            top: 10,
            bottom: 0,
          ),
          itemCount: _orderList.length,
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return OrderDetails(
                    id: _orderList[index].id,
                  );
                }));
              },
              child: buildOrderListItemCard(index),
            );
          },
        ),
      );
    } else if (_totalData == 0) {
      return Center(child: Text('no_data_is_available'.tr(context: context)));
    } else {
      return emptyWidget; // should never be happening
    }
  }

  Container buildOrderListItemCard(int index) {
    return Container(
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Text(
                _orderList[index].code!,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingSmallExtra),
              child: Row(
                children: [
                  Text(_orderList[index].date!,
                      style: const TextStyle(
                          color: MyTheme.dark_font_grey, fontSize: 12)),
                  const Spacer(),
                  Text(
                    convertPrice(_orderList[index].grand_total!),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingSmallExtra),
              child: Row(
                children: [
                  Text(
                    "${'payment_status_ucf'.tr(context: context)} - ",
                    style: const TextStyle(
                        color: MyTheme.dark_font_grey, fontSize: 12),
                  ),
                  Text(
                    _orderList[index].payment_status_string!,
                    style: TextStyle(
                        color: _orderList[index].paymentStatus?.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  "${'delivery_status_ucf'.tr(context: context)} -",
                  style: const TextStyle(
                      color: MyTheme.dark_font_grey, fontSize: 12),
                ),
                Text(
                  _orderList[index].delivery_status_string!,
                  style: TextStyle(
                      color: _orderList[index].deliveryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Container buildPaymentStatusCheckContainer(String paymentStatus) {
    return Container(
      height: 16,
      width: 16,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
          color: paymentStatus == "paid" ? Colors.green : Colors.red),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmallExtra),
        child: Icon(paymentStatus == "paid" ? Icons.check : Icons.check,
            color: Colors.white, size: 10),
      ),
    );
  }
}
