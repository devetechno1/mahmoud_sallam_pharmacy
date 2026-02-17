import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/enum_classes.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/reg_ex_inpur_formatter.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/wallet_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/checkout/checkout.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:flutter/material.dart';

import '../helpers/main_helpers.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key, this.from_recharge = false}) : super(key: key);
  final bool from_recharge;

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');
  final ScrollController _mainScrollController = ScrollController();
  final TextEditingController _amountController = TextEditingController();

  GlobalKey appBarKey = GlobalKey();

  dynamic _balanceDetails = null;

  final List<dynamic> _rechargeList = [];
  bool _rechargeListInit = true;
  int _rechargePage = 1;
  int? _totalRechargeData = 0;
  bool _showRechageLoadingContainer = false;

  @override
  void initState() {
    super.initState();
    fetchAll();
    _mainScrollController.addListener(() {
      if (_mainScrollController.position.pixels ==
          _mainScrollController.position.maxScrollExtent) {
        setState(() {
          _rechargePage++;
        });
        _showRechageLoadingContainer = true;
        fetchRechargeList();
      }
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  fetchAll() {
    fetchBalanceDetails();
    fetchRechargeList();
  }

  fetchBalanceDetails() async {
    final balanceDetailsResponse = await WalletRepository().getBalance();

    _balanceDetails = balanceDetailsResponse;

    setState(() {});
  }

  fetchRechargeList() async {
    final rechageListResponse =
        await WalletRepository().getRechargeList(page: _rechargePage);

    if (rechageListResponse.result) {
      _rechargeList.addAll(rechageListResponse.recharges);
      _totalRechargeData = rechageListResponse.meta.total;
    } else {}
    _rechargeListInit = false;
    _showRechageLoadingContainer = false;

    setState(() {});
  }

  reset() {
    _balanceDetails = null;
    _rechargeList.clear();
    _rechargeListInit = true;
    _rechargePage = 1;
    _totalRechargeData = 0;
    _showRechageLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  void onPressProceed() {
    final amountString = _amountController.text.toString();

    if (amountString == "") {
      ToastComponent.showDialog(
        'amount_cannot_be_empty'.tr(context: context),
      );
      return;
    }

    final amount = double.parse(amountString);

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Checkout(
        paymentFor: PaymentFor.WalletRecharge,
        rechargeAmount: amount,
        title: 'recharge_wallet_ucf'.tr(context: context),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.from_recharge) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Main();
          }));
        } else {
          Navigator.pop(context);
        }
        return Future.delayed(Duration.zero);
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: MyTheme.mainColor,
          appBar: buildAppBar(context),
          body: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: MyTheme.mainColor,
            onRefresh: _onPageRefresh,
            displacement: 10,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: MyTheme.mainColor,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 0.0, left: 16.0, right: 16.0),
                    child: _balanceDetails != null
                        ? buildTopSection(context)
                        : ShimmerHelper().buildBasicShimmer(height: 150),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100.0, bottom: 0.0),
                  child: buildRechargeList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showRechageLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalRechargeData == _rechargeList.length
            ? 'no_more_histories_ucf'.tr(context: context)
            : 'loading_more_histories_ucf'.tr(context: context)),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      key: appBarKey,
      backgroundColor: MyTheme.mainColor,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: UsefulElements.backButton(),
          onPressed: () {
            if (widget.from_recharge) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Main();
              }));
            } else {
              return Navigator.pop(context);
            }
          },
        ),
      ),
      title: Text(
        'my_wallet_ucf'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget buildRechargeList() {
    if (_rechargeListInit && _rechargeList.isEmpty) {
      return SingleChildScrollView(child: buildRechargeListShimmer());
    } else if (_rechargeList.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: AppDimensions.paddingDefault,
                  bottom: AppDimensions.paddingDefault,
                  left: AppDimensions.paddingDefault),
              child: Text(
                'wallet_recharge_history_ucf'.tr(context: context),
                style: const TextStyle(
                    color: MyTheme.dark_font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
            ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _rechargeList.length,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingNormal),
                  child: buildRechargeListItemCard(index),
                );
              },
            ),
          ],
        ),
      );
    } else if (_totalRechargeData == 0) {
      return Center(child: Text('no_recharges_yet'.tr(context: context)));
    } else {
      return emptyWidget; // should never be happening
    }
  }

  Column buildRechargeListShimmer() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: ShimmerHelper().buildBasicShimmer(height: 75.0),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: ShimmerHelper().buildBasicShimmer(height: 75.0),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: ShimmerHelper().buildBasicShimmer(height: 75.0),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: ShimmerHelper().buildBasicShimmer(height: 75.0),
        )
      ],
    );
  }

