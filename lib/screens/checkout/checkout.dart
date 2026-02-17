import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/enum_classes.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/cart_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/coupon_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/payment_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/orders/order_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/amarpay_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/bkash_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/flutterwave_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/iyzico_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/khalti_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/my_fatoora_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/nagad_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/offline_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/online_pay.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/payfast_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/paypal_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/paystack_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/paytm_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/phonepay_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/razorpay_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/sslcommerz_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/payment_method_screen/stripe_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';

import '../../app_config.dart';
import '../../custom/loading.dart';
import '../../data_model/order_detail_response.dart';
import '../../data_model/payment_type_response.dart';
import '../../helpers/auth_helper.dart';
import '../../repositories/guest_checkout_repository.dart';
import '../../repositories/order_repository.dart';
import '../guest_checkout_pages/guest_checkout_address.dart';
import '../payment_method_screen/main_payment_screen.dart';

class Checkout extends StatefulWidget {
  final int?
      order_id; // only need when making manual payment from order details
  final String list;
  final PaymentFor? paymentFor;
  final double rechargeAmount;
  final String? title;
  final packageId;
  final String? guestCheckOutShippingAddress;

  const Checkout({
    Key? key,
    this.guestCheckOutShippingAddress,
    this.order_id = 0,
    this.paymentFor,
    this.list = "both",
    this.rechargeAmount = 0.0,
    this.title,
    this.packageId = 0,
  }) : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _selected_payment_method_index = 0;
  String _selected_payment_method = "";
  String? _selected_payment_method_key = "";
  String subPaymentOption = '';

  final ScrollController _mainScrollController = ScrollController();
  final TextEditingController _couponController = TextEditingController();
  final List<PaymentTypeResponse> _paymentTypeList = [];
  bool _isInitial = true;
  String? _totalString = ". . .";
  double? _grandTotalValue = 0.00;
  String? _subTotalString = ". . .";
  String? _taxString = ". . .";
  String _shippingCostString = ". . .";
  String? _discountString = ". . .";
  String _used_coupon_code = "";
  bool? _coupon_applied = false;
  BuildContext? loadingcontext;
  String payment_type = "cart_payment";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchAll();

