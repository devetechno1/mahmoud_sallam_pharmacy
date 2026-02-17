import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/payment_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/orders/order_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../helpers/system_config.dart';
import '../profile.dart';

class RazorpayScreen extends StatefulWidget {
  final double? amount;
  final String payment_type;
  final String? payment_method_key;
  final int? orderId;
  final package_id;
  const RazorpayScreen(
      {Key? key,
      this.amount = 0.00,
      this.orderId = 0,
      this.payment_type = "",
      this.package_id = "0",
      this.payment_method_key = ""})
      : super(key: key);

  @override
  _RazorpayScreenState createState() => _RazorpayScreenState();
}

class _RazorpayScreenState extends State<RazorpayScreen> {
  int? _combined_order_id = 0;
  bool _order_init = false;

  final WebViewController _webViewController = WebViewController();
  bool get goToOrdersScreen =>
      widget.payment_type != "cart_payment" || _order_init;

  @override
  void initState() {
    super.initState();

    if (widget.payment_type == "cart_payment") {
      createOrder();
    } else {
      razorpay();
    }
  }

  razorpay() {
    final String initialUrl =
        "${AppConfig.BASE_URL}/razorpay/pay-with-razorpay?payment_type=${widget.payment_type}&combined_order_id=$_combined_order_id&amount=${widget.amount}&user_id=${user_id.$}&package_id=${widget.package_id}&order_id${widget.orderId}";

    // print(initial_url);

    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          // onWebResourceError: (error) {
          //   Navigator.pop(context, goToOrdersScreen);
          // },
          // onHttpError: (error) {
          //   Navigator.pop(context, goToOrdersScreen);
          // },
          onPageFinished: (page) {
            // print("page");
            // print(page);
            if (page.contains("/razorpay/success")) {
              print(page.toString());
              getData();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl), headers: {
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
        "Accept": "application/json",
        "System-Key": AppConfig.system_key,
        "Authorization": "Bearer ${access_token.$}",
        "Currency-Code": SystemConfig.systemCurrency!.code!,
        "Currency-Exchange-Rate":
            SystemConfig.systemCurrency!.exchangeRate.toString(),
      });
  }

  Future<void> createOrder() async {
    final orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponse(widget.payment_method_key);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(
        orderCreateResponse.message,
      );
      Navigator.pop(context, goToOrdersScreen);
      return;
    }

    _combined_order_id = orderCreateResponse.combined_order_id;
    _order_init = true;
    setState(() {});

    razorpay();
    // print("-----------");

    // print(_combined_order_id);
    // print(user_id.$);
    // print(widget.amount);
    // print(widget.payment_method_key);
    // print(widget.payment_type);
    // print("-----------");
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // textDirection:
      //   app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
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

  void getData() {
    String? paymentDetails = '';
    _webViewController
        .runJavaScriptReturningResult("document.body.innerText")
        .then((data) {
      var responseJSON = jsonDecode(data as String);
      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }

      // print('responseJSON');
      // print(responseJSON);
      if (responseJSON["result"] == false) {
        ToastComponent.showDialog(
          responseJSON["message"],
        );

        Navigator.pop(context);
      } else if (responseJSON["result"] == true) {
        paymentDetails = responseJSON['payment_details'];
        onPaymentSuccess(paymentDetails);
      }
    });
  }

  Future<void> onPaymentSuccess(paymentDetails) async {
    final razorpayPaymentSuccessResponse = await PaymentRepository()
        .getRazorpayPaymentSuccessResponse(widget.payment_type, widget.amount,
            _combined_order_id, paymentDetails);

    if (razorpayPaymentSuccessResponse.result == false) {
      ToastComponent.showDialog(
        razorpayPaymentSuccessResponse.message!,
      );
      Navigator.pop(context);
      return;
    }
    // print(razorpayPaymentSuccessResponse);
    // print(razorpayPaymentSuccessResponse.message);

    ToastComponent.showDialog(
      razorpayPaymentSuccessResponse.message!,
    );

    if (widget.payment_type == "cart_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const OrderList(from_checkout: true);
      }));
    } else if (widget.payment_type == "wallet_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const Wallet(from_recharge: true);
      }));
    } else if (widget.payment_type == "order_re_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const OrderList(from_checkout: true);
      }));
    } else if (widget.payment_type == "customer_package_payment") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const Profile();
      }));
    }
  }

  Widget buildBody() {
    if (_order_init == false &&
        _combined_order_id == 0 &&
        widget.payment_type == "cart_payment") {
      return Container(
        child: Center(
          child: Text('creating_order'.tr(context: context)),
        ),
      );
    } else {
      return SizedBox.expand(
        child: Container(
          child: WebViewWidget(
            controller: _webViewController,
          ),
        ),
      );
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
              app_language_rtl.$!
                  ? CupertinoIcons.arrow_right
                  : CupertinoIcons.arrow_left,
              color: MyTheme.dark_grey),
          onPressed: () => Navigator.pop(context, goToOrdersScreen),
        ),
      ),
      title: Text(
        'pay_with_razorpay'.tr(context: context),
        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
