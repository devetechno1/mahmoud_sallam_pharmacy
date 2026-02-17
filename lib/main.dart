import 'dart:async';
import 'dart:developer';

import 'package:active_ecommerce_cms_demo_app/middlewares/auth_middleware.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:active_ecommerce_cms_demo_app/screens/filter.dart';
import 'package:active_ecommerce_cms_demo_app/screens/update_screen.dart';
import 'package:active_ecommerce_cms_demo_app/services/navigation_service.dart';
import 'package:app_links/app_links.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_value/shared_value.dart';
import 'package:device_preview/device_preview.dart';

import 'app_config.dart';
import 'custom/aiz_route.dart';

import 'custom/error_widget.dart';
import 'data_model/address_response.dart';
import 'data_model/business_settings/update_model.dart';
import 'data_model/login_response.dart';
import 'helpers/auth_helper.dart';
import 'helpers/business_setting_helper.dart';
import 'helpers/main_helpers.dart';
import 'helpers/shared_value_helper.dart';
import 'locale/custom_localization.dart';
import 'my_theme.dart';
import 'other_config.dart';
import 'presenter/cart_counter.dart';
import 'presenter/cart_provider.dart';
import 'presenter/currency_presenter.dart';
import 'presenter/home_provider.dart';
import 'presenter/select_address_provider.dart';
import 'presenter/unRead_notification_counter.dart';
import 'providers/blog_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/auth_repository.dart';
import 'screens/address.dart';
import 'screens/auction/auction_bidded_products.dart';
import 'screens/auction/auction_products.dart';
import 'screens/auction/auction_products_details.dart';
import 'screens/auction/auction_purchase_history.dart';
import 'screens/auth/registration.dart';
import 'screens/brand_products.dart';
import 'screens/category_list_n_product/category_list.dart';
import 'screens/category_list_n_product/category_products.dart';
import 'screens/checkout/cart.dart';
import 'screens/classified_ads/classified_ads.dart';
import 'screens/classified_ads/classified_product_details.dart';
import 'screens/classified_ads/classified_provider.dart';
import 'screens/classified_ads/my_classified_ads.dart';
import 'screens/common_webview_screen.dart';
import 'screens/coupon/coupons.dart';
import 'screens/flash_deal/flash_deal_list.dart';
import 'screens/flash_deal/flash_deal_products.dart';
import 'screens/followed_sellers.dart';
import 'screens/index.dart';
import 'screens/orders/order_details.dart';
import 'screens/orders/order_list.dart';
import 'screens/package/packages.dart';
import 'screens/product/product_details.dart';
import 'screens/product/todays_deal_products.dart';
import 'screens/profile.dart';
import 'screens/seller_details.dart';
import 'services/push_notification_service.dart';
import 'single_banner/photo_provider.dart';
import 'status/execute_and_handle_remote_errors.dart';
import 'status/status.dart';

void main() async {
  if (AppConfig.businessSettingsData.useSentry) {
    SentryWidgetsFlutterBinding.ensureInitialized();
    await SentryFlutter.init(
      (options) {
        options.dsn = AppConfig.businessSettingsData.sentryDSN;
        options.sendDefaultPii = true;
      },
      appRunner: appRunner,
    );
  } else {
    await appRunner();
  }
}

late final Address? _initAddress;

