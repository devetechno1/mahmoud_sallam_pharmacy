// import statements
import 'package:active_ecommerce_cms_demo_app/custom/home_banners/home_banners_three.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/all_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/auction_products.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/best_selling_section_sliver.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/brand_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/today_deal.dart';
import 'package:flutter/material.dart';
import '../../../custom/featured_category/enum_feature_category.dart';
import '../../../custom/home_banners/home_banner_five.dart';
import '../../../custom/home_banners/home_banners_four.dart';
import '../../../custom/home_banners/home_banners_one.dart';
import '../../../custom/home_banners/home_banners_two.dart';
import '../../../locale/custom_localization.dart';
import '../widgets/carousel_and_flash_sale_sliver.dart';
import '../widgets/discount_product_section.dart';
import '../widgets/featured_products_list_sliver.dart';
import '../widgets/global_home_screen_widget.dart';

class MetroScreen extends StatelessWidget {
  const MetroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalHomeScreenWidget(
      slivers: <Widget>[
        const CarouselAndFlashSaleSliver(isFlashSaleCircle: true),
        // Featured category (FIX)
        buildFeaturedCategory(context),

        const SliverToBoxAdapter(child: HomeBannersOne()),
        const DiscountProductSectionSliver(),
        const SliverToBoxAdapter(child: HomeBannersTwo()),
        const BestSellingSectionSliver(),
        TodaysDealProductsSliverWidget(
          title: 'todays_deal_ucf'.tr(context: context),
        ),
        const SliverToBoxAdapter(child: HomeBannersThree()),
        const BrandListSectionSliver(),
        const SliverToBoxAdapter(child: HomeBannersFour()),
        const FeaturedProductsListSliver(),
        const AuctionProductsSectionSliver(),
        const SliverToBoxAdapter(child: HomeBannersFive()),

        ...allProductsSliver,
      ],
    );
  }

}
