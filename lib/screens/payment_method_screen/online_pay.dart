import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/payment_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/orders/order_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/package/packages.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OnlinePay extends StatefulWidget {
  final String? title;
  final double? amount;
  final String payment_type;
  final String? payment_method_key;
  final package_id;
  final int? orderId;
  const OnlinePay(
      {Key? key,
      this.amount = 0.00,
      this.orderId = 0,
      this.title = "Pay With Instamojo",
      this.payment_type = "",
      this.package_id = "0",
      this.payment_method_key = ""})
      : super(key: key);

  @override
  _OnlinePayState createState() => _OnlinePayState();
}

class _OnlinePayState extends State<OnlinePay> {
  int? _combined_order_id = 0;
  bool _initial_url_fetched = false;
  bool _order_init = false;

  final WebViewController _webViewController = WebViewController();
  bool get goToOrdersScreen =>
      widget.payment_type != "cart_payment" || _order_init;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.payment_type == "cart_payment") {
      createOrder();
    } else {
      pay(Uri.parse(
          "${AppConfig.BASE_URL}/online-pay/init?payment_type=${widget.payment_type}&combined_order_id=$_combined_order_id&wallet_amount=${widget.amount}&payment_option=${widget.payment_method_key}&order_id=${widget.orderId}"));
    }
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
    pay(Uri.parse(
        "${AppConfig.BASE_URL}/online-pay/init?payment_type=${widget.payment_type}&combined_order_id=$_combined_order_id&wallet_amount=${widget.amount}&payment_option=${widget.payment_method_key}"));
  }

  pay(url) {
    print(url);
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
            print(page);
            if (page.contains("/online-pay/done")) {
              if (widget.payment_type == "cart_payment") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrderList(
                              from_checkout: true,
                            )));
              } else if (widget.payment_type == "order_re_payment") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrderList(
                              from_checkout: true,
                            )));
              } else if (widget.payment_type == "wallet_payment") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Wallet(
                              from_recharge: true,
                            )));
              } else if (widget.payment_type == "customer_package_payment") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UpdatePackage(
                              goHome: true,
                            )));
              }
            }
            if (page.contains("/online-pay/failed")) {
              getData();
              Navigator.pop(context, goToOrdersScreen);
            }
          },
        ),
      )
      ..loadRequest(url, headers: {
        "Authorization": "Bearer ${access_token.$}",
        "Content-Type": "application/json",
        "App-Language": app_language.$!,
        "Accept": "application/json",
        "System-Key": AppConfig.system_key
      });
    _initial_url_fetched = true;
    setState(() {});
  }

  void getData() {
    _webViewController
        .runJavaScriptReturningResult("document.body.innerText")
        .then((data) {
      var responseJSON = jsonDecode(data as String);

      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }
      // ToastContext().init(context);/**/
      /// todo:: show message
      ToastComponent.showDialog(
        responseJSON["message"],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (_initial_url_fetched == false &&
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
        widget.title!,
        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
