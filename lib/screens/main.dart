import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/main.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/bottom_appbar_index.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/cart_counter.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/category_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/checkout/cart.dart';
import 'package:active_ecommerce_cms_demo_app/screens/profile.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';

import '../app_config.dart';
import '../helpers/camera_helper.dart';
import '../presenter/cart_provider.dart';
import '../presenter/prescription_controller.dart';
import '../repositories/upload_repository.dart';
import '../ui_elements/close_app_dialog_widget.dart';
import '../ui_elements/image_viewer_page.dart';
import '../ui_elements/prescription_sheet.dart';

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  // ---- Navigation / Pages ----
  int _currentIndex = 0;
  late final List<Widget> _pages;
  final CartCounter counter = CartCounter();
  final BottomAppbarIndex bottomAppbarIndex = BottomAppbarIndex();
  late final HomeProvider homeProvider = context.read<HomeProvider>();

  // ---- Cart / Data ----
  void fetchAll() {
    getCartData();
  }

  void getCartData() {
    Provider.of<CartProvider>(context, listen: false).fetchData(context);
  }

  // ---- Prescription tab helpers (keep same behavior) ----
  int setIndexWhenPrescription(int index) {
    if (showPrescription && index > 1) return index - 1;
    return index;
  }

  int getIndexWhenPrescription(int index) {
    if (showPrescription && index > 1) return index + 1;
    return index;
  }

  void onTapped(int i) {
    if (showPrescription && i == 2) {
      onTapPrescription();
      return;
    }
    fetchAll();

    i = setIndexWhenPrescription(i);

    if (AppConfig.businessSettingsData.guestCheckoutStatus && (i == 2)) {
      // allowed guest
    } else if (!AppConfig.businessSettingsData.guestCheckoutStatus &&
        (i == 2) &&
        !is_logged_in.$) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Login()));
      return;
    }

    if (i == 3) {
      routes.push("/dashboard").then(
        (value) async {
          fetchAll();
          await homeProvider.onRefresh();
        },
      );
      return;
    }
    setState(() {
      _currentIndex = getIndexWhenPrescription(i);
    });
  }

  // ---- Lifecycle ----
  @override
  void initState() {
    super.initState();

    _pages = [
      AppConfig.businessSettingsData.selectedHomePage.screen,
      const CategoryList(slug: "", name: "", is_base_category: true),
      if (showPrescription) emptyWidget,
      Cart(has_bottomnav: true, from_navigation: true, counter: counter),
      const Profile(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAll();
      homeProvider.showPopupBanner(context);
    });

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: const [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  bool _dialogShowing = false;

  bool get showPrescription =>
      AppConfig.businessSettingsData.isPrescriptionActive;

  Future<void> _handleSystemBack() async {
    // أي تبويب غير الهوم (ومنهم Category) يرجع للهوم ومايقفلش التطبيق
    if (_currentIndex != 0) {
      fetchAll();
      setState(() {
        _currentIndex = 0;
      });
      return;
    }

    // وإنت في الهوم: اعرض ديالوج الخروج
    if (_dialogShowing) return;

    setState(() {
      _dialogShowing = true;
    });

    final bool shouldExit = await showDialog<bool?>(
          context: context,
          builder: (_) => const CloseAppDialogWidget(),
        ) ??
        false;

    setState(() {
      _dialogShowing = false;
    });

    if (shouldExit) {
      SystemNavigator.pop(); // اقفل التطبيق فعليًا
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // امنع الإغلاق التلقائي
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          // appBar: customStatusBar(SystemUiOverlayStyle.dark),
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          floatingActionButton: showPrescription
              ? Transform.translate(
                  offset: const Offset(0, 4),
                  child: FloatingActionButton(
                    onPressed: onTapPrescription,
                    child: const FaIcon(FontAwesomeIcons.filePrescription),
                  ),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: onTapped,
            currentIndex: _currentIndex,
            backgroundColor: Colors.white.withValues(alpha: 0.95),
            unselectedItemColor: const Color.fromRGBO(168, 175, 179, 1),
            selectedItemColor: Theme.of(context).primaryColor,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(168, 175, 179, 1),
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                  child: Image.asset(
                    AppImages.home,
                    color: _currentIndex == 0
                        ? Theme.of(context).primaryColor
                        : const Color.fromRGBO(153, 153, 153, 1),
                    height: 16,
                  ),
                ),
                label: 'home_ucf'.tr(context: context),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                  child: Image.asset(
                    AppImages.categories,
                    color: _currentIndex == getIndexWhenPrescription(1)
                        ? Theme.of(context).primaryColor
                        : const Color.fromRGBO(153, 153, 153, 1),
                    height: 16,
                  ),
                ),
                label: 'categories_ucf'.tr(context: context),
              ),
              if (showPrescription)
                BottomNavigationBarItem(
                  icon: const SizedBox(height: 34),
                  label: 'prescription'.tr(context: context),
                ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                  child: badges.Badge(
                    badgeStyle: badges.BadgeStyle(
                      shape: badges.BadgeShape.circle,
                      badgeColor: Theme.of(context).primaryColor,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusNormal),
                      padding: const EdgeInsets.all(5),
                    ),
                    badgeAnimation: const badges.BadgeAnimation.slide(
                      toAnimate: false,
                    ),
                    child: Image.asset(
                      AppImages.cart,
                      color: _currentIndex == getIndexWhenPrescription(2)
                          ? Theme.of(context).primaryColor
                          : const Color.fromRGBO(153, 153, 153, 1),
                      height: 16,
                    ),
                    badgeContent: Consumer<CartCounter>(
                      builder: (context, cart, child) {
                        return Text(
                          "${cart.cartCounter}",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
                label: 'cart_ucf'.tr(context: context),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                  child: Image.asset(
                    AppImages.profile,
                    color: _currentIndex == getIndexWhenPrescription(3)
                        ? Theme.of(context).primaryColor
                        : const Color.fromRGBO(153, 153, 153, 1),
                    height: 16,
                  ),
                ),
                label: 'profile_ucf'.tr(context: context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onTapPrescription() async {
    if (!AppConfig.businessSettingsData.guestCheckoutStatus &&
        !is_logged_in.$) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Login()));
      return;
    }

    addPrescriptionFN(
      OneContext().context!,
      homeProvider.presc,
      () => setState(() => _currentIndex = 3),
    );
  }
}

Future<void> addPrescriptionFN(
  BuildContext context,
  PrescriptionController _presc, [
  void Function()? afterUpload,
]) async {
  if (_presc.imagesVN.value.isEmpty) {
    await CameraHelper.openImageSourceSheet(
      context,
      onAddImages: (x) => _presc.addImages(x),
    );
  }
  if (_presc.imagesVN.value.isEmpty) return;
  await showPrescriptionSheetReusable(
    context: context,
    imagesController: _presc,
    onAddMore: () async {
      await CameraHelper.openImageSourceSheet(
        context,
        onAddImages: (x) => _presc.addImages(x),
      );
    },
    onReplaceAt: (i) async {
      final nx = await CameraHelper.getImageBottomSheet(
        context,
        cameraTitle: 'replace_camera'.tr(context: context),
        galleryTitle: 'replace_gallery'.tr(context: context),
      );
      if (nx != null) _presc.replaceAt(i, nx);
    },
    onDeleteAt: (i) => _presc.removeAt(i),
    onClearAll: () async {
      final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('clear_all_images'.tr(context: context)),
              content: Text('confirm_remove_all_prescription_images'
                  .tr(context: context)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('cancel'.tr(context: context)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('yes_clear'.tr(context: context)),
                ),
              ],
            ),
          ) ??
          false;
      if (ok) {
        _presc.clearAll();
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    },
    onSubmit: () async {
      if (_presc.images.isEmpty) return;
      _presc.setUploading(true);
      _presc.setProgress(0.0);
      try {
        await FileUploadRepository().multiFileUploadHttpWithProgress(
          "carts/prescription/add",
          files: _presc.images,
          onProgress: _presc.setProgress,
        );
        Provider.of<CartProvider>(context, listen: false).fetchData(context);
        if (Navigator.canPop(context)) Navigator.pop(context);
        _presc.clearAll();
        afterUpload?.call();
      } catch (e, s) {
        String error = '';

        try {
          error += "${jsonDecode(e.toString())["message"]}";
        } catch (a) {
          error += "$e";
        }

        ToastComponent.showDialog(error, isError: true);
        recordError(e, s);
      } finally {
        _presc.setUploading(false);
      }
    },
    onOpenViewer: (index) {
      final imgs = _presc.images;
      if (imgs.isEmpty) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageViewerPage.fromFiles(
            imgs,
            initialIndex: index,
            heroTags: List.generate(
              imgs.length,
              (index) => "${imgs[index].path}",
            ),
          ),
        ),
      );
    },
  );
}
