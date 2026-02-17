import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/all_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/auction_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/best_selling_section_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/brand_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/featured_category/featured_category_horizontal.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/new_products_list_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/today_deal.dart';
import 'package:flutter/material.dart';
import '../../../custom/home_banners/home_banners_one.dart';
import '../../../custom/home_banners/home_banners_three.dart';
import '../../../custom/home_banners/home_banners_two.dart';
import '../widgets/featured_products_list_sliver.dart';
import '../widgets/carousel_and_flash_sale_sliver.dart';
import '../widgets/global_home_screen_widget.dart';

class ClassicScreen extends StatelessWidget {
  const ClassicScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GlobalHomeScreenWidget(
      slivers: <Widget>[
        CarouselAndFlashSaleSliver(
          isFlashSaleCircle: true,
          flashSaleBackgroundColor: Colors.white,
          flashSaleDefaultTextColor: Theme.of(context).primaryColor,
        ),

        const TodaysDealProductsSliverWidget(),

        //Featured category-----------------------
        const CategoryListHorizontal(),

        //BannerList---------------------

        const SliverToBoxAdapter(child: HomeBannersOne()),
        //  SliverToBoxAdapter(
        //   child: HomeBannersListCircle(
        //     bannersImagesList: homeData.bannerOneImageList,
        //     isBannersInitial: homeData.isBannerOneInitial,
        //   ),
        // ),
        //featuredProducts-----------------------------
        const FeaturedProductsListSliver(),
        //BannerList---------------------
        const SliverToBoxAdapter(child: HomeBannersTwo()),

        //Best Selling-------------------
        // if(homeData.isFeaturedProductInitial || homeData.featuredProductList.isNotEmpty)
        const BestSellingSectionSliver(),
        //newProducts-----------------------------
        const NewProductsListSliver(),
        //BannerList---------------------
        const SliverToBoxAdapter(child: HomeBannersThree()),

        //auction products----------------------------
        const AuctionProductsSectionSliver(),
        //Brand List ---------------------------
        const BrandListSectionSliver(),
        //all products --------------------------
        ...allProductsSliver,
      ],
    );
  }
}