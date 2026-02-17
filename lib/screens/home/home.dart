import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/flash%20deals%20banner/flash_deal_banner.dart';
import 'package:active_ecommerce_cms_demo_app/custom/home_banners/home_banners_one.dart';
import 'package:active_ecommerce_cms_demo_app/custom/home_banners/home_banners_three.dart';
import 'package:active_ecommerce_cms_demo_app/custom/home_banners/home_banners_two.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/featured_products_list_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/featured_category/featured_category_horizontal.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/menu_item_list.dart';

import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../custom/home_all_products_2.dart';
import '../../custom/home_carousel_slider.dart';
import '../../custom/pirated_widget.dart';
import 'widgets/carousel_and_flash_sale_sliver.dart';
import 'widgets/global_home_screen_widget.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return GlobalHomeScreenWidget(
      slivers: <Widget>[
        const CarouselAndFlashSaleSliver(isFlashSaleCircle: true),
        SliverList(
          delegate: SliverChildListDelegate([
            const PiratedWidget(),
            const SizedBox(height: 10),
            const HomeCarouselSlider(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(bottom: AppDimensions.paddingDefault),
              child: MenuItemList(),
            ),
            const HomeBannersOne(),
          ]),
        ),

        //Featured Categories
        const CategoryListHorizontal(),
        const SliverToBoxAdapter(child: HomeBannersTwo()),
        // const  CategoryListVertical(crossAxisCount: 5,),

        SliverToBoxAdapter(
          child: Selector<HomeProvider, bool>(
            selector: (_, s) => s.isFlashDeal,
            builder: (context, s, child) {
              if (!s) return emptyWidget;
              return Column(
                children: [
                  InkWell(
                    onTap: () => GoRouter.of(context).go('/flash-deals'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(
                        'flash_deals_ucf'.tr(context: context),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const FlashDealBanner(),
                ],
              );
            },
          ),
        ),
        //Featured Products
        const FeaturedProductsListSliver(),
        //Home Banner Slider Two
        const SliverToBoxAdapter(child: HomeBannersThree()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18.0, 20, 20.0, 0.0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'all_products_ucf'.tr(context: context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        //Home All Product
        const HomeAllProductsSliver(),
      ],
    );
  }
}
