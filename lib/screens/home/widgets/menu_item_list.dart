import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/screens/filter.dart';
import 'package:active_ecommerce_cms_demo_app/screens/flash_deal/flash_deal_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/menu_item_model.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/todays_deal_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/top_sellers.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:provider/provider.dart';

import '../../../presenter/home_provider.dart';

class MenuItemList extends StatelessWidget {
  const MenuItemList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final HomeProvider homeProvider = context.read<HomeProvider>();
    final List<MenuItemModel> menuItems = [
      if (homeProvider.isTodayDeal)
        MenuItemModel(
          title: 'todays_deal_ucf'.tr(context: context),
          image: AppImages.todayDeal,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TodaysDealProducts();
            }));
          },
          textColor: Colors.white,
          backgroundColor: const Color(0xffE62D05),
        ),
      if (homeProvider.isFlashDeal)
        MenuItemModel(
          title: 'flash_deal_ucf'.tr(context: context),
          image: AppImages.flashDeal,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FlashDealList();
            }));
          },
          textColor: Colors.white,
          backgroundColor: const Color(0xffF6941C),
        ),
      if (homeProvider.isBrands)
        MenuItemModel(
          title: 'brands_ucf'.tr(context: context),
          image: AppImages.brands,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const Filter(selected_filter: "brands");
            }));
          },
          textColor: const Color(0xff263140),
          backgroundColor: const Color(0xffE9EAEB),
        ),
      if (AppConfig.businessSettingsData.vendorSystemActivation)
        MenuItemModel(
          title: 'top_sellers_ucf'.tr(context: context),
          image: AppImages.TopSellers,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const TopSellers();
            }));
          },
          textColor: const Color(0xff263140),
          backgroundColor: const Color(0xffE9EAEB),
        ),
    ];
    if (menuItems.isEmpty) return emptyWidget;

    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];

          return GestureDetector(
            onTap: item.onTap,
            child: Container(
              margin: const EdgeInsetsDirectional.only(start: 8),
              height: 40,
              width: 106,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
                color: item.backgroundColor,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingSmallExtra),
                      child: Container(
                        height: 16,
                        width: 16,
                        alignment: Alignment.center,
                        child: Image.asset(
                          item.image,
                          color: item.textColor,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: item.textColor,
                          fontWeight: FontWeight.w300,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
