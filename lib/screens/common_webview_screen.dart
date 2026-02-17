import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/navigation_service.dart';

class CommonWebviewScreen extends StatefulWidget {
  final String url;
  final String page_name;
  final bool backHome;

  const CommonWebviewScreen(
      {Key? key, this.url = "", this.page_name = "", this.backHome = false})
      : super(key: key);

  @override
  _CommonWebviewScreenState createState() => _CommonWebviewScreenState();
}

class _CommonWebviewScreenState extends State<CommonWebviewScreen> {
  final WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    webView();
  }

  bool _isInitialLoadDone = false;

  webView() {
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            final Uri? uri = Uri.tryParse(request.url);
            if (uri != null && _isInitialLoadDone) {
              final bool handled = await NavigationService.handleUrls(
                request.url,
                useGo: true,
              );
              if (handled) {
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) => _isInitialLoadDone = true,
          onPageStarted: (url) => _isInitialLoadDone = false,
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
        headers: {if (app_language.$ != null) "App-Language": app_language.$!},
      );
  }

  TextDirection get direction =>
      app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.backHome,
      onPopInvokedWithResult: (didPop, result) {
        if (widget.backHome) onPop();
      },
      child: Directionality(
        textDirection: direction,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          body: buildBody(),
        ),
      ),
    );
  }

  SizedBox buildBody() {
    return SizedBox.expand(
      child: Container(
        child: WebViewWidget(
          controller: _webViewController,
          layoutDirection: direction,
        ),
      ),
    );
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
          onPressed: () {
            if (widget.backHome) {
              onPop();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      title: Text(
        "${widget.page_name}",
        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Future<void> onPop() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
    } else {
      context.go('/');
      // if (widget.backHome) context.go('/');
    }
  }
}