    print('recharge amount: ${widget.rechargeAmount}');
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
    _couponController.dispose();
  }

  String balance() {
    String? balance;

    // Setting balance based on paymentFor conditions
    if (widget.paymentFor == PaymentFor.ManualPayment ||
        widget.paymentFor == PaymentFor.OrderRePayment) {
      balance = widget.rechargeAmount.toString();
    }
    if (SystemConfig.systemCurrency != null) {
      balance = _totalString?.replaceAll(SystemConfig.systemCurrency!.code!,
          SystemConfig.systemCurrency!.symbol!);
    } else {
      balance = _totalString;
    }

    // Remove any non-numeric characters, except for a decimal point.
    balance = balance?.replaceAll(RegExp(r'[^\d.]'), '').trim();

    // Check if balance is a valid number before parsing
    if (balance == null || balance.isEmpty) {
      print("balance is invalid or empty");
      return '';
    }

    // Safely parse balance to a double
    setState(() {
      _grandTotalValue = double.tryParse(balance!) ?? 0.0;
    });

    print("balance: $balance");
    return balance;
  }

  void fetchAll() {
    fetchList();
    fetchSummary();
    if (widget.paymentFor != PaymentFor.Order) {
      _grandTotalValue = widget.rechargeAmount;

      if (widget.paymentFor == PaymentFor.OrderRePayment) {
        payment_type = 'order_re_payment';
      } else {
        payment_type = widget.paymentFor == PaymentFor.WalletRecharge
            ? "wallet_payment"
            : "customer_package_payment";
      }
    } else {}
  }

  fetchList() async {
    String mode = '';
    setState(() {
      mode = widget.paymentFor != PaymentFor.Order &&
              widget.paymentFor != PaymentFor.ManualPayment
          ? "wallet"
          : "order";
    });

    final paymentTypeResponseList = await PaymentRepository()
        .getPaymentResponseList(list: widget.list, mode: mode);

    _paymentTypeList.addAll(paymentTypeResponseList);
    if (_paymentTypeList.isNotEmpty) {
      _selected_payment_method = _paymentTypeList[0].payment_type ?? '';
      _selected_payment_method_key = _paymentTypeList[0].payment_type_key;
    }
    _isInitial = false;
    setState(() {});
  }

  Future<void> fetchSummary() async {
    print('in fetch summery');
    if (widget.paymentFor == PaymentFor.ManualPayment ||
        widget.paymentFor == PaymentFor.OrderRePayment) {
      final OrderDetailResponse? orderDetailsResponse =
          await OrderRepository().getOrderDetails(id: widget.order_id);

      final DetailedOrder? details =
          orderDetailsResponse?.detailed_orders?.firstOrNull;

      if (details != null) {
        _subTotalString = details.subtotal;
        _taxString = details.tax;
        _shippingCostString = details.shipping_cost ?? '';
        _discountString = details.coupon_discount;
        _totalString = details.grand_total;
        _grandTotalValue = double.tryParse(details.grand_total ?? '');
        _used_coupon_code = details.coupon_discount ?? _used_coupon_code;
        _couponController.text = _used_coupon_code;
        _coupon_applied = details.coupon_discount != null;
        setState(() {});
      }

      return;
    }

    final cartSummaryResponse = await CartRepository().getCartSummaryResponse();
    if (!mounted) return;

    if (cartSummaryResponse != null) {
      _subTotalString = cartSummaryResponse.sub_total;
      _taxString = cartSummaryResponse.tax;
      _shippingCostString = cartSummaryResponse.shipping_cost;
      _discountString = cartSummaryResponse.discount;
      _totalString = cartSummaryResponse.grand_total;
      _grandTotalValue = cartSummaryResponse.grand_total_value;
      _used_coupon_code = cartSummaryResponse.coupon_code ?? _used_coupon_code;
      _couponController.text = _used_coupon_code;
      _coupon_applied = cartSummaryResponse.coupon_applied;
      setState(() {});
    }
  }

  reset() {
    _paymentTypeList.clear();
    _isInitial = true;
    _selected_payment_method_index = 0;
    _selected_payment_method = "";
    _selected_payment_method_key = "";
    setState(() {});

    reset_summary();
  }

  reset_summary() {
    _totalString = ". . .";
    _grandTotalValue = 0.00;
    _subTotalString = ". . .";
    _taxString = ". . .";
    _shippingCostString = ". . .";
    _discountString = ". . .";
    _used_coupon_code = "";
    _couponController.text = _used_coupon_code;
    _coupon_applied = false;

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  Future<void> onPopped(value) async {
    if (value == true) {
      ToastComponent.showDialog(
        'payment_cancelled_ucf'.tr(context: context),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const OrderList(from_checkout: true);
      }));
      return;
    }
    reset();
    fetchAll();
  }

  Future<void> onCouponApply() async {
    final couponCode = _couponController.text.toString();
    if (couponCode == "") {
      ToastComponent.showDialog(
        'enter_coupon_code'.tr(context: context),
      );
      return;
    }

    final couponApplyResponse =
        await CouponRepository().getCouponApplyResponse(couponCode);
    if (couponApplyResponse.result == false) {
      ToastComponent.showDialog(
        couponApplyResponse.message,
      );
      return;
    }

    reset_summary();
    fetchSummary();
  }

  Future<void> onCouponRemove() async {
    final couponRemoveResponse =
        await CouponRepository().getCouponRemoveResponse();

    if (couponRemoveResponse.result == false) {
      ToastComponent.showDialog(
        couponRemoveResponse.message,
      );
      return;
    }

    reset_summary();
    fetchSummary();
  }

  Future<void> onPressPlaceOrderOrProceed() async {
    if (_selected_payment_method == "") {
      ToastComponent.showDialog(
        'please_choose_one_option_to_pay'.tr(context: context),
        isError: true,
      );
      return;
    }
    if (_grandTotalValue == 0.00 &&
        !AppConfig.businessSettingsData.isPrescriptionActive) {
      ToastComponent.showDialog(
        'nothing_to_pay'.tr(context: context),
        isError: true,
      );
      return;
    }

    if (subPaymentOption.trim().isEmpty &&
        _paymentTypeList[_selected_payment_method_index]
            .integrations
            .isNotEmpty) {
      ToastComponent.showDialog(
        'please_choose_one_option_to_pay'.tr(context: context),
        isError: true,
      );
      return;
    }
    if (AppConfig.businessSettingsData.guestCheckoutStatus && !is_logged_in.$) {
      Loading.show(context);
      // guest checkout user create response

      final guestUserAccountCreateResponse = await GuestCheckoutRepository()
          .guestUserAccountCreate(widget.guestCheckOutShippingAddress);
      Loading.close();

      // after creating  guest user save to auth helper
      await AuthHelper().setUserData(guestUserAccountCreateResponse);

      if (!guestUserAccountCreateResponse.result!) {
        ToastComponent.showDialog(
          'already_have_account'.tr(context: context),
        );

        // if user not created
        // or any issue occurred
        // then it goes to guest check address page
        Navigator.pushAndRemoveUntil(
          OneContext().context!,
          MaterialPageRoute(
            builder: (context) => const GuestCheckoutAddress(),
          ),
          (Route<dynamic> route) => true,
        );
        return;
      }
    }

    if (_selected_payment_method == "stripe") {
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return StripeScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    }
    if (_selected_payment_method == "aamarpay") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AmarpayScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "paypal") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PaypalScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "razorpay") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return RazorpayScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "paystack") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PaystackScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "iyzico") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return IyzicoScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "bkash") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return BkashScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "nagad") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return NagadScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "sslcommerz") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SslCommerzScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "flutterwave") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FlutterwaveScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "paytm") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PaytmScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "khalti") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return KhaltiScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "instamojo") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OnlinePay(
          title: 'pay_with_instamojo'.tr(context: context),
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "payfast") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PayfastScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "phonepe") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PhonepayScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "myfatoorah") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MyFatooraScreen(
          amount: _grandTotalValue,
          payment_type: payment_type,
          payment_method_key: _selected_payment_method_key,
          package_id: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    } else if (_selected_payment_method == "wallet_system") {
      pay_by_wallet();
    } else if (_selected_payment_method == "cash_payment") {
      pay_by_cod();
    } else if (_selected_payment_method == "manual_payment" &&
        widget.paymentFor == PaymentFor.Order) {
      pay_by_manual_payment();
    } else if (_selected_payment_method == "manual_payment" &&
        (widget.paymentFor == PaymentFor.ManualPayment ||
            widget.paymentFor == PaymentFor.WalletRecharge ||
            widget.paymentFor == PaymentFor.PackagePay)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return OfflineScreen(
          order_id: widget.order_id,
          paymentInstruction:
              _paymentTypeList[_selected_payment_method_index].details,
          offline_payment_id: _paymentTypeList[_selected_payment_method_index]
              .offline_payment_id,
          rechargeAmount: widget.rechargeAmount,
          offLinePaymentFor: widget.paymentFor,
          paymentMethod: _paymentTypeList[_selected_payment_method_index].name,
          packageId: widget.packageId,
//          offLinePaymentFor: widget.offLinePaymentFor,
        );
      })).then((value) {
        onPopped(value);
      });
    } else {
      final String? name =
          _paymentTypeList[_selected_payment_method_index].name;
      String title = name == null
          ? 'payment_settings_ucf'.tr(context: context)
          : 'pay_with_'.tr(
              context: context,
              args: {'payment_method': name.capitalizeFirst},
            );
      switch (_selected_payment_method) {
        case "paymob":
          title = 'pay_with_my_paymob'.tr(context: context);
          break;
        case "fawaterk":
          title = 'pay_with_fawaterk'.tr(context: context);
          break;
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MainPaymentScreen(
          paymentKey: _selected_payment_method,
          title: title,
          subPaymentOption: subPaymentOption,
          amount: _grandTotalValue,
          paymentType: payment_type,
          paymentMethodKey: _selected_payment_method_key,
          packageId: widget.packageId.toString(),
          orderId: widget.order_id,
        );
      })).then((value) {
        onPopped(value);
      });
    }
  }

  Future<void> pay_by_wallet() async {
    final orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromWallet(
            _selected_payment_method_key, _grandTotalValue);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message, isError: true);
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const OrderList(from_checkout: true);
    }));
  }

  Future<void> pay_by_cod() async {
    loading();
    final orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromCod(_selected_payment_method_key);
    if (loadingcontext != null) {
      Navigator.of(loadingcontext!).pop();
    }
    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(
        orderCreateResponse.message,
      );
      Navigator.pop(context);
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const OrderList(from_checkout: true);
    }));
  }

  Future<void> pay_by_manual_payment() async {
    loading();
    final orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromManualPayment(_selected_payment_method_key);
    if (loadingcontext != null) {
      Navigator.pop(loadingcontext!);
    }
    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(
        orderCreateResponse.message,
      );
      Navigator.pop(context);
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const OrderList(from_checkout: true);
    }));
  }

  onPaymentMethodItemTap(index) {
    if (_selected_payment_method_key !=
        _paymentTypeList[index].payment_type_key) {
      setState(() {
        subPaymentOption = '';
        _selected_payment_method_index = index;
        _selected_payment_method = _paymentTypeList[index].payment_type ?? '';
        _selected_payment_method_key = _paymentTypeList[index].payment_type_key;
      });
    }

    //print(_selected_payment_method);
    //print(_selected_payment_method_key);
  }

  onPressDetails() {
    showDialog(
      context: context,
      builder: (_) => _AlertDialogDetailsWidget(
          subTotalString: _subTotalString,
          taxString: _taxString,
          shippingCostString: _shippingCostString,
          discountString: _discountString,
          totalString: _totalString),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        bottomNavigationBar: buildBottomAppBar(context),
        body: Stack(
          children: [
            RefreshIndicator(
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              onRefresh: _onRefresh,
              displacement: 0,
              child: CustomScrollView(
                controller: _mainScrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        if (AppConfig.businessSettingsData.checkoutMessage
                                ?.isNotEmpty ==
                            true)
                          Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingDefault,
                            ),
                            child: Text(
                              AppConfig.businessSettingsData.checkoutMessage!,
                              textDirection: AppConfig.businessSettingsData
                                  .checkoutMessage!.direction,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingDefault,
                          ),
                          child: buildPaymentMethodList(),
                        ),
                        const SizedBox(height: 292)
                      ],
                    ),
                  )
                ],
              ),
            ),

            //Apply Coupon and order details container
            Align(
              alignment: Alignment.bottomCenter,
              child: widget.paymentFor == PaymentFor.WalletRecharge ||
                      widget.paymentFor == PaymentFor.PackagePay
                  ? const SizedBox.shrink()
                  : Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      height: (widget.paymentFor == PaymentFor.ManualPayment) ||
                              (widget.paymentFor == PaymentFor.OrderRePayment)
                          ? 232
                          : 292,
                      //color: Colors.white,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingDefault),
                        child: Column(
                          children: [
                            widget.paymentFor == PaymentFor.Order
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: buildApplyCouponRow(context),
                                  )
                                : const SizedBox.shrink(),
                            CheckoutDetails(
                                showTotal: false,
                                subTotalString: _subTotalString,
                                taxString: _taxString,
                                shippingCostString: _shippingCostString,
                                discountString: _discountString,
                                totalString: _totalString),
                            grandTotalSection(),
                          ],
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Row buildApplyCouponRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: SizedBox(
              height: 42,
              width: (MediaQuery.sizeOf(context).width - 32) * (2 / 3),
              child: TextFormField(
                controller: _couponController,
                readOnly: _coupon_applied!,
                autofocus: false,
                decoration: InputDecoration(
                    hintText: 'enter_coupon_code'.tr(context: context),
                    hintStyle: const TextStyle(
                        fontSize: 14.0, color: MyTheme.textfield_grey),
                    enabledBorder: app_language_rtl.$!
                        ? const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyTheme.textfield_grey, width: 0.5),
                            borderRadius: BorderRadius.only(
                              topRight:
                                  Radius.circular(AppDimensions.radiusSmall),
                              bottomRight:
                                  Radius.circular(AppDimensions.radiusSmall),
                            ),
                          )
                        : const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyTheme.textfield_grey, width: 0.5),
                            borderRadius: BorderRadius.only(
                              topLeft:
                                  Radius.circular(AppDimensions.radiusSmall),
                              bottomLeft:
                                  Radius.circular(AppDimensions.radiusSmall),
                            ),
                          ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: MyTheme.medium_grey, width: 0.5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radiusSmall),
                        bottomLeft: Radius.circular(AppDimensions.radiusSmall),
                      ),
                    ),
                    contentPadding:
                        const EdgeInsetsDirectional.only(start: 16.0)),
              ),
            ),
          ),
        ),
        !_coupon_applied!
            ? Container(
                width: (MediaQuery.sizeOf(context).width - 32) * (1 / 3),
                height: 42,
                child: Btn.basic(
                  minWidth: MediaQuery.sizeOf(context).width,
                  color: Theme.of(context).primaryColor,
                  shape: app_language_rtl.$!
                      ? const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppDimensions.radiusSmall),
                          bottomLeft:
                              Radius.circular(AppDimensions.radiusSmall),
                        ))
                      : const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                          topRight: Radius.circular(AppDimensions.radiusSmall),
                          bottomRight:
                              Radius.circular(AppDimensions.radiusSmall),
                        )),
                  child: Text(
                    'apply_coupon_all_capital'.tr(context: context),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponApply();
                  },
                ),
              )
            : Container(
                width: (MediaQuery.sizeOf(context).width - 32) * (1 / 3),
                height: 42,
                child: Btn.basic(
                  minWidth: MediaQuery.sizeOf(context).width,
                  color: Theme.of(context).primaryColor,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppDimensions.radiusSmall),
                    bottomRight: Radius.circular(AppDimensions.radiusSmall),
                  )),
                  child: Text(
                    'remove_ucf'.tr(context: context),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponRemove();
                  },
                ),
              )
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
              app_language_rtl.$!
                  ? CupertinoIcons.arrow_right
                  : CupertinoIcons.arrow_left,
              color: MyTheme.dark_grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        widget.title!,
        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget? buildPaymentMethodList() {
    if (_isInitial && _paymentTypeList.isEmpty) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_paymentTypeList.isNotEmpty) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 16,
            );
          },
          itemCount: _paymentTypeList.length,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: buildPaymentMethodItemCard(index),
            );
          },
        ),
      );
    } else if (!_isInitial && _paymentTypeList.isEmpty) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            'no_payment_method_is_added'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    }
    return null;
  }

