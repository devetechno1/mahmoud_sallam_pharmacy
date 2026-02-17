import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app_config.dart';
import '../../../custom/home_banners/home_banners_list.dart' show HomeBannersList;
import '../../../data_model/product_mini_response.dart';
import '../../../data_model/slider_response.dart';
import '../../../locale/custom_localization.dart';
import '../../../my_theme.dart';
import '../../product/product_details.dart';
import 'today_deal_all.dart';

class TodaysDealProductsSliverWidget extends StatelessWidget {
  const TodaysDealProductsSliverWidget({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final todayDealData = context.select<HomeProvider,
        ({
          bool z,
          UnmodifiableListView<Product> products,
          bool isBannerInitial,
          UnmodifiableListView<AIZSlider> bannerImages
        })>(
      (value) => (
        products: UnmodifiableListView(value.TodayDealList),
        z: value.isTodayDealInitial,
        isBannerInitial: value.isTodayDealBannerInitial,
        bannerImages: UnmodifiableListView(value.todayDealBannerImageList),
      ),
    );
    final todayDealList = todayDealData.products;
    if (todayDealList.isEmpty) {
      return const SliverToBoxAdapter(child: emptyWidget);
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: HomeBannersList(
              isBannersInitial: todayDealData.isBannerInitial,
              bannersImagesList: todayDealData.bannerImages,
            ),
          ),
        ),
        if (title?.trim().isNotEmpty == true)
          SliverPadding(
            padding: const EdgeInsetsDirectional.only(
              start: AppDimensions.paddingLarge,
              end: AppDimensions.paddingLarge,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TodaysDealViewAllScreen(
                            ),
                          ),
                        );
                        
                      },
                      child: Text(    
                        "view_all_ucf".tr(context: context),
                        style:  TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                   ),
                  ),
                    ),
                ],
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 270,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              itemCount: todayDealList.length,
              itemBuilder: (context, index) {
                final product = todayDealList[index];

                return GestureDetector(
                  onTap: product.slug == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetails(slug: product.slug!),
                            ),
                          );
                        },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsetsDirectional.only(
                      end: AppDimensions.paddingDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSmall),
                            child: Image.network(
                              product.thumbnail_image ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.name ?? '',
                          maxLines: 2,
                          textDirection: (product.name ?? '').direction,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.main_price ?? '',
                          style:  TextStyle(color: MyTheme.secondaryColor,
                            fontWeight: FontWeight.w700,),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