Future<void> appRunner() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (e) {
    return CustomErrorWidget(errorMessage: e.summary.value);
  };
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    recordError(details.exception, details.stack);
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    recordError(error, stack);
    return true; // Mark as handled
  };
  Widget app = SharedValue.wrapApp(const MyApp());

  AppConfig.storeType = await StoreType.thisDeviceType();

  await Future.wait([
    user_id.load(),
    is_logged_in.load(),
    access_token.load(),
  ]);

  await Future.wait([
    BusinessSettingHelper().setBusinessSettingData(),
    BusinessSettingHelper.setInitLang(),
    Firebase.initializeApp(),
    Hive.initFlutter(),
  ]);
  _initAddress = await getDefaultAddress();
  await _getUserData();

  localeTranslation = await Hive.openBox<Map>('langs');

  await Future.wait([
    BusinessSettingHelper.handleTranslations(),
    BusinessSettingHelper.getOTPLoginProviders(),
    // homeData.fetchAddressLists(false, false),
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  if (AppConfig.businessSettingsData.useClarity) {
    app = ClarityWidget(
      clarityConfig: ClarityConfig(
        projectId: AppConfig.businessSettingsData.clarityProjectId!,
        logLevel: LogLevel.None,
      ),
      app: app,
    );
  }
  if (AppConfig.businessSettingsData.useSentry) app = SentryWidget(child: app);

  runApp(
    DevicePreview(
      enabled: AppConfig.turnDevicePreviewOn,
      builder: (context) => app,
    ),
  );
}

Future<void> _getUserData() async {
  if (AppConfig.oldTokenKey.trim().isEmpty) return;

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? token = prefs.getString(AppConfig.oldTokenKey);

  if (token?.trim().isNotEmpty != true) return;

  access_token.$ = token;
  await access_token.save();

  final Status<LoginResponse> loginStatus = await executeAndHandleErrors(
    () => AuthRepository().getUserByTokenResponse(),
  );
  if (loginStatus is Success<LoginResponse> &&
      loginStatus.data.result == true) {
    final loginResponse = loginStatus.data;

    print("in the success block ");

    prefs.remove(AppConfig.oldTokenKey);

    await AuthHelper().setUserData(loginResponse);

    await saveFCMToken();
  } else {
    AuthHelper().clearUserData();

    String error = "an error occurred";

    if (loginStatus.data?.message.runtimeType == List) {
      error = loginStatus.data!.message!.join("\n");
    } else if (loginStatus.data?.message != null) {
      error = loginStatus.data!.message.toString();
    }

    recordError(error, StackTrace.current);
  }
}

void _setTag(String key, String? value) {
  if (value?.trim().isNotEmpty == true) {
    final b = Clarity.setCustomTag(key, value!);

    print(b);
  }
}

void setCustomUserDataClarity() {
  if ((user_id.$ != null || temp_user_id.$.isNotEmpty) &&
      AppConfig.businessSettingsData.useClarity) {
    Clarity.setCustomUserId("${user_id.$ ?? temp_user_id.$}");
    _setTag("id", "${user_id.$ ?? temp_user_id.$}");
    _setTag("name", user_name.$);
    _setTag("email", user_email.$);
    _setTag("phone", user_phone.$);
    _setTag("language", app_language.$);
  }
}

bool _isUpdateScreenOpened = false;
bool skipUpdate = false;

var routes = GoRouter(
  overridePlatformDefaultLocation: false,
  navigatorKey: OneContext().key,
  initialLocation: "/",
  errorPageBuilder: (BuildContext context, GoRouterState state) {
    return MaterialPage(
      child: CommonWebviewScreen(
        backHome: true,
        url: "${AppConfig.RAW_BASE_URL}/mobile-page${state.uri.path}",
      ),
    );
  },
  routes: [
    GoRoute(
        path: '/',
        name: "Home",
        redirect: (context, state) {
          setCustomUserDataClarity();
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            if (extra["skipUpdate"] == true) skipUpdate = true;
          }
          final UpdateDataModel? updateData =
              AppConfig.businessSettingsData.updateData;

          if ((updateData?.version != null &&
                  AppConfig.version !=
                      AppConfig.businessSettingsData.updateData?.version) &&
              (!_isUpdateScreenOpened ||
                  !skipUpdate ||
                  AppConfig.businessSettingsData.updateData?.mustUpdate ==
                      true) &&
              state.uri.path != "/update") {
            _isUpdateScreenOpened = true;
            return '/update?url=${state.uri.path}';
          }
          if (context.read<HomeProvider>().haveToGoAddress) return '/address';

          return null;
        },
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const MaterialPage(child: Index());
        },
        routes: [
          GoRoute(
            path: "go",
            redirect: (context, state) => "/",
          ),
          GoRoute(
              path: "customer_products",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(child: MyClassifiedAds())),
          GoRoute(
              path: "customer-products",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(child: ClassifiedAds())),
          GoRoute(
              path: "customer-product/:slug",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: ClassifiedAdsDetails(
                    slug: getParameter(state, "slug"),
                  ))),
          GoRoute(
              path: "product/:slug",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: ProductDetails(
                    slug: getParameter(state, "slug"),
                  ))),
          GoRoute(
              path: "customer-packages",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(child: UpdatePackage())),
          GoRoute(
              path: "auction_product_bids",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: AuthMiddleware(const AuctionBiddedProducts())
                          .next())),
          GoRoute(
            path: 'login',
            pageBuilder: (context, state) {
              return MaterialPage(
                child: Login(token: state.uri.queryParameters['user']),
              );
            },
          ),
          GoRoute(
            path: "registration",
            pageBuilder: (BuildContext context, GoRouterState state) =>
                MaterialPage(child: Registration()),
          ),
          GoRoute(
              path: "dashboard",
              name: "Profile",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  AIZRoute.rightTransition(const Profile())),
          GoRoute(
              path: "address",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(child: AddressScreen(goHome: false))),
          GoRoute(
              path: "auction-products",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(child: AuctionProducts())),
          GoRoute(
              path: "auction-product/:slug",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: AuctionProductsDetails(
                    slug: getParameter(state, "slug"),
                  ))),
          GoRoute(
              path: "auction/purchase_history",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: AuthMiddleware(const AuctionPurchaseHistory())
                          .next())),
          GoRoute(
              path: "brand/:slug",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: (BrandProducts(
                    slug: getParameter(state, "slug"),
                  )))),
          GoRoute(
              path: "brands",
              name: "Brands",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(
                      child: Filter(
                    selected_filter: "brands",
                  ))),
          GoRoute(
              path: "cart",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: AuthMiddleware(const Cart()).next())),
          GoRoute(
              path: "categories",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: (CategoryList(
                    name: getParameter(state, "name"),
                    slug: getParameter(state, "slug"),
                  )))),
          GoRoute(
              path: "category/:slug",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: (CategoryProducts(
                    name: getParameter(state, "name"),
                    slug: getParameter(state, "slug"),
                  )))),
          GoRoute(
              path: "flash-deals",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: (FlashDealList()))),
          GoRoute(
              path: "flash-deal/:slug",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: (FlashDealProducts(
                    slug: getParameter(state, "slug"),
                  )))),
          GoRoute(
              path: "followed-seller",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(child: (FollowedSellers()))),
          GoRoute(
              path: "purchase_history",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(child: (OrderList()))),
          GoRoute(
              path: "purchase_history/details/:id",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: (OrderDetails(
                    id: int.parse(getParameter(state, "id")),
                  )))),
          GoRoute(
              path: "sellers",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(
                      child: (Filter(
                    selected_filter: "sellers",
                  )))),
          GoRoute(
              path: "shop/:slug",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(
                      child: (SellerDetails(
                    slug: getParameter(state, "slug"),
                  )))),
          GoRoute(
              path: "todays-deal",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  MaterialPage(child: (TodaysDealProducts()))),
          GoRoute(
              path: "coupons",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(child: (Coupons()))),
          GoRoute(
              path: "update",
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const MaterialPage(child: (UpdateScreen()))),
        ])
  ],
);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // BusinessSettingHelper.setInitLang();
    Future.microtask(() async {
      await Firebase.initializeApp();
      if (OtherConfig.USE_PUSH_NOTIFICATION)
        PushNotificationService.initialize();
    });
    _handleDeepLink();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => HomeProvider(_initAddress),
        ),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CartCounter()),
        ChangeNotifierProvider(create: (context) => SelectAddressProvider()),
        ChangeNotifierProvider(
          create: (context) => UnReadNotificationCounter(),
        ),
        ChangeNotifierProvider(create: (context) => CurrencyPresenter()),

        ///
        //ChangeNotifierProvider(create: (_) => BannerProvider()),
        // ChangeNotifierProvider(create: (_) => HomePresenter()),
        ChangeNotifierProvider(create: (_) => BlogProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => MyClassifiedProvider()),
        ChangeNotifierProvider(lazy: false, create: (_) => CartProvider()),
      ],
      child: const MyMaterialApp(),
    );
  }
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    setCustomUserDataClarity();
    return Consumer<LocaleProvider>(
      builder: (context, provider, snapshot) {
        final ThemeProvider theme =
            Provider.of<ThemeProvider>(context, listen: true);

        return MaterialApp.router(
          routerConfig: routes,
          title: AppConfig.appNameOnDeviceLang,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            if (AppConfig.turnDevicePreviewOn)
              child = DevicePreview.appBuilder(context, child);
            return Directionality(
              textDirection:
                  app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
              child: OneContext().builder(context, child),
            );
          },
          theme: appTheme(theme),
          localizationsDelegates: const [
            CustomLocalizationDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: provider.locale,
          key: ValueKey("${provider.locale.languageCode}"),
          supportedLocales: CustomLocalization.supportedLocales,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (CustomLocalization.isSupported(deviceLocale!))
              return deviceLocale;

            return provider.locale;
          },
        );
      },
    );
  }
}

