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
import '../widgets/carousel_and_flash_sale_sliver.dart';
import '../widgets/featured_products_list_sliver.dart';
import '../widgets/global_home_screen_widget.dart';
import '../widgets/new_products_list_sliver.dart';

class MegamartScreen extends StatelessWidget {
  const MegamartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const GlobalHomeScreenWidget(
      slivers: <Widget>[
        //Featured category-----------------------
        CategoryListHorizontal(),

        CarouselAndFlashSaleSliver(),
        //move banner
        TodaysDealProductsSliverWidget(),

        //BannerList---------------------
        SliverToBoxAdapter(child: HomeBannersOne()),

        //featuredProducts-----------------------------
        FeaturedProductsListSliver(),

        //BannerList---------------------
        SliverToBoxAdapter(child: HomeBannersTwo()),

        //Best Selling-------------------
        // if(homeData.isFeaturedProductInitial || homeData.featuredProductList.isNotEmpty)
        BestSellingSectionSliver(),
        //newProducts-----------------------------
        NewProductsListSliver(),

        SliverToBoxAdapter(child: HomeBannersThree()),

        //Brand List ---------------------------
        BrandListSectionSliver(showViewAllButton: false),
        //auctionProducts------------
        AuctionProductsSectionSliver(),
        //all products --------------------------
        ...allProductsSliver,

        ///
      ],
    );
  }
}
