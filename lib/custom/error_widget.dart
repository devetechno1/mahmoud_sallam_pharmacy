import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/custom_otp.dart';
import 'btn.dart';

class CustomErrorWidget extends StatefulWidget {
  final Object? errorMessage;
  final bool canPop;
  final void Function()? onTap;
  final bool canGoHome;

  const CustomErrorWidget({
    super.key,
    this.errorMessage,
    this.canPop = true,
    this.canGoHome = false,
    this.onTap,
  });

  @override
  State<CustomErrorWidget> createState() => _CustomErrorWidgetState();
}

class _CustomErrorWidgetState extends State<CustomErrorWidget> {
  bool _goingUp = true;

  String error = '';
  bool get canPop => widget.canPop && Navigator.canPop(context);

  @override
  void initState() {
    if (widget.errorMessage is List) {
      final List e = widget.errorMessage as List;
      if (e.length > 1) {
        for (int i = 0; i < e.length; i++) error += "${i + 1} - ${e[i]} \n";
      } else {
        error = e.first.toString();
      }
    } else {
      error = widget.errorMessage.toString();
    }

    super.initState();
  }

  late final widget1 = PopScope(
    canPop: canPop,
    onPopInvokedWithResult: (didPop, result) {
      if (!canPop) context.go('/');
    },
    child: Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingDefault),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: AppDimensions.paddingDefault,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<Offset>(
                    begin: Offset(0, _goingUp ? 0 : -0.07),
                    end: Offset(0, _goingUp ? -0.07 : 0),
                  ),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  onEnd: () {
                    setState(() {
                      _goingUp = !_goingUp;
                    });
                  },
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: Offset(0, offset.dy * 100),
                      child: child,
                    );
                  },
                  child: Image.asset(AppImages.oops),
                ),
                Text(
                  "oops".tr(context: context),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  !AppConfig.isDebugMode || widget.errorMessage == null
                      ? "some_things_went_wrong".tr(context: context)
                      : error,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.onTap != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Btn.minWidthFixHeight(
                      minWidth: 250,
                      height: 30,
                      color: Theme.of(context).primaryColor,
                      child: Text(
                        "try_again".tr(context: context),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: widget.onTap,
                    ),
                  ),
                if (widget.canGoHome)
                  TextButton(
                    onPressed: () => goHome(context),
                    child: Text(
                      "go_home".tr(context: context),
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (isSliver(context)) return SliverToBoxAdapter(child: widget1);

    return widget1;
  }

  bool isSliver(BuildContext context) {
    Element? parentElem;
    (context as Element).visitAncestorElements((e) {
      parentElem = e;
      return false;
    });

    final ro = parentElem?.renderObject;
    if (ro is RenderSliver) return true;
    return false;
  }
}
