import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/screens/filter.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/get_brands_widget.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:provider/provider.dart';

import '../../../data_model/brand_response.dart';
import '../../../presenter/home_provider.dart';

class BrandListSectionSliver extends StatelessWidget {
  final bool showViewAllButton;

  const BrandListSectionSliver({super.key, this.showViewAllButton = true});

  @override
  Widget build(BuildContext context) {
    final p = context.select<
            HomeProvider, ({bool isBrandsInitial, UnmodifiableListView<Brands> brandsList})>(
        (p) => (
              brandsList: UnmodifiableListView(p.brandsList),
              isBrandsInitial: p.isBrandsInitial,
            ));

    if (p.isBrandsInitial || p.brandsList.isNotEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsetsDirectional.only(
                top: AppDimensions.paddingLarge,
                start: AppDimensions.paddingLarge,
                bottom: AppDimensions.paddingSupSmall),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const Filter(selected_filter: "brands");
                }));
              },
              child: Text(
                'top_brands_ucf'.tr(context: context),
                style: const TextStyle(
                  color: Color(0xff000000),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          CustomBrandListWidget(
            showViewAllButton: showViewAllButton,
            brands: p.brandsList,
          ),
        ]),
      );
    }

    return const SliverToBoxAdapter(child: emptyWidget);
  }
}
