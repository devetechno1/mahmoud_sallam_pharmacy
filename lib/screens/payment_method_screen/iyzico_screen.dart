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

import '../../helpers/main_helpers.dart';
import '../profile.dart';

class IyzicoScreen extends StatefulWidget {
  final double? amount;
  final String payment_type;
  final String? payment_method_key;
  final package_id;
  final int? orderId;
  const IyzicoScreen(
      {Key? key,
      this.amount = 0.00,
      this.orderId = 0,
      this.payment_type = "",
      this.package_id = "0",
      this.payment_method_key = ""})
      : super(key: key);

  @override
  _IyzicoScreenState createState() => _IyzicoScreenState();
}

class _IyzicoScreenState extends State<IyzicoScreen> {
  int? _combined_order_id = 0;
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
      iyzico();
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
    setState(() {});
    iyzico();
  }

  iyzico() {
    final String initialUrl =
        "${AppConfig.BASE_URL}/iyzico/init?payment_type=${widget.payment_type}&combined_order_id=$_combined_order_id&amount=${widget.amount}&user_id=${user_id.$}&package_id=${widget.package_id}&order_id=${widget.orderId}";
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
            print(page.toString());
            getData();
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl), headers: commonHeader);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, goToOrdersScreen);
        }
      },
      // textDirection:
      //     app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(),
      ),
    );
  }

  void getData() {
    // print('called.........');
    String? paymentDetails = '';
    _webViewController
        .runJavaScriptReturningResult("document.body.innerText")
        .then((data) {
      var responseJSON = jsonDecode(data as String);
      if (responseJSON.runtimeType == String) {
        responseJSON = jsonDecode(responseJSON);
      }
      if (responseJSON["result"] == false) {
        ToastComponent.showDialog(
          responseJSON["message"],
        );

        Navigator.pop(context, goToOrdersScreen);
      } else if (responseJSON["result"] == true) {
        paymentDetails = responseJSON['payment_details'];
        onPaymentSuccess(paymentDetails);
      }
    });
  }

  Future<void> onPaymentSuccess(paymentDetails) async {
    final iyzicoPaymentSuccessResponse = await PaymentRepository()
        .getIyzicoPaymentSuccessResponse(widget.payment_type, widget.amount,
            _combined_order_id, paymentDetails);
    if (iyzicoPaymentSuccessResponse.result == false) {
      ToastComponent.showDialog(
        iyzicoPaymentSuccessResponse.message!,
      );
      Navigator.pop(context, goToOrdersScreen);
      return;
    }

    ToastComponent.showDialog(
      iyzicoPaymentSuccessResponse.message!,
    );
    if (widget.payment_type == "cart_payment") {
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const OrderList(from_checkout: true);
      }));
    } else if (widget.payment_type == "order_re_payment") {
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const OrderList(from_checkout: true);
      }));
    } else if (widget.payment_type == "wallet_payment") {
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const Wallet(from_recharge: true);
      }));
    } else if (widget.payment_type == "customer_package_payment") {
      await Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) {
        return const Profile();
      }));
    }
  }

  Widget buildBody() {
    //print("init url");
    //print(initial_url);

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
        'pay_with_iyzico'.tr(context: context),
        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
