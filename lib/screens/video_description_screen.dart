import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoDescription extends StatefulWidget {
  final String? url;

  const VideoDescription({Key? key, this.url}) : super(key: key);

  @override
  _VideoDescriptionState createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends State<VideoDescription> {
  final WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    webView();
  }

  webView() {
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {},
          onPageFinished: (page) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url!));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (MediaQuery.orientationOf(context) == Orientation.landscape) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }
        return Future.value(true);
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: buildBody(),
        ),
      ),
    );
  }

  SizedBox buildBody() {
    return SizedBox.expand(
      child: Container(
        child: Stack(
          children: [
            WebViewWidget(
              controller: _webViewController,
            ),
            Align(
              alignment: app_language_rtl.$!
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                decoration: const ShapeDecoration(
                  color: MyTheme.medium_grey_50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppDimensions.radius),
                      bottomRight: Radius.circular(AppDimensions.radius),
                    ),
                  ),
                ),
                width: 40,
                height: 40,
                child: IconButton(
                  icon: Icon(
                      app_language_rtl.$!
                          ? CupertinoIcons.arrow_right
                          : CupertinoIcons.arrow_left,
                      color: MyTheme.white),
                  onPressed: () {
                    if (MediaQuery.orientationOf(context) ==
                        Orientation.landscape) {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown
                      ]);
                    }
                    return Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
