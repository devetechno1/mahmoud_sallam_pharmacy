import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/wholesale_model.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auction/auction_products_details.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/product_details.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import '../app_config.dart';
import '../custom/paged_view/models/page_result.dart';
import '../custom/paged_view/paged_view.dart';

class WholesalesScreen extends StatelessWidget {
  const WholesalesScreen({super.key});

  Future<PageResult<Product>> _fetchWholesale(int page) async {
    try {
      final WholesaleProductModel res =
          await ProductRepository().getWholesaleProducts(page);
      if (res.result != true) {
        return const PageResult<Product>(data: [], hasMore: false);
      }
      final List<Product> list = res.products.data;
      final bool hasMore = list.isNotEmpty;
      return PageResult<Product>(data: list, hasMore: hasMore);
    } catch (_) {
      return const PageResult<Product>(data: [], hasMore: false);
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
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
        'wholesale_products_ucf'.tr(context: context),
        style: const TextStyle(
          fontSize: 16,
          color: MyTheme.dark_font_grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.mainColor,
      appBar: _buildAppBar(context),
      body: PagedView<Product>(
        fetchPage: _fetchWholesale,
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
          return WholeSalesProductCard(
            id: product.id,
            slug: product.slug,
            image: product.thumbnailImage,
            name: product.name,
            main_price: product.basePrice.toString(),
            stroked_price: product.baseDiscountedPrice.toString(),
            has_discount: product.discount != 0.0,
            discount: product.discount_percentage,
            isWholesale: true,
          );
        },
      ),
    );
  }
}

class WholeSalesProductCard extends StatefulWidget {
  final dynamic identifier;
  final int? id;
  final String slug;
  final String? image;
  final String? name;
  final String? main_price;
  final String? stroked_price;
  final bool has_discount;
  final bool? isWholesale;
  final String? discount;

  const WholeSalesProductCard({
    Key? key,
    this.identifier,
    required this.slug,
    this.id,
    this.image,
    this.name,
    this.main_price,
    this.stroked_price,
    this.has_discount = false,
    this.isWholesale = false,
    this.discount,
  }) : super(key: key);

  @override
  _WholeSalesProductCardState createState() => _WholeSalesProductCardState();
}

class _WholeSalesProductCardState extends State<WholeSalesProductCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return widget.identifier == 'auction'
                  ? AuctionProductsDetails(slug: widget.slug)
                  : ProductDetails(slug: widget.slug);
            },
          ),
        );
      },
      child: Container(
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(children: [
                    SizedBox(
                      width: double.infinity,
                      child: ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusNormal),
                        child: FadeInImage.assetNetwork(
                          placeholder: AppImages.placeholder,
                          image: widget.image ?? AppImages.placeholder,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (whole_sale_addon_installed.$ &&
                        widget.isWholesale == true &&
                        AppConfig.businessSettingsData.showWholesaleLabel)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: const BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  AppDimensions.radiusHalfSmall),
                              bottomLeft: Radius.circular(
                                  AppDimensions.radiusHalfSmall),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x14000000),
                                offset: Offset(-1, 1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            'wholesale'.tr(context: context),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.8,
                            ),
                            textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false),
                            softWrap: false,
                          ),
                        ),
                      ),
                  ]),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(
                          widget.name ?? 'no_name'.tr(context: context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      if (widget.has_discount)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            SystemConfig.systemCurrency != null
                                ? widget.main_price?.replaceAll(
                                        SystemConfig.systemCurrency!.code!,
                                        SystemConfig.systemCurrency!.symbol!) ??
                                    ''
                                : widget.main_price ?? '',
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: MyTheme.medium_grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 8.0),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          SystemConfig.systemCurrency != null
                              ? widget.stroked_price?.replaceAll(
                                      SystemConfig.systemCurrency!.code!,
                                      SystemConfig.systemCurrency!.symbol!) ??
                                  ''
                              : widget.stroked_price ?? '',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.has_discount)
                      Container(
                        height: 20,
                        width: 48,
                        margin: const EdgeInsets.only(
                            top: AppDimensions.paddingSmall,
                            right: AppDimensions.paddingSmall,
                            bottom: 15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusNormal),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              offset: Offset(-1, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.discount ?? '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.8,
                            ),
                            textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false),
                            softWrap: false,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