/////Method card paypal,Strip,Bkash,etc//////////
  GestureDetector buildPaymentMethodItemCard(index) {
    return GestureDetector(
      onTap: () {
        onPaymentMethodItemTap(index);
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusHalfSmall))
                .copyWith(
              border: Border.all(
                color: _selected_payment_method_key ==
                        _paymentTypeList[index].payment_type_key
                    ? Theme.of(context).primaryColor
                    : MyTheme.light_grey,
                width: _selected_payment_method_key ==
                        _paymentTypeList[index].payment_type_key
                    ? 2.0
                    : 0.0,
              ),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 100,
                    padding: const EdgeInsets.all(AppDimensions.paddingDefault),
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: FadeInImage.assetNetwork(
                      placeholder: AppImages.placeholder,
                      image: _paymentTypeList[index].image ?? '',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppDimensions.paddingSmall,
                        children: [
                          Text(
                            _paymentTypeList[index].title ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final List<SubPayment> integrations =
                                  _paymentTypeList[index].integrations;
                              final bool hasSubOptions =
                                  _selected_payment_method_index == index &&
                                      integrations.isNotEmpty;
                              if (integrations.length == 1 && hasSubOptions) {
                                subPaymentOption = integrations[0].value ?? '';
                              }

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: hasSubOptions ? 50 : 0,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSmall,
                                  ),
                                ),
                                child: StatefulBuilder(
                                  builder: (context, setState2) {
                                    return ListView.builder(
                                      itemCount: integrations.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, i) {
                                        final SubPayment subPayment =
                                            integrations[i];
                                        return Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                            end: AppDimensions.paddingSmall,
                                          ),
                                          child: ChoiceChip(
                                            avatar: subPayment.image == null
                                                ? null
                                                : FadeInImage.assetNetwork(
                                                    placeholder:
                                                        AppImages.placeholder,
                                                    imageErrorBuilder:
                                                        (___, __, _) =>
                                                            emptyWidget,
                                                    image: subPayment.image!,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                            checkmarkColor: Colors.white,
                                            onSelected: (value) {
                                              setState2(() {
                                                subPaymentOption =
                                                    subPayment.value ?? '';
                                              });
                                            },
                                            selected: subPaymentOption ==
                                                    subPayment.value &&
                                                subPaymentOption
                                                    .trim()
                                                    .isNotEmpty,
                                            label: Text(subPayment.name ?? ''),
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color: subPaymentOption ==
                                                              subPayment
                                                                  .value &&
                                                          subPaymentOption
                                                              .trim()
                                                              .isNotEmpty
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .primaryColor,
                                                ),
                                            selectedColor:
                                                Theme.of(context).primaryColor,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
          PositionedDirectional(
            end: 16,
            top: 16,
            child: buildPaymentMethodCheckContainer(
                _selected_payment_method_key ==
                    _paymentTypeList[index].payment_type_key),
          )
        ],
      ),
    );
  }

  Widget buildPaymentMethodCheckContainer(bool check) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: check ? 1 : 0,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
            color: Colors.green),
        child: const Icon(Icons.check, color: Colors.white, size: 10),
      ),
    );
  }

  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Container(
        color: Colors.transparent,
        height: 50,
        child: Btn.minWidthFixHeight(
          minWidth: MediaQuery.sizeOf(context).width,
          height: 50,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
          ),
          child: Text(
            widget.paymentFor == PaymentFor.WalletRecharge
                ? 'recharge_wallet_ucf'.tr(context: context)
                : widget.paymentFor == PaymentFor.ManualPayment
                    ? 'proceed_all_caps'.tr(context: context)
                    : widget.paymentFor == PaymentFor.PackagePay
                        ? 'buy_package_ucf'.tr(context: context)
                        : 'place_my_order_all_capital'.tr(context: context),
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: () {
            onPressPlaceOrderOrProceed();
          },
        ),
      ),
    );
  }

  Widget grandTotalSection() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        color: MyTheme.soft_accent_color,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmallExtra),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16.0),
              child: Text(
                'total_amount_ucf'.tr(context: context),
                style: const TextStyle(color: MyTheme.font_grey, fontSize: 14),
              ),
            ),
            // Visibility(
            //   visible: widget.paymentFor != PaymentFor.ManualPayment,
            //   child: Padding(
            //     padding: const EdgeInsetsDirectional.only(start: 8.0),
            //     child: InkWell(
            //       onTap: () {
            //         onPressDetails();
            //       },
            //       child: Text(
            //         'see_details_all_lower'.tr(context: context),
            //         style: TextStyle(
            //           color: MyTheme.font_grey,
            //           fontSize: 12,
            //           decoration: TextDecoration.underline,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            const Spacer(),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16.0),
              child: Text(balance(),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  loading() {
    showDialog(
      context: context,
      builder: (context) {
        loadingcontext = context;
        return AlertDialog(
            content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              width: 10,
            ),
            Text("${'please_wait_ucf'.tr(context: context)}"),
          ],
        ));
      },
    );
  }
}

