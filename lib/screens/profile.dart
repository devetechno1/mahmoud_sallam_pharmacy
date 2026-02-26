// ignore_for_file: dead_code

import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/custom/aiz_route.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/unRead_notification_counter.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/address.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auction/auction_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/blog_list_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/classified_ads/classified_ads.dart';
import 'package:active_ecommerce_cms_demo_app/screens/classified_ads/my_classified_ads.dart';
import 'package:active_ecommerce_cms_demo_app/screens/coupon/coupons.dart';
import 'package:active_ecommerce_cms_demo_app/screens/customer_support_screen.dart'
    show CustomerSupportScreen;
import 'package:active_ecommerce_cms_demo_app/screens/digital_product/digital_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/filter.dart';
import 'package:active_ecommerce_cms_demo_app/screens/flash_deal/flash_deal_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/last_view_product.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/top_selling_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/refund_request.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wholesales_screen.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wishlist/widgets/page_animation.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import 'package:route_transitions/route_transitions.dart';

import '../app_config.dart';
import '../custom/btn.dart';
import '../presenter/home_provider.dart';
import '../repositories/auth_repository.dart';
import 'auction/auction_bidded_products.dart';
import 'auction/auction_purchase_history.dart';
import 'auth/custom_otp.dart';
import 'change_language.dart';
import 'chat/messenger_list.dart';
import 'checkout/cart.dart';
import 'club_point.dart';
import 'common_webview_screen.dart';
import 'currency_change.dart';
import 'digital_product/purchased_digital_produts.dart';

