// import statements
import 'package:active_ecommerce_cms_demo_app/custom/home_banners/home_banners_three.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/all_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/auction_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/best_selling_section_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/brand_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/featured_category/featured_category_horizontal.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/today_deal.dart';
import 'package:flutter/material.dart';
import '../../../custom/home_banners/home_banners_one.dart';
import '../../../custom/home_banners/home_banners_two.dart';
import '../../../custom/home_carousel_slider.dart';
import '../../../custom/pirated_widget.dart';
import '../widgets/featured_products_list_sliver.dart';
import '../widgets/flash_deal_home_widget.dart';
import '../widgets/global_home_screen_widget.dart';
import '../widgets/new_products_list_sliver.dart';

class MinimaScreen extends StatelessWidget {
  const MinimaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GlobalHomeScreenWidget(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate([
            const PiratedWidget(),
            const SizedBox(height: 10),

            // Header Banner
            const HomeCarouselSlider(),
            const SizedBox(height: 16),

            // Flash Sale Section
            const FlashDealHomeWidget(),
          ]),
        ),
        const TodaysDealProductsSliverWidget(),

        //new products-----------------------------
        const NewProductsListSliver(),
        //feature_categories//

        const CategoryListHorizontal(),
        const SliverToBoxAdapter(child: HomeBannersOne()),
        const FeaturedProductsListSliver(),
        const SliverToBoxAdapter(child: HomeBannersTwo()),

        //Best Selling
        const BestSellingSectionSliver(),
        const NewProductsListSliver(),
        const SliverToBoxAdapter(child: HomeBannersThree()),

        //auction products
        const AuctionProductsSectionSliver(),

        const BrandListSectionSliver(),
        //all products ------------
        ...allProductsSliver,

        ///
      ],
    );
  }
}