class _AlertDialogDetailsWidget extends StatelessWidget {
  const _AlertDialogDetailsWidget({
    required String? subTotalString,
    required String? taxString,
    required String shippingCostString,
    required String? discountString,
    required String? totalString,
  })  : _subTotalString = subTotalString,
        _taxString = taxString,
        _shippingCostString = shippingCostString,
        _discountString = discountString,
        _totalString = totalString;

  final String? _subTotalString;
  final String? _taxString;
  final String _shippingCostString;
  final String? _discountString;
  final String? _totalString;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding:
          const EdgeInsets.all(2).copyWith(top: AppDimensions.paddingDefault),
      content: CheckoutDetails(
          showTotal: true,
          subTotalString: _subTotalString,
          taxString: _taxString,
          shippingCostString: _shippingCostString,
          discountString: _discountString,
          totalString: _totalString),
      actions: [
        Btn.basic(
          child: Text(
            'close_all_lower'.tr(context: context),
            style: const TextStyle(color: MyTheme.medium_grey),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );
  }
}

class CheckoutDetails extends StatelessWidget {
  const CheckoutDetails({
    super.key,
    required String? subTotalString,
    required String? taxString,
    required String shippingCostString,
    required String? discountString,
    required String? totalString,
    required this.showTotal,
  })  : _subTotalString = subTotalString,
        _taxString = taxString,
        _shippingCostString = shippingCostString,
        _discountString = discountString,
        _totalString = totalString;

