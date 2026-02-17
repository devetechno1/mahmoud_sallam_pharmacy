import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/screens/brand_products.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:go_router/go_router.dart';

import '../../../data_model/brand_response.dart';
import '../../../helpers/grid_responsive.dart';

class CustomBrandListWidget extends StatefulWidget {
  final bool showViewAllButton;
  final List<Brands> brands;

  const CustomBrandListWidget({
    super.key,
    required this.showViewAllButton,
    required this.brands,
  });

  @override
  State<CustomBrandListWidget> createState() => _CustomBrandListWidgetState();
}

class _CustomBrandListWidgetState extends State<CustomBrandListWidget> {
  
  @override
  Widget build(BuildContext context) {
    if (widget.brands.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final bool showViewAll =
        widget.showViewAllButton && widget.brands.length > 8;
    final cross = GridResponsive.columnsForWidth(
      context,
      minTileWidth: 50,
      maxXs: 4,
      maxSm: 6,
      maxMd: 8,
      maxLg: 8,
    );

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: showViewAll ? 8 : widget.brands.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing:   10,
            crossAxisSpacing: 15,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final Brands brand = widget.brands[index];

            if (showViewAll && index == 7) {
              return GestureDetector(
                onTap: () {
                  context.pushNamed('Brands');
                },
                child: Column(
                  children: [
                    ClipOval(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSmall),
                            child: Image.network(
                              brand.logo ?? '',
                              height: 60,
                              width: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image),
                            ),
                          ),
                          Positioned.fill(
                            child: ColoredBox(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.8),
                              child: const Icon(Icons.more_horiz_outlined,
                                  color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'view_all_ucf'.tr(context: context),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BrandProducts(slug: brand.slug ?? '');
                }));
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSmall),
                    child: Image.network(
                      brand.logo ?? '',
                      height: 60,
                      width: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(height: 6),
                if (AppConfig.businessSettingsData.showBrandName == true)
                              SizedBox(
                                child: Text(
                                  brand.name ?? '',
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                             ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