import 'followed_sellers.dart';
import 'notification/notification_list.dart';
import 'orders/order_list.dart';
import 'profile_edit.dart';
import 'wallet.dart';
import 'wishlist/wishlist.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, this.show_back_button = false}) : super(key: key);

  final bool show_back_button;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // ScrollController _mainScrollController = ScrollController();
  // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // ✅ max width for tablet/desktop-like screens
  static const double _contentMaxWidth = 680;

  int? _cartCounter = 0;
  String _cartCounterString = "00";
  int? _wishlistCounter = 0;
  String _wishlistCounterString = "00";
  int? _orderCounter = 0;
  String _orderCounterString = "00";
  late BuildContext loadingContext;

  @override
  void initState() {
    super.initState();

    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  void fetchAll() {
    fetchCounters();
    getNotificationCount();
  }

  Future<void> getNotificationCount() async {
    Provider.of<UnReadNotificationCounter>(context, listen: false).getCount();
  }

  Future<void> fetchCounters() async {
    final profileCountersResponse =
        await ProfileRepository().getProfileCountersResponse();

    _cartCounter = profileCountersResponse.cart_item_count;
    _wishlistCounter = profileCountersResponse.wishlist_item_count;
    _orderCounter = profileCountersResponse.order_count;

    _cartCounterString =
        counterText(_cartCounter.toString(), default_length: 2);
    _wishlistCounterString =
        counterText(_wishlistCounter.toString(), default_length: 2);
    _orderCounterString =
        counterText(_orderCounter.toString(), default_length: 2);

    setState(() {});
  }

  Future<void> deleteAccountReq() async {
    loading();
    final response = await AuthRepository().getAccountDeleteResponse();

    if (response.result) {
      AuthHelper().clearUserData();
      Navigator.pop(loadingContext);
      goHome(context);
    }
    ToastComponent.showDialog(response.message);
  }

  String counterText(String txt, {default_length = 3}) {
    final blankZeros = default_length == 3 ? "000" : "00";
    var leadingZeros = "";
    if (default_length == 3 && txt.length == 1) {
      leadingZeros = "00";
    } else if (default_length == 3 && txt.length == 2) {
      leadingZeros = "0";
    } else if (default_length == 2 && txt.length == 1) {
      leadingZeros = "0";
    }

    var newtxt = (txt == "" || txt == null.toString()) ? blankZeros : txt;

    if (default_length > txt.length) {
      newtxt = leadingZeros + newtxt;
    }

    return newtxt;
  }

  void reset() {
    _cartCounter = 0;
    _cartCounterString = "00";
    _wishlistCounter = 0;
    _wishlistCounterString = "00";
    _orderCounter = 0;
    _orderCounterString = "00";
  }

  List<int> listItem = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  Future<void> onTapLogout(BuildContext context) async {
    await AuthHelper().clearUserData();
    goHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: buildView(context),
    );
  }

  // ✅ helper: keep content centered with max width (tablet fix)
  Widget _wrapConstrained(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
        child: child,
      ),
    );
  }

  Widget buildView(context) {
    return Container(
      color: Colors.white,
      height: DeviceInfo(context).height,
      child: Stack(
        children: [
          Container(
            height: DeviceInfo(context).height! / 1.6,
            width: DeviceInfo(context).width,
            color: Theme.of(context).primaryColor,
            alignment: Alignment.topRight,
            child: Image.asset(
              AppImages.backgroundOne,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: buildCustomAppBar(context),
            body: buildBody(),
          ),
        ],
      ),
    );
  }

  RefreshIndicator buildBody() {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: _onPageRefresh,
      displacement: 10,
      child: buildBodyChildren(),
    );
  }

  CustomScrollView buildBodyChildren() {
    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _wrapConstrained(buildCountersRow()),
              _wrapConstrained(buildHorizontalSettings()),
              _wrapConstrained(buildSettingAndAddonsHorizontalMenu()),
              _wrapConstrained(buildBottomVerticalCardList()),
            ]),
          ),
        )
      ],
    );
  }

  PreferredSize buildCustomAppBar(context) {
    return PreferredSize(
      preferredSize: Size(DeviceInfo(context).width!, 92),
      child: Container(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.only(end: 18, bottom: 12),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusVeryExtra),
                    child: const SizedBox(
                      height: 30,
                      width: 30,
                      child: Icon(
                        Icons.close,
                        color: MyTheme.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: buildAppbarSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomVerticalCardList() {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 120, top: AppDimensions.paddingNormal),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecorations.buildBoxDecoration_1()
          .copyWith(boxShadow: [const BoxShadow(spreadRadius: 0.08)]),
      child: Column(
        children: [
          BottomVerticalCardListItemWidget(
            AppImages.products,
            'top_selling_products_ucf'.tr(context: context),
            onPressed: () {
              final bool isPhone = user_phone.$.trim().isNotEmpty == true &&
                  AppConfig.businessSettingsData.otpProviders.isNotEmpty;
              AIZRoute.push(
                context,
                TopSellingProducts(),
                isPhone ? user_phone.$.trim() : user_email.$.trim(),
                null,
                isPhone,
              );
            },
          ),
          if (whole_sale_addon_installed.$)
            BottomVerticalCardListItemWidget(
              AppImages.wholeSale,
              'wholesale_product'.tr(context: context),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WholesalesScreen(),
                  ),
                );
              },
            ),
          BottomVerticalCardListItemWidget(
            AppImages.blog,
            'blog_list_ucf'.tr(context: context),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlogListScreen()),
              );
            },
          ),
          BottomVerticalCardListItemWidget(
            AppImages.download,
            'all_digital_products_ucf'.tr(context: context),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const DigitalProducts();
              }));
            },
          ),
          BottomVerticalCardListItemWidget(
            AppImages.coupon,
            'coupons_ucf'.tr(context: context),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Coupons();
              }));
            },
          ),
          Selector<HomeProvider, bool>(
            selector: (_, provider) => provider.isFlashDealInitial,
            builder: (context, isFlashDealInitial, child) {
              if (isFlashDealInitial != false) {
                return BottomVerticalCardListItemWidget(
                  AppImages.flashDeal,
                  'flash_deal_ucf'.tr(context: context),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return FlashDealList();
                    }));
                  },
                );
              }
              return emptyWidget;
            },
          ),
          BottomVerticalCardListItemWidget(
            AppImages.brands,
            'brands_ucf'.tr(context: context),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Filter(selected_filter: "brands");
              }));
            },
          ),
          if (AppConfig.businessSettingsData.classifiedProduct && is_logged_in.$)
            BottomVerticalCardListItemWidget(
              AppImages.myClassified,
              'my_classified_ads_ucf'.tr(context: context),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MyClassifiedAds();
                }));
              },
            ),
          if (AppConfig.businessSettingsData.classifiedProduct)
            BottomVerticalCardListItemWidget(
              AppImages.classifiedProduct,
              'all_classified_ads_ucf'.tr(context: context),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ClassifiedAds();
                }));
              },
            ),
          if (AppConfig.businessSettingsData.lastViewedProductActivation &&
              is_logged_in.$)
            BottomVerticalCardListItemWidget(
              AppImages.lastViewProduct,
              'last_view_product_ucf'.tr(context: context),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const LastViewProduct();
                }));
              },
            ),
          if (auction_addon_installed.$) const AuctionTileWidget(),
          if (AppConfig.businessSettingsData.classifiedProduct)
            BottomVerticalCardListItemWidget(
              AppImages.shop,
              'browse_all_sellers_ucf'.tr(context: context),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const Filter(
                    selected_filter: "sellers",
                  );
                }));
              },
            ),
          if (is_logged_in.$ && (AppConfig.businessSettingsData.classifiedProduct))
            BottomVerticalCardListItemWidget(
              AppImages.followSeller,
              'followed_sellers_ucf'.tr(context: context),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const FollowedSellers();
                }));
              },
            ),
          BottomVerticalCardListItemWidget(
            AppImages.delete,
            'privacy_policy_ucf'.tr(context: context),
            icon: Icons.lock_outline_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommonWebviewScreen(
                    page_name: 'privacy_policy_ucf'.tr(context: context),
                    url: "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
                  ),
                ),
              );
            },
            showDivider: is_logged_in.$,
          ),
          if (is_logged_in.$)
            BottomVerticalCardListItemWidget(
              AppImages.delete,
              'delete_my_account'.tr(context: context),
              onPressed: deleteWarningDialog,
              showDivider: true,
            ),
          if (is_logged_in.$)
            BottomVerticalCardListItemWidget(
              icon: Icons.support_agent_sharp,
              AppImages.delete,
              'customer_support'.tr(context: context),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const CustomerSupportScreen();
                }));
              },
              showDivider: false,
            ),
        ],
      ),
    );
  }

  Widget buildHorizontalSettings() {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildHorizontalSettingItem(
            true,
            AppImages.language,
            'language_ucf'.tr(context: context),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const ChangeLanguage();
                  },
                ),
              );
            },
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const CurrencyChange();
              }));
            },
            child: Column(
              children: [
                Image.asset(
                  AppImages.currency,
                  height: 16,
                  width: 16,
                  color: MyTheme.white,
                ),
                const SizedBox(height: 5),
                Text(
                  'currency_ucf'.tr(context: context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: MyTheme.white,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          buildHorizontalSettingItem(
            is_logged_in.$,
            AppImages.edit,
            'edit_profile_ucf'.tr(context: context),
            is_logged_in.$
                ? () {
                    final bool isPhone =
                        user_phone.$.trim().isNotEmpty == true &&
                            AppConfig
                                .businessSettingsData.otpProviders.isNotEmpty;
                    AIZRoute.push(
                      context,
                      ProfileEdit(),
                      isPhone ? user_phone.$.trim() : user_email.$.trim(),
                      null,
                      isPhone,
                    ).then((value) {
                      onPopped(value);
                    });
                  }
                : () => showLoginWarning(),
          ),
          buildHorizontalSettingItem(
            is_logged_in.$,
            AppImages.location,
            'address_ucf'.tr(context: context),
            is_logged_in.$
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const AddressScreen(goHome: false);
                        },
                      ),
                    );
                  }
                : () => showLoginWarning(),
          ),
        ],
      ),
    );
  }

  InkWell buildHorizontalSettingItem(
    bool isLogin,
    String img,
    String text,
    void Function()? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            img,
            height: 16,
            width: 16,
            color: isLogin ? MyTheme.white : MyTheme.blue_grey,
          ),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isLogin ? MyTheme.white : MyTheme.blue_grey,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }

  dynamic showLoginWarning() {
    return ToastComponent.showDialog(
      'you_need_to_log_in'.tr(context: context),
      isError: true,
    );
  }

  Future deleteWarningDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'delete_account_warning_title'.tr(context: context),
          style: const TextStyle(
            fontSize: 15,
            color: MyTheme.dark_font_grey,
          ),
        ),
        content: Text(
          'delete_account_warning_description'.tr(context: context),
          style: const TextStyle(
            fontSize: 13,
            color: MyTheme.dark_font_grey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              pop(context);
            },
            child: Text('no_ucf'.tr(context: context)),
          ),
          TextButton(
            onPressed: () {
              pop(context);
              deleteAccountReq();
            },
            child: Text('yes_ucf'.tr(context: context)),
          )
        ],
      ),
    );
  }

  Widget buildSettingAndAddonsHorizontalMenu() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // ✅ adaptive grid for tablets
        int crossAxisCount = 3;
        if (w >= 900) {
          crossAxisCount = 6;
        } else if (w >= 720) {
          crossAxisCount = 5;
        } else if (w >= 600) {
          crossAxisCount = 4;
        }

        final double horizontalPadding = w >= 600 ? 16 : 40;

        return Container(
          margin: const EdgeInsets.only(top: AppDimensions.paddingNormal),
          width: DeviceInfo(context).width,
          height: 225,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [BoxShadow(spreadRadius: 0.08)],
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusHalfSmall),
          ),
          child: GridView(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: horizontalPadding,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              childAspectRatio: w >= 600 ? 1.7 : 1.5,
            ),
            children: [
              buildSettingAndAddonsHorizontalMenuItem(
                AppImages.wallet,
                'my_wallet_ucf'.tr(context: context),
                () {
                  Navigator.push(
                    context,
                    PageAnimation.fadeRoute(const Wallet()),
                  );
                },
              ),
              buildSettingAndAddonsHorizontalMenuItem(
                AppImages.orders,
                'orders_ucf'.tr(context: context),
                is_logged_in.$
                    ? () {
                        Navigator.push(
                          context,
                          PageAnimation.fadeRoute(const OrderList()),
                        );
                      }
                    : () => null,
              ),
              buildSettingAndAddonsHorizontalMenuItem(
                AppImages.heart,
                'my_wishlist_ucf'.tr(context: context),
                is_logged_in.$
                    ? () {
                        Navigator.push(
                          context,
                          PageAnimation.fadeRoute(Wishlist()),
                        );
                      }
                    : () => null,
              ),
              if (club_point_addon_installed.$)
                buildSettingAndAddonsHorizontalMenuItem(
                  AppImages.points,
                  'club_point_ucf'.tr(context: context),
                  is_logged_in.$
                      ? () {
                          Navigator.push(
                            context,
                            PageAnimation.fadeRoute(Clubpoint()),
                          );
                        }
                      : () => null,
                ),
              badges.Badge(
                showBadge: is_logged_in.$,
                position: badges.BadgePosition.topEnd(
                  top: 2,
                  end: AppDimensions.paddingLarge,
                ),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.circle,
                  badgeColor: Theme.of(context).primaryColor,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusNormal),
                  padding: const EdgeInsets.all(
                    AppDimensions.paddingSmallExtra,
                  ),
                ),
                ignorePointer: true,
                badgeContent: Consumer<UnReadNotificationCounter>(
                  builder: (context, notification, child) {
                    return Text(
                      "${notification.unReadNotificationCounter}",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                child: buildSettingAndAddonsHorizontalMenuItem(
                  AppImages.notification,
                  'notification_ucf'.tr(context: context),
                  is_logged_in.$
                      ? () {
                          Navigator.push(
                            context,
                            PageAnimation.fadeRoute(
                              const NotificationList(),
                            ),
                          ).then((value) {
                            onPopped(value);
                          });
                        }
                      : () => null,
                ),
              ),
              buildSettingAndAddonsHorizontalMenuItem(
                AppImages.download,
                'downloads_ucf'.tr(context: context),
                is_logged_in.$
                    ? () {
                        Navigator.push(
                          context,
                          PageAnimation.fadeRoute(
                            const PurchasedDigitalProducts(),
                          ),
                        );
                      }
                    : () => null,
              ),
              if (AppConfig.businessSettingsData.conversationSystem)
                buildSettingAndAddonsHorizontalMenuItem(
                  AppImages.messages,
                  'messages_ucf'.tr(context: context),
                  is_logged_in.$
                      ? () {
                          Navigator.push(
                            context,
                            PageAnimation.fadeRoute(MessengerList()),
                          );
                        }
                      : () => null,
                ),
              if (AppConfig.businessSettingsData.classifiedProduct)
                buildSettingAndAddonsHorizontalMenuItem(
                  AppImages.classifiedProduct,
                  'classified_products'.tr(context: context),
                  is_logged_in.$
                      ? () {
                          Navigator.push(
                            context,
                            PageAnimation.fadeRoute(const MyClassifiedAds()),
                          );
                        }
                      : () => null,
                ),
              if (refund_addon_installed.$)
                buildSettingAndAddonsHorizontalMenuItem(
                  AppImages.refund,
                  'refund_requests_ucf'.tr(context: context),
                  is_logged_in.$
                      ? () {
                          Navigator.push(
                            context,
                            PageAnimation.fadeRoute(RefundRequest()),
                          );
                        }
                      : () => null,
                ),
            ],
          ),
        );
      },
    );
  }

  Container buildSettingAndAddonsHorizontalMenuItem(
    String img,
    String text,
    Function() onTap,
  ) {
    return Container(
      alignment: Alignment.center,
      child: InkWell(
        onTap: is_logged_in.$
            ? onTap
            : () {
                showLoginWarning();
              },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              img,
              width: 16,
              height: 16,
              color:
                  is_logged_in.$ ? MyTheme.dark_font_grey : MyTheme.medium_grey_50,
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: is_logged_in.$
                    ? MyTheme.dark_font_grey
                    : MyTheme.medium_grey_50,
                fontSize: 11.5,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCountersRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final bool isWide = w >= 600;

        final double itemWidth = isWide ? (w / 3) - 12 : DeviceInfo(context).width! / 3.5;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildCountersRowItem(
              _cartCounterString,
              'in_your_cart_all_lower'.tr(context: context),
              width: itemWidth,
              onTap: () => Navigator.push(
                context,
                PageAnimation.fadeRoute(const Cart(has_bottomnav: false)),
              ),
            ),
            buildCountersRowItem(
              _wishlistCounterString,
              'in_your_wishlist_all_lower'.tr(context: context),
              width: itemWidth,
              onTap: () => Navigator.push(
                context,
                PageAnimation.fadeRoute(Wishlist()),
              ),
            ),
            buildCountersRowItem(
              _orderCounterString,
              'your_ordered_all_lower'.tr(context: context),
              width: itemWidth,
              onTap: () => Navigator.push(
                context,
                PageAnimation.fadeRoute(const OrderList()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildCountersRowItem(
    String counter,
    String title, {
    double? width,
    Future<void> Function()? onTap,
  }) {
    return InkWell(
      onTap: is_logged_in.$ && onTap != null
          ? () => onTap.call().then((_) => onPopped(null))
          : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
      child: Container(
        margin: const EdgeInsets.only(top: AppDimensions.paddingLarge),
        padding: const EdgeInsets.symmetric(vertical: 14),
        width: width ?? DeviceInfo(context).width! / 3.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
          color: MyTheme.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              counter,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 18,
                color: MyTheme.dark_font_grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              maxLines: 2,
              style: const TextStyle(
                color: Color(0xff3E4447),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppbarSection() {
    return Container(
      alignment: Alignment.center,
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14.0),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusVeryExtra),
                border: Border.all(color: MyTheme.white, width: 1),
              ),
              child: is_logged_in.$
                  ? ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppDimensions.radiusVeryExtra),
                      ),
                      child: FadeInImage.assetNetwork(
                        placeholder: AppImages.placeholder,
                        image: "${avatar_original.$}",
                        fit: BoxFit.fill,
                      ),
                    )
                  : Image.asset(
                      AppImages.profilePlaceholder,
                      height: 48,
                      width: 48,
                      fit: BoxFit.fitHeight,
                    ),
            ),
          ),
          buildUserInfo(),
          const Spacer(),
          Btn.basic(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusHalfSmall),
              side: const BorderSide(color: MyTheme.white),
            ),
            child: Text(
              is_logged_in.$
                  ? 'logout_ucf'.tr(context: context)
                  : 'login_ucf'.tr(context: context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              if (is_logged_in.$) {
                onTapLogout(context);
              } else {
                context.push("/login");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildUserInfo() {
    return is_logged_in.$
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${user_name.$}",
                style: const TextStyle(
                  fontSize: 14,
                  color: MyTheme.white,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: "${user_name.$}".direction,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "${user_phone.$.trim().isEmpty ? user_email.$ : user_phone.$}",
                  style: const TextStyle(color: MyTheme.light_grey),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],
          )
        : Text(
            'login_or_reg'.tr(context: context),
            style: const TextStyle(
              fontSize: 14,
              color: MyTheme.white,
              fontWeight: FontWeight.bold,
            ),
          );
  }

  void loading() {
    showDialog(
      context: context,
      builder: (context) {
        loadingContext = context;
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 10),
              Text("${'please_wait_ucf'.tr(context: context)}"),
            ],
          ),
        );
      },
    );
  }
}

