import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/custom_horizontal_brands_list.dart';
import 'package:flutter/material.dart';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:provider/provider.dart';
import '../../../data_model/brand_response.dart';
import '../../../presenter/home_provider.dart';

class GetBrandsListSliver extends StatelessWidget {
  const GetBrandsListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<
          HomeProvider,
          ({
            bool isBrandsInitial,
            UnmodifiableListView<Brands> brandsList,
            int totalAllBrandsData
          })>(
        selector: (_, provider) => (
          isBrandsInitial: provider.isBrandsInitial,
          brandsList: UnmodifiableListView(provider.brandsList),
          totalAllBrandsData: provider.totalAllBrandsData,
        ),
        builder: (context, s, child) {
          // if (!homeData.isFeaturedProductInitial && homeData.featuredProductList.isEmpty) return emptyWidget;
          return CustomHorizontalBrandsListSectionWidget(
            title: 'top_brands_ucf'.tr(context: context),
            isBrandsInitial: s.isBrandsInitial,
            brandsList: s.brandsList,
            numberOfTotalBrands: s.totalAllBrandsData,
            onArriveTheEndOfList:
                context.read<HomeProvider>().fetchBrandsProducts,
          );
        },
      ),
    );
  }
}