///////////////////////////////////////////////////////main Container///////////////////////////////////////////////
  Widget buildRechargeListItemCard(int index) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
      margin:
          const EdgeInsets.symmetric(horizontal: AppDimensions.paddingDefault),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingNormal),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 40,
                child: Text(
                  getFormattedRechargeListIndex(index),
                  style: const TextStyle(
                      color: MyTheme.dark_font_grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                )),
            Container(
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _rechargeList[index].date,
                      style: const TextStyle(
                        color: MyTheme.dark_font_grey,
                        fontSize: 12,
                      ),
                    ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    Text(
                      'payment_method_ucf'.tr(context: context),
                      style: const TextStyle(
                          color: MyTheme.dark_font_grey, fontSize: 12),
                    ),
                    Text(
                      _rechargeList[index].payment_method,
                      style: const TextStyle(
                          color: MyTheme.dark_font_grey, fontSize: 12),
                    ),
                  ],
                )),
            const Spacer(),
            Container(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    convertPrice(_rechargeList[index].amount),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _rechargeList[index].approval_string,
                    style: const TextStyle(
                      color: MyTheme.dark_grey,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String getFormattedRechargeListIndex(int index) {
    final int num = index + 1;
    final txt = num.toString().length == 1
        ? "# 0" + num.toString()
        : "#" + num.toString();
    return txt;
  }

// Top Part Container
  Widget buildTopSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: DeviceInfo(context).width! / 2.3,
          height: 90,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusNormal)),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: AppDimensions.paddingDefault),
                child: Text(
                  'wallet_balance_ucf'.tr(context: context),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  convertPrice(_balanceDetails.balance),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Text(
                "${'last_recharged'.tr(context: context)} : ${_balanceDetails.last_recharged}",
                style: const TextStyle(
                  color: MyTheme.light_grey,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer()
            ],
          ),
        ),
        Container(
          width: DeviceInfo(context).width! / 2.3,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xffFEF0D7), // Background color
            border: Border.all(color: Colors.amber.shade700, width: 1),
            borderRadius: BorderRadius.circular(
                AppDimensions.radiusNormal), // Set border radius here
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                10), // Clip the child to the same border radius
            child: Btn.basic(
              minWidth: MediaQuery.sizeOf(context).width,
              color: MyTheme.amber,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(5.0)), // Adjust if needed
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${'recharge_wallet_ucf'.tr(context: context)}",
                    style: const TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Image.asset(
                    AppImages.add,
                    height: 20,
                    width: 20,
                  ),
                ],
              ),
              onPressed: () {
                buildShowAddFormDialog(context);
              },
            ),
          ),
        )
      ],
    );
  }

///////////   AlartDialog  ///////
  Future buildShowAddFormDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 10),
          contentPadding: const EdgeInsets.only(
              top: 36.0, left: 20.0, right: 22.0, bottom: 2.0),
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
                    child: Text('amount_ucf'.tr(context: context),
                        style: const TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Container(
                      height: 40,
                      child: TextField(
                        controller: _amountController,
                        autofocus: false,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [_amountValidator],
                        decoration: InputDecoration(
                            fillColor: MyTheme.light_grey,
                            filled: true,
                            hintText: 'enter_amount_ucf'.tr(context: context),
                            hintStyle: const TextStyle(
                                fontSize: 12.0, color: MyTheme.textfield_grey),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: MyTheme.noColor, width: 0.0),
                              borderRadius: BorderRadius.all(
                                Radius.circular(AppDimensions.radiusSmall),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: MyTheme.noColor, width: 0.0),
                              borderRadius: BorderRadius.all(
                                Radius.circular(AppDimensions.radiusSmall),
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8.0)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //  Expanded(child: SizedBox()),
                Btn.minWidthFixHeight(
                  minWidth: 75,
                  height: 30,
                  color: const Color.fromRGBO(253, 253, 253, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusHalfSmall),
                      side: BorderSide(
                          color: Theme.of(context).primaryColor, width: 1.0)),
                  child: Text(
                    'close_ucf'.tr(context: context),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                const SizedBox(
                  width: 14,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Btn.minWidthFixHeight(
                    minWidth: 75,
                    height: 30,
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusHalfSmall),
                    ),
                    child: Text(
                      'proceed_ucf'.tr(context: context),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.normal),
                    ),
                    onPressed: () {
                      onPressProceed();
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
