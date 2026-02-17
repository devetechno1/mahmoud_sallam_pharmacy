import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/payment_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/orders/order_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/profile.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../helpers/main_helpers.dart';

class MainPaymentScreen extends StatefulWidget {
  final double? amount;
  final String paymentType;
  final String title;
  final String paymentKey;
  final String? paymentMethodKey;
  final String packageId;
  final int? orderId;
  final String subPaymentOption;
  const MainPaymentScreen({
    Key? key,
    this.amount = 0.00,
    this.orderId = 0,
    this.paymentType = "",
    this.paymentMethodKey = "",
    required this.title,
    required this.subPaymentOption,
    required this.paymentKey,
    this.packageId = "0",
  }) : super(key: key);

  @override
  _MainPaymentScreenState createState() => _MainPaymentScreenState();
}

class _MainPaymentScreenState extends State<MainPaymentScreen> {
  int? _combinedOrderId = 0;
  bool _orderInit = false;
  bool canPop = true;
  bool isLoading = true;

  final WebViewController _webViewController = WebViewController();
  bool get goToOrdersScreen =>
      widget.paymentType != "cart_payment" || _orderInit;

  @override
  void initState() {
    super.initState();
    if (widget.paymentType == "cart_payment") {
      createOrder();
    } else {
      init();
    }
  }

  void init() {
    final String _initialUrl =
        "${AppConfig.BASE_URL}/${widget.paymentKey}/initiate?payment_type=${widget.paymentType}&combined_order_id=$_combinedOrderId&amount=${widget.amount}&user_id=${user_id.$}&package_id=${widget.packageId}&order_id=${widget.orderId}&sub_payment_option=${widget.subPaymentOption}";
    print(_initialUrl);
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          // onWebResourceError: (error) {
          //   Navigator.pop(context, goToOrdersScreen);
          // },
          // onHttpError: (error) {
          //   print(error);
          //   Navigator.pop(context, goToOrdersScreen);
          // },
          onPageFinished: (page) {
            isLoading = false;
            canPop = true;
            setState(() {});
            if (page.contains("/${widget.paymentKey}/callback")) {
              getData();
            } else if (page.contains("pending=false") &&
                page.contains("success=true")) {
              canPop = false;
              setState(() {});
            }
            print("page: $page");
          },
        ),
      )
      ..loadRequest(Uri.parse(_initialUrl), headers: commonHeader);
  }

  Future<void> createOrder() async {
    final orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponse(widget.paymentMethodKey);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(
        orderCreateResponse.message,
      );
      if (canPop) Navigator.pop(context, goToOrdersScreen);
      return;
    }

    _combinedOrderId = orderCreateResponse.combined_order_id;
    _orderInit = true;
    setState(() {});
    init();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && canPop) {
          Navigator.pop(context, goToOrdersScreen);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(),
      ),
    );
  }

  Future<void> getData() async {
    final data = await _webViewController
        .runJavaScriptReturningResult("document.body.innerText");

    var responseJSON = jsonDecode(data as String);
    if (responseJSON.runtimeType == String) {
      responseJSON = jsonDecode(responseJSON);
    }
    if (responseJSON["result"] == false) {
      ToastComponent.showDialog(responseJSON["message"]);
      Navigator.pop(context, goToOrdersScreen);
    } else if (responseJSON["result"] == true) {
      ToastComponent.showDialog(responseJSON["message"]);

      if (widget.paymentType == "cart_payment") {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const OrderList(from_checkout: true);
        }));
      } else if (widget.paymentType == "order_re_payment") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const OrderList(from_checkout: true);
        }));
      } else if (widget.paymentType == "wallet_payment") {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const Wallet(from_recharge: true);
        }));
      } else if (widget.paymentType == "customer_package_payment") {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const Profile();
        }));
      }
    }
  }

  Widget? buildBody() {
    //print("init url");
    //print(initial_url);

    if (_orderInit == false &&
        _combinedOrderId == 0 &&
        widget.paymentType == "cart_payment") {
      return Container(
        child: Center(
          child: Text(
            'creating_order'.tr(context: context),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              child: WebViewWidget(controller: _webViewController),
            ),
          ),
          if (isLoading)
            Center(
              child: Transform.scale(
                scale: 2,
                child: const CircularProgressIndicator.adaptive(),
              ),
            ),
        ],
      );
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: canPop
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(
                    app_language_rtl.$!
                        ? CupertinoIcons.arrow_right
                        : CupertinoIcons.arrow_left,
                    color: MyTheme.dark_grey),
                onPressed: () => Navigator.pop(context, goToOrdersScreen),
              ),
            )
          : emptyWidget,
      title: Text(
        widget.title,
        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
