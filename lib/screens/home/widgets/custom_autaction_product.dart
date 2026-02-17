import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auction/auction_products_details.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/product_mini_response.dart'
    as productMini;

class CustomAuctionProductsListWidget extends StatelessWidget {
  final List<productMini.Product>? products;

  const CustomAuctionProductsListWidget({super.key, this.products});

  @override
  Widget build(BuildContext context) {
    if (products == null || products!.isEmpty) {
      return Center(
        child: Text(
          'no_auction_products_available'.tr(context: context),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products!.length,
      itemBuilder: (context, index) {
        final product = products![index];

        return GestureDetector(
          onTap: product.slug == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AuctionProductsDetails(slug: product.slug!),
                    ),
                  );
                },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                child: Image.network(
                  product.thumbnail_image ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(product.name ?? 'No name'),
              subtitle: Text(product.main_price ?? 'N/A'),
            ),
          ),
        );
      },
    );
  }
}
