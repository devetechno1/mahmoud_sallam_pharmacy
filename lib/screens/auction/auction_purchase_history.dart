import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_config.dart';
import '../../custom/device_info.dart';
import '../../custom/toast_component.dart';
import '../../custom/useful_elements.dart';
import '../../helpers/main_helpers.dart';
import '../../helpers/shared_value_helper.dart';
import '../../my_theme.dart';
import '../../repositories/auction_products_repository.dart';
import '../orders/order_details.dart';

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
      DeliveryStatus('confirmed', 'confirmed_ucf'.tr()),
      DeliveryStatus('on_the_way', 'on_the_way_ucf'.tr()),
      DeliveryStatus('delivered', 'delivered_ucf'.tr()),
    ];
  }
}

class AuctionPurchaseHistory extends StatefulWidget {
  const AuctionPurchaseHistory({Key? key}) : super(key: key);

  @override
  State<AuctionPurchaseHistory> createState() => _AuctionPurchaseHistoryState();
}

class _AuctionPurchaseHistoryState extends State<AuctionPurchaseHistory> {
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0);
  int _page = 1;
  bool _isDataFetch = false;
  bool _showMoreProductLoadingContainer = false;
  List _purchaseList = [];
  String _defaultPaymentStatusKey = '';
  String _defaultDeliveryStatusKey = '';

  final List<PaymentStatus> _paymentStatusList =
      PaymentStatus.getPaymentStatusList();
  final List<DeliveryStatus> _deliveryStatusList =
      DeliveryStatus.getDeliveryStatusList();

  PaymentStatus? _selectedPaymentStatus;
  DeliveryStatus? _selectedDeliveryStatus;

  List<DropdownMenuItem<PaymentStatus>>? _dropdownPaymentStatusItems;
  List<DropdownMenuItem<DeliveryStatus>>? _dropdownDeliveryStatusItems;

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

  resetFilterKeys() {
    _defaultPaymentStatusKey = '';
    _defaultDeliveryStatusKey = '';

    setState(() {});
  }

  Future<void> _onRefresh() async {
    cleanAll();
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
    fetchAll();
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

  cleanAll() {
    _isDataFetch = false;
    _showMoreProductLoadingContainer = false;
    _purchaseList = [];
    _page = 1;

    setState(() {});
  }

  getPurchaseList() async {
    final purchaseListResponse = await AuctionProductsRepository()
        .getAuctionPurchaseHistory(
            page: _page,
            payment_status: _selectedPaymentStatus!.option_key,
            delivery_status: _selectedDeliveryStatus!.option_key);
    if (purchaseListResponse.data!.isEmpty) {
      ToastComponent.showDialog(
        'no_data_is_available'.tr(context: context),
      );
    }
    _purchaseList.addAll(purchaseListResponse.data!);
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
          print(_page);
          _page++;
        });
        getPurchaseList();
      }
    });
  }

  fetchAll() {
    getPurchaseList();
    setState(() {});
  }

  @override
  void initState() {
    init();
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
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        // body: buildAuctionPurchaseList(),
        body: buildAuctionPurchaseList(),
      ),
    );
  }

  RefreshIndicator buildAuctionPurchaseList() {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: MyTheme.mainColor,
      displacement: 0,
      onRefresh: _onRefresh,
      child: !_isDataFetch
          ? buildOrderShimmer()
          : CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: _purchaseList.isNotEmpty
                      ? ListView.separated(
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 14,
                            );
                          },
                          padding: const EdgeInsets.only(
                            top: 3,
                            left: 20,
                            right: 20,

                            /// this is from bottom bar
                            // ignore: dead_code
                            bottom: false ? 95 : 15,
                          ),
                          itemCount: _purchaseList.length + 1,
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(
                              parent: NeverScrollableScrollPhysics()),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (index == _purchaseList.length) {
                              return moreProductLoading();
                            }
                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return OrderDetails(
                                      id: _purchaseList[index].id,
                                    );
                                  }));
                                },
                                child: buildOrderListItemCard(index));
                          },
                        )
                      : SizedBox(
                          height: DeviceInfo(context).width! -
                              (AppBar().preferredSize.height + 75),
                          child: Center(
                            child: Text(
                                'no_data_is_available'.tr(context: context)),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  // Widget buildOrderListItemCard(int index) {
  //   return MyWidget.customCardView(
  //     alignment: Alignment.center,
  //     backgroundColor: MyTheme.white,
  //     width: DeviceInfo(context).width!,
  //     elevation: 0.0,
  //     borderRadius: 10,
  //     height: 103,
  //     borderColor: MyTheme.white,
  //     borderWidth: 1,
  //     child: Padding(
  //       padding: const EdgeInsets.fromLTRB(12, 14, 21, 12),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.only(bottom: AppDimensions.paddingsmall),
  //                 child: Text(
  //                   _purchaseList[index].code!,
  //                   style: const TextStyle(
  //                       color: MyTheme.accent_color,
  //                       fontSize: 13,
  //                       fontWeight: FontWeight.bold),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(bottom: 0.0),
  //                 child: Row(
  //                   children: [
  //                     Padding(
  //                       padding: app_language_rtl.$!
  //                           ? const EdgeInsets.only(left: AppDimensions.paddingsmall)
  //                           : const EdgeInsets.only(right: 8.0),
  //                       // child: const Icon(
  //                       //   Icons.calendar_today_outlined,
  //                       //   size: 16,
  //                       //   color: MyTheme.font_grey,
  //                       // ),
  //                     ),
  //                     Text(_purchaseList[index].date!,
  //                         style: const TextStyle(
  //                             color: MyTheme.font_grey,
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.w400)),
  //                   ],
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.only(bottom: AppDimensions.paddingsmallExtra),
  //                 child: Row(
  //                   children: [
  //                     Padding(
  //                       padding: app_language_rtl.$!
  //                           ? const EdgeInsets.only(left: AppDimensions.paddingsmall)
  //                           : const EdgeInsets.only(right: 8.0),
  //                       // child: const Icon(
  //                       //   Icons.credit_card,
  //                       //   size: 16,
  //                       //   color: MyTheme.font_grey,
  //                       // ),
  //                     ),
  //                     Text(
  //                         "${'payment_status_ucf'.tr(context: context)} - ",
  //                         style: const TextStyle(
  //                             color: MyTheme.font_grey,
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.w400)),
  //                     Text(
  //                       _purchaseList[index]
  //                           .paymentStatus
  //                           .toString()
  //                           .replaceRange(
  //                               0,
  //                               1,
  //                               _purchaseList[index]
  //                                   .paymentStatus
  //                                   .toString()
  //                                   .characters
  //                                   .first
  //                                   .toString()
  //                                   .toUpperCase()),
  //                       style: TextStyle(
  //                         color: _purchaseList[index].paymentStatus == "Paid"
  //                             ? Colors.green
  //                             : Colors.red,
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Row(
  //                 children: [
  //                   Padding(
  //                     padding: app_language_rtl.$!
  //                         ? const EdgeInsets.only(left: AppDimensions.paddingsmall)
  //                         : const EdgeInsets.only(right: 8.0),
  //                     // child: const Icon(
  //                     //   Icons.local_shipping_outlined,
  //                     //   size: 16,
  //                     //   color: MyTheme.font_grey,
  //                     // ),
  //                   ),
  //                   Text(
  //                       "${'delivery_status_ucf'.tr(context: context)} -",
  //                       style: const TextStyle(
  //                           color: MyTheme.font_grey,
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.w400)),
  //                   Text(_purchaseList[index].deliveryStatus!,
  //                       style: const TextStyle(
  //                           color: MyTheme.font_grey,
  //                           fontSize: 12,
  //                           fontWeight: FontWeight.w400)),
  //                 ],
  //               ),
  //             ],
  //           ),
  //           Text(
  //             convertPrice(_purchaseList[index].amount!),
  //             style: const TextStyle(
  //                 color: MyTheme.accent_color,
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget buildOrderListItemCard(int index) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 21, 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text(
                  _purchaseList[index].code!,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Row(
                  children: [
                    Padding(
                      padding: app_language_rtl.$!
                          ? const EdgeInsets.only(
                              left: AppDimensions.paddingSmall)
                          : const EdgeInsets.only(right: 8.0),
                      // child: const Icon(
                      //   Icons.calendar_today_outlined,
                      //   size: 16,
                      //   color: MyTheme.font_grey,
                      // ),
                    ),
                    Text(_purchaseList[index].date!,
                        style: const TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingSmallExtra),
                child: Row(
                  children: [
                    Padding(
                      padding: app_language_rtl.$!
                          ? const EdgeInsets.only(
                              left: AppDimensions.paddingSmall)
                          : const EdgeInsets.only(right: 8.0),
                      // child: const Icon(
                      //   Icons.credit_card,
                      //   size: 16,
                      //   color: MyTheme.font_grey,
                      // ),
                    ),
                    Text("${'payment_status_ucf'.tr(context: context)} - ",
                        style: const TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    Text(
                      _purchaseList[index]
                          .paymentStatus
                          .toString()
                          .replaceRange(
                              0,
                              1,
                              _purchaseList[index]
                                  .paymentStatus
                                  .toString()
                                  .characters
                                  .first
                                  .toString()
                                  .toUpperCase()),
                      style: TextStyle(
                        color: _purchaseList[index].paymentStatus == "Paid"
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: app_language_rtl.$!
                        ? const EdgeInsets.only(
                            left: AppDimensions.paddingSmall)
                        : const EdgeInsets.only(right: 8.0),
                    // child: const Icon(
                    //   Icons.local_shipping_outlined,
                    //   size: 16,
                    //   color: MyTheme.font_grey,
                    // ),
                  ),
                  Text("${'delivery_status_ucf'.tr(context: context)} -",
                      style: const TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                  Text(_purchaseList[index].deliveryStatus!,
                      style: const TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            ],
          ),
          Text(
            convertPrice(_purchaseList[index].amount!),
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          )
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

  Widget buildOrderShimmer() {
    return SizedBox(
      height: DeviceInfo(context).width! - (AppBar().preferredSize.height + 90),
      child: SingleChildScrollView(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: 10,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        ),
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(98.0),
      child: AppBar(
          centerTitle: false,
          backgroundColor: MyTheme.mainColor,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0.0,
          actions: const [emptyWidget],
          elevation: 0.0,
          titleSpacing: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
            child: Column(
              children: [
                Padding(
                  padding: MediaQuery.viewPaddingOf(context).top >
                          30 //MediaQuery.viewPaddingOf(context).top is the status bar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                      ? const EdgeInsets.only(
                          top: AppDimensions.paddingVeryExtraLarge)
                      : const EdgeInsets.only(top: 14.0),
                  child: buildTopAppBarContainer(),
                ),
                buildBottomAppBar(context),
              ],
            ),
          )),
    );
  }

  Padding buildBottomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusSmallExtra)),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            height: 36,
            width: MediaQuery.sizeOf(context).width * .35,
            child: DropdownButton<PaymentStatus>(
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: Colors.black54),
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
                cleanAll();
                fetchAll();
              },
            ),
          ),
          Container(
            // decoration: BoxDecorations.buildBoxDecoration_1(),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusSmallExtra)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            height: 36,
            width: MediaQuery.sizeOf(context).width * .35,
            child: DropdownButton<DeliveryStatus>(
              icon: const Icon(Icons.expand_more, color: Colors.black54),
              isExpanded: true,
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
                cleanAll();
                fetchAll();
              },
            ),
          ),
        ],
      ),
    );
  }

  Container buildTopAppBarContainer() {
    return Container(
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              padding: EdgeInsets.zero,
              icon: UsefulElements.backIcon(),
              onPressed: () {
                return Navigator.pop(context);
              },
            ),
          ),
          Text(
            'auction_purchase_history_ucf'.tr(context: context),
            style: const TextStyle(
                fontSize: 16,
                color: MyTheme.dark_font_grey,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
