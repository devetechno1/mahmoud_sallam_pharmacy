// import statements
import 'package:active_ecommerce_cms_demo_app/custom/home_banners/home_banners_three.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/all_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/auction_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/best_selling_section_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/brand_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/today_deal.dart';
import 'package:flutter/material.dart';
import '../../../custom/featured_category/enum_feature_category.dart';
import '../../../custom/home_banners/home_banners_one.dart';
import '../../../custom/home_banners/home_banners_two.dart';
import '../widgets/carousel_and_flash_sale_sliver.dart';
import '../widgets/featured_products_list_sliver.dart';
import '../widgets/global_home_screen_widget.dart';

class MegamartScreen extends StatelessWidget {
  const MegamartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GlobalHomeScreenWidget(
      slivers: <Widget>[
        //Featured category-----------------------
         buildFeaturedCategory(context),

        const CarouselAndFlashSaleSliver(),
        //move banner
        const TodaysDealProductsSliverWidget(),

        //BannerList---------------------
        const SliverToBoxAdapter(child: HomeBannersOne()),

        //featuredProducts-----------------------------
        const FeaturedProductsListSliver(),

        //BannerList---------------------
        const SliverToBoxAdapter(child: HomeBannersTwo()),

        //Best Selling-------------------
        // if(homeData.isFeaturedProductInitial || homeData.featuredProductList.isNotEmpty)
        const BestSellingSectionSliver(),
        //newProducts-----------------------------
        // NewProductsListSliver(),

        const SliverToBoxAdapter(child: HomeBannersThree()),

        //Brand List ---------------------------
        const BrandListSectionSliver(showViewAllButton: false),
        //auctionProducts------------
        const AuctionProductsSectionSliver(),
        //all products --------------------------
        ...allProductsSliver,

        ///
      ],
    );
  }
}
