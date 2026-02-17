import 'package:active_ecommerce_cms_demo_app/helpers/addons_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/check_internet.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/currency_presenter.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:active_ecommerce_cms_demo_app/screens/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_config.dart';
import '../providers/theme_provider.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  Future<String?> getSharedValueHelperData() async {
    // await BusinessSettingHelper.setInitLang();
    Provider.of<ThemeProvider>(context, listen: false).changeAppColors(
      primary: AppConfig.businessSettingsData.primaryColor,
      secondary: AppConfig.businessSettingsData.secondaryColor,
    );
    Provider.of<CurrencyPresenter>(context, listen: false).fetchListData();
    access_token.load().whenComplete(() {
      AuthHelper().fetch_and_set();
    });
    AddonsHelper().setAddonsData();
    await Future.wait([
      temp_user_id.load(),
      app_language.load(),
      app_mobile_language.load(),
      app_language_rtl.load(),
      system_currency.load(),
    ]);

    // print("new splash screen ${app_mobile_language.$}");
    // print("new splash screen app_language_rtl ${app_language_rtl.$}");

    return app_mobile_language.$;
  }

  @override
  void initState() {
    InternetHelper.listenToConnectivityChanges(context);
    getSharedValueHelperData().then((value) async {
      // await Future.wait([
      //   homeData.fetchAddressLists(false, false),
      //   await Future.delayed(const Duration(seconds: 3));
      // ]);
      // if (homeData.haveToGoAddress) homeData.handleAddressNavigation();
      await Future.delayed(const Duration(seconds: 3));
      SystemConfig.isShownSplashScreen = true;
      // Provider.of<LocaleProvider>(context, listen: false)
      //     .setLocale(app_mobile_language.$!);
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemConfig.context ??= context;
    return Scaffold(
      body: SystemConfig.isShownSplashScreen
          ? const Main()
          : const SplashScreen(),
    );
  }
}
