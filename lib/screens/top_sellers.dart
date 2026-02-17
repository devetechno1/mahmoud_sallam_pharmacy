import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';

import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/shop_repository.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/shop_square_card.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../data_model/shop_response.dart';
import '../helpers/grid_responsive.dart';

class TopSellers extends StatefulWidget {
  const TopSellers({super.key});

  @override
  State<TopSellers> createState() => _TopSellersState();
}

class _TopSellersState extends State<TopSellers> {
  ScrollController? _scrollController;
  List<Shop> topSellers = [];
  bool isInit = false;

  getTopSellers() async {
    final ShopResponse response = await ShopRepository().topSellers();
    isInit = true;
    if (response.shops != null) {
      topSellers.addAll(response.shops!);
    }

    setState(() {});
  }

  clearAll() {
    isInit = false;
    topSellers.clear();
    setState(() {});
  }

  Future<void> onRefresh() async {
    clearAll();

    return await getTopSellers();
  }

  @override
  void initState() {
    // TODO: implement initState
    getTopSellers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.mainColor,
      appBar: buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: buildTopSellerList(context)),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      // centerTitle: true,
      leading: UsefulElements.backButton(),
      title: Text(
        'top_sellers_ucf'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      scrolledUnderElevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget buildTopSellerList(context) {
    final int cross = GridResponsive.columnsForWidth(context);
    final double ratio = GridResponsive.aspectRatioForWidth(context);
    if (isInit) {
      //print(productResponse.toString());
      return GridView.builder(
        // 2
        //addAutomaticKeepAlives: true,
        itemCount: topSellers.length,
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: ratio),
        padding: const EdgeInsets.only(
            top: AppDimensions.paddingLarge,
            bottom: AppDimensions.paddingSupSmall,
            left: 18,
            right: 18),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // 3
          return ShopSquareCard(
            id: topSellers[index].id,
            shopSlug: topSellers[index].slug ?? "",
            image: topSellers[index].logo,
            name: topSellers[index].name,
            stars: double.parse(topSellers[index].rating.toString()),
          );
        },
      );
    } else {
      return ShimmerHelper().buildSquareGridShimmer(
          crossAxisCount: cross,
          childAspectRatio: ratio,
          scontroller: _scrollController);
    }
  }
}
