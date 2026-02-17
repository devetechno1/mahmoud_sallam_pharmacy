import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/all_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/auction_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/best_selling_section_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/brand_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/featured_category/featured_category_horizontal.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/flash_sale.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/new_products_list_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/today_deal.dart';
import 'package:flutter/material.dart';
import '../../../custom/home_banners/home_banners_one.dart';
import '../../../custom/home_banners/home_banners_three.dart';
import '../../../custom/home_banners/home_banners_two.dart';
import '../../../custom/home_carousel_slider.dart';
import '../../../custom/pirated_widget.dart';
import '../widgets/featured_products_list_sliver.dart';

import '../widgets/global_home_screen_widget.dart';

class ReClassicScreen extends StatelessWidget {
  const ReClassicScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GlobalHomeScreenWidget(
      slivers: <Widget>[
        const SliverToBoxAdapter(child: HomeCarouselSlider()),
        const CategoryListHorizontal(),

        TodaysDealProductsSliverWidget(
          title: 'todays_deal_ucf'.tr(context: context),
        ),

        //BannerList---------------------
        const SliverToBoxAdapter(child: HomeBannersOne()),

        SliverList(
          delegate: SliverChildListDelegate([
            const PiratedWidget(),
            const SizedBox(height: 10),
            //featured

            // Header Banner

            const SizedBox(height: 16),

            // Flash Sale Section
            FlashSale(
              isCircle: false,
              defaultTextColor: Theme.of(context).primaryColor,
            )
          ]),
        ),
        //featuredProducts-----------------------------
        const FeaturedProductsListSliver(),

        //BannerList---------------------
        const SliverToBoxAdapter(child: HomeBannersTwo()),

        //Best Selling-------------------
        const BestSellingSectionSliver(),
        //newProducts-----------------------------
        const NewProductsListSliver(),
        //BannerList---------------------
        const SliverToBoxAdapter(child: HomeBannersThree()),
        //auctionProducts------------
        const AuctionProductsSectionSliver(),

        //Brand List ---------------------------

        const BrandListSectionSliver(),

        //all products --------------------------
        ...allProductsSliver,

        ///
      ],
    );
  }
}