ThemeData appTheme(ThemeProvider theme) {
  return ThemeData(
    primaryColor: theme.primary,
    scaffoldBackgroundColor: MyTheme.white,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: "PublicSansSerif",
    textTheme: MyTheme.textTheme1,
    fontFamilyFallback: const ['NotoSans'],
    colorScheme: ColorScheme.light(
      primary: AppConfig.businessSettingsData.primaryColor ?? theme.primary,
      secondary:
          AppConfig.businessSettingsData.secondaryColor ?? theme.secondary,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all<bool>(false),
    ),
  );
}

Future<void> _handleDeepLink() async {
  final appLinks = AppLinks(); // AppLinks is singleton
  final Uri? uri = await appLinks.getInitialLink();
  WidgetsBinding.instance.addPostFrameCallback(
    (_) {
      if (uri != null) OneContext().key.currentContext!.go(uri.paramPath);
    },
  );
  appLinks.uriLinkStream.listen((Uri? uriStream) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (uriStream != null)
          OneContext().key.currentContext!.go(uriStream.paramPath);
      },
    );
  });
}

void recordError(Object error, StackTrace? stack) {
  log("error: $error");
  log("stack: $stack");

  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  if (AppConfig.businessSettingsData.useSentry) {
    Sentry.captureException(error, stackTrace: stack);
  }
}
