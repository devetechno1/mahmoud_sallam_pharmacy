import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/featured_category/feature_categories_widget_horizontal.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:provider/provider.dart';

import '../../../../data_model/category_response.dart';
import '../../../../presenter/home_provider.dart';

class CategoryListHorizontal extends StatelessWidget {
  const CategoryListHorizontal({super.key});

  @override
  Widget build(BuildContext context) {
    final ({UnmodifiableListView<Category> featuredCategoryList, bool isCategoryInitial}) p =
        context.select<HomeProvider,
            ({bool isCategoryInitial, UnmodifiableListView<Category> featuredCategoryList})>(
      (provider) => (
        featuredCategoryList: UnmodifiableListView(provider.featuredCategoryList),
        isCategoryInitial: provider.isCategoryInitial,
      ),
    );
    if (!p.isCategoryInitial && p.featuredCategoryList.isEmpty) {
      return const SliverToBoxAdapter(child: emptyWidget);
    }
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  top: 10, start: 20, bottom: 1),
              child: Text(
                'featured_categories_ucf'.tr(context: context),
                style: const TextStyle(
                  color: Color(0xff000000),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Expanded(child: FeaturedCategoriesWidget(
            )),
          ],
        ),
      ),
    );
  }
}
