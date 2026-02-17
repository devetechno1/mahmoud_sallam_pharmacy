import 'package:active_ecommerce_cms_demo_app/custom/home_all_products_2.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

const List<Widget> allProductsSliver = [
  _AllProductsTitle(),
  HomeAllProductsSliver(),
];

class _AllProductsTitle extends StatelessWidget {
  const _AllProductsTitle();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsetsDirectional.fromSTEB(18.0, 20, 20.0, 0.0),
      sliver: SliverToBoxAdapter(
        child: Text(
          'all_products_ucf'.tr(context: context),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