  final String? _subTotalString;
  final String? _taxString;
  final String _shippingCostString;
  final String? _discountString;
  final String? _totalString;
  final bool showTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8.0, end: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Row(
                children: [
                  Container(
                    width: 120,
                    child: Text(
                      'subtotal_all_capital'.tr(context: context),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    SystemConfig.systemCurrency != null
                        ? _subTotalString!.replaceAll(
                            SystemConfig.systemCurrency!.code!,
                            SystemConfig.systemCurrency!.symbol!)
                        : _subTotalString!,
                    style: const TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              )),
          Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
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
                    SystemConfig.systemCurrency != null
                        ? _taxString!.replaceAll(
                            SystemConfig.systemCurrency!.code!,
                            SystemConfig.systemCurrency!.symbol!)
                        : _taxString!,
                    style: const TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              )),
          Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
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
                    SystemConfig.systemCurrency != null
                        ? _shippingCostString.replaceAll(
                            SystemConfig.systemCurrency!.code!,
                            SystemConfig.systemCurrency!.symbol!)
                        : _shippingCostString,
                    style: const TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              )),
          Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
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
                    SystemConfig.systemCurrency != null
                        ? _discountString!.replaceAll(
                            SystemConfig.systemCurrency!.code!,
                            SystemConfig.systemCurrency!.symbol!)
                        : _discountString!,
                    style: const TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              )),
          const Divider(
            indent: 8.0,
          ),
          if (showTotal)
            Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
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
                      SystemConfig.systemCurrency != null
                          ? _totalString!.replaceAll(
                              SystemConfig.systemCurrency!.code!,
                              SystemConfig.systemCurrency!.symbol!)
                          : _totalString!,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )),
        ],
      ),
    );
  }
}
