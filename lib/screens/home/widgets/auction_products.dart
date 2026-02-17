import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:active_ecommerce_cms_demo_app/screens/home/widgets/featured_products/custom_horizontal_products_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:provider/provider.dart';

import '../../../data_model/product_mini_response.dart';

class AuctionProductsSectionSliver extends StatelessWidget {
  const AuctionProductsSectionSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(10.0, 20, 20.0, 0.0),
                child: SizedBox(
                  width: double.infinity,
                ),
              ),
              Selector<
                      HomeProvider,
                      ({
                        bool isAuctionProductInitial,
                        UnmodifiableListView<Product> auctionProductList,
                        int? totalAuctionProductData,
                      })>(
                  selector: (context, provider) => (
                        isAuctionProductInitial:
                            provider.isauctionProductInitial,
                        auctionProductList: UnmodifiableListView(provider.auctionProductList),
                        totalAuctionProductData:
                            provider.totalauctionProductData,
                      ),
                  builder: (context, provider, child) {
                    return CustomHorizontalProductsListSectionWidget(
                      title: 'auction_product_ucf'.tr(context: context),
                      isProductInitial: provider.isAuctionProductInitial,
                      productList: provider.auctionProductList,
                      numberOfTotalProducts:
                          provider.totalAuctionProductData ?? 0,
                      onArriveTheEndOfList:
                          context.read<HomeProvider>().fetchAuctionProducts,
                    );
                  }),
            ],
          ),
        ),
      ]),
    );
  }
}
