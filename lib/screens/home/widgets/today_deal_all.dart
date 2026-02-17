import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_config.dart';
import '../../../custom/home_banners/home_banners_list.dart';
import '../../../custom/paged_view/models/page_result.dart';
import '../../../custom/paged_view/paged_view.dart';
import '../../../data_model/product_mini_response.dart';
import '../../../data_model/slider_response.dart';
import '../../../helpers/shared_value_helper.dart';
import '../../../helpers/shimmer_helper.dart';
import '../../../locale/custom_localization.dart';
import '../../../my_theme.dart';
import '../../../repositories/product_repository.dart';
import '../../../ui_elements/product_card.dart';

class TodaysDealViewAllScreen extends StatelessWidget {
  const TodaysDealViewAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.select<
        HomeProvider,
        ({
          bool isInitial,
          UnmodifiableListView<Product> products,
          bool isBannerInitial,
          UnmodifiableListView<AIZSlider> bannerImages,
        })>(
      (p) => (
        isInitial: p.isTodayDealInitial,
        products: UnmodifiableListView(p.TodayDealList),
        isBannerInitial: p.isTodayDealBannerInitial,
        bannerImages: UnmodifiableListView(p.todayDealBannerImageList),
      ),
    );
    Future<PageResult<Product>> _fetchProducts(int page) async {
      final res = await ProductRepository()
          .getTodaysDealProducts(page: page, paginate: "");
      final list = res.products ?? [];
      final hasMore = list.isNotEmpty;
      return PageResult<Product>(data: list, hasMore: hasMore);
    }

    return Scaffold(
      backgroundColor: MyTheme.mainColor,
      // appBar: buildAppBar(context),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: HomeBannersList(
                isBannersInitial: data.isBannerInitial,
                bannersImagesList: data.bannerImages,
              ),
            ),
          ),
        ],
        body: PagedView<Product>(
          fetchPage: _fetchProducts,
          usePrimaryScrollController: true,
          layout: PagedLayout.masonry,
          gridCrossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          padding: const EdgeInsets.only(
            top: AppDimensions.paddingLarge,
            bottom: AppDimensions.paddingSupSmall,
            left: 18,
            right: 18,
          ),
          itemBuilder: (context, product, index) {
            return ProductCard(
              id: product.id,
              slug: product.slug!,
              image: product.thumbnail_image,
              name: product.name,
              main_price: product.main_price,
              stroked_price: product.stroked_price,
              has_discount: product.has_discount ?? false,
              discount: product.discount,
              isWholesale: product.isWholesale,
              flatdiscount: product.flatdiscount,
            );
          },
          loadingItemBuilder: (_, index) {
            return ShimmerHelper.loadingItemBuilder(index);
          },
        ),
      ),
    );
  }

  SliverAppBar buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: MyTheme.mainColor, scrolledUnderElevation: 0.0,
      // centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
              app_language_rtl.$!
                  ? CupertinoIcons.arrow_right
                  : CupertinoIcons.arrow_left,
              color: MyTheme.dark_grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'todays_deal_ucf'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      floating: false,
      pinned: true,
      snap: false,
    );
  }
}