class AuctionTileWidget extends StatefulWidget {
  const AuctionTileWidget({super.key});

  @override
  State<AuctionTileWidget> createState() => AuctionTileWidgetState();
}

class AuctionTileWidgetState extends State<AuctionTileWidget> {
  bool _auctionExpand = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MyTheme.light_grey,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _auctionExpand = !_auctionExpand;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(end: 24.0),
                            child: Image.asset(
                              AppImages.auction,
                              height: 16,
                              width: 16,
                              color: MyTheme.dark_font_grey,
                            ),
                          ),
                          Text(
                            'auction_ucf'.tr(context: context),
                            style: const TextStyle(
                                fontSize: 12, color: MyTheme.dark_font_grey),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _auctionExpand
                          ? (app_language_rtl.$ == true ? -0.25 : 0.25)
                          : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.navigate_next_rounded,
                        size: 20,
                        color: MyTheme.dark_font_grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            curve: Curves.easeInOut,
            child: _auctionExpand
                ? Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsetsDirectional.only(start: 40, bottom: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => OneContext().push(
                            MaterialPageRoute(
                              builder: (_) => const AuctionProducts(),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                const Text(
                                  '-',
                                  style: TextStyle(
                                    color: MyTheme.dark_font_grey,
                                  ),
                                ),
                                Text(
                                  " ${'on_auction_products_ucf'.tr(context: context)}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: MyTheme.dark_font_grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (is_logged_in.$)
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => OneContext().push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AuctionBiddedProducts(),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      const Text(
                                        '-',
                                        style: TextStyle(
                                          color: MyTheme.dark_font_grey,
                                        ),
                                      ),
                                      Text(
                                        " ${'bidded_products_ucf'.tr(context: context)}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: MyTheme.dark_font_grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => OneContext().push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AuctionPurchaseHistory(),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      const Text(
                                        '-',
                                        style: TextStyle(
                                          color: MyTheme.dark_font_grey,
                                        ),
                                      ),
                                      Text(
                                        " ${'purchase_history_ucf'.tr(context: context)}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: MyTheme.dark_font_grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  )
                : emptyWidget,
          ),
        ],
      ),
    );
  }
}

class BottomVerticalCardListItemWidget extends StatelessWidget {
  const BottomVerticalCardListItemWidget(
    this.img,
    this.label, {
    super.key,
    this.onPressed,
    this.isDisable = false,
    this.icon,
    this.showDivider = true,
    this.isBold = false,
  });

  // ✅ item max width inside wide screens
  static const double _itemMaxWidth = 640;

  final String img;
  final String label;
  final Function()? onPressed;
  final bool isDisable;
  final IconData? icon;
  final bool showDivider;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _itemMaxWidth),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: showDivider
                    ? const BorderSide(
                        color: MyTheme.light_grey,
                        width: 1,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 24.0),
                  child: icon == null
                      ? Image.asset(
                          img,
                          height: 16,
                          width: 16,
                          color: isDisable
                              ? MyTheme.primaryColor
                              : MyTheme.dark_font_grey,
                        )
                      : Icon(
                          icon,
                          size: 18,
                          color: isDisable
                              ? MyTheme.grey_153
                              : MyTheme.dark_font_grey,
                        ),
                ),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDisable
                          ? MyTheme.primaryColor
                          : MyTheme.dark_font_grey,
                      fontWeight:
                          isBold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}