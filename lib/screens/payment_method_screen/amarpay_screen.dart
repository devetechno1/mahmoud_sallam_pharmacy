import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app_config.dart';
import '../../custom/toast_component.dart';
import '../../helpers/main_helpers.dart';
import '../../helpers/shared_value_helper.dart';
import '../../my_theme.dart';
import '../../repositories/payment_repository.dart';
import '../orders/order_list.dart';
import '../profile.dart';
import '../wallet.dart';

class AmarpayScreen extends StatefulWidget {
  final double? amount;
  final String payment_type;
  final String? payment_method_key;
  final package_id;
  final int? orderId;
  const AmarpayScreen({
    Key? key,
    this.amount = 0.00,
    this.orderId = 0,
    this.payment_type = "",
    this.package_id = "0",
    this.payment_method_key = "",
  }) : super(key: key);

  @override
  State<AmarpayScreen> createState() => _AmarpayScreenState();
}

class _AmarpayScreenState extends State<AmarpayScreen> {
  //controller
  final WebViewController _webViewController = WebViewController();
  bool get goToOrdersScreen =>
      widget.payment_type != "cart_payment" || _order_init;

  int? _combined_order_id = 0;
  bool _order_init = false;

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
    amarpay();
  }

  void getData() {
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
        Navigator.pop(context);
      } else if (responseJSON["result"] == true) {
        ToastComponent.showDialog(
          responseJSON["message"],
        );
        if (widget.payment_type == "cart_payment") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const OrderList(from_checkout: true);
          }));
        } else if (widget.payment_type == "order_re_payment") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const OrderList(from_checkout: true);
          }));
        } else if (widget.payment_type == "wallet_payment") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Wallet(from_recharge: true);
          }));
        } else if (widget.payment_type == "customer_package_payment") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return const Profile();
          }));
        }
      }
    });
  }

  amarpay() {
    // todo:: PUT amar pay initial url here
    final String _initial_url =
        "${AppConfig.BASE_URL}/amarpay?payment_type=${widget.payment_type}&combined_order_id=$_combined_order_id&amount=${widget.amount}&user_id=${user_id.$}&package_id=${widget.package_id}&order_id=${widget.orderId}";

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
            if (page.contains("/amarpay/success")) {
              getData();
            } else if (page.contains("/amarpay/cancel")) {
              ToastComponent.showDialog(
                'payment_cancelled_ucf'.tr(context: context),
              );
              Navigator.pop(context, goToOrdersScreen);
              return;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_initial_url), headers: commonHeader);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.payment_type == "cart_payment") {
      createOrder();
    } else {
      amarpay();
    }
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

  // body
  Widget? buildBody() {
    if (_order_init == false &&
        _combined_order_id == 0 &&
        widget.payment_type == "cart_payment") {
      return Container(
        child: Center(
          child: Text('creating_order'.tr(context: context)),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: WebViewWidget(
            controller: _webViewController,
          ),
        ),
      );
    }
  }

  //app bar
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
        'pay_with_amarpay'.tr(context: context),
        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
