import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auction/auction_products_details.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/product_details.dart';
import 'package:flutter/material.dart';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../app_config.dart';

class ProductCardBlack extends StatefulWidget {
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
  final String? flatdiscount;

  const ProductCardBlack({
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
    this.flatdiscount,
  }) : super(key: key);

  @override
  _ProductCardBlackState createState() => _ProductCardBlackState();
}

class _ProductCardBlackState extends State<ProductCardBlack> {
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
        //decoration: BoxDecorations.buildBoxDecoration_1(),
        //decoration: BoxDecoration(color: Color(0xffF6F5FA)),
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity,
                    child: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusNormal),
                      child: FadeInImage.assetNetwork(
                        placeholder: AppImages.placeholder,
                        image: widget.image ?? AppImages.placeholder,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Container(
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
                                ? widget.stroked_price?.replaceAll(
                                        SystemConfig.systemCurrency!.code!,
                                        SystemConfig.systemCurrency!.symbol!) ??
                                    ''
                                : widget.stroked_price ?? '',
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
                              ? widget.main_price?.replaceAll(
                                      SystemConfig.systemCurrency!.code!,
                                      SystemConfig.systemCurrency!.symbol!) ??
                                  ''
                              : widget.main_price ?? '',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style:  TextStyle(
                            color: MyTheme.secondaryColor,
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
            Positioned(
            top: 0,
            right: 0, // ✅ تثبيت على اليمين
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.has_discount)
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          offset: Offset(-1, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      
                    child: Column(
                      children: [
                        Text(
                          'off'.tr(context: context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                          
                        ),
                        if (AppConfig.businessSettingsData.diplayDiscountType == 'flat' && widget.flatdiscount != null) 
                        Column(
                          children: [
                            Text(
                              "${widget.flatdiscount}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                            height: 1.1,
                                          ),
                                          
                                        ),
                                        Text(
                              "${SystemConfig.systemCurrency!.symbol}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                            height: 1.1,
                                          ),
                                          
                                        ),
                          ],
                        ),
            if (AppConfig.businessSettingsData.diplayDiscountType == 'percentage'|| widget.flatdiscount == null)
            Text(
              "${widget.discount}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ],
        ),
                    ),
        ),

      if (whole_sale_addon_installed.$ && (widget.isWholesale ?? false))
        Container(
          margin: const EdgeInsets.only(top: 6, right: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: const BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(AppDimensions.radiusHalfSmall),
              bottomLeft: Radius.circular(AppDimensions.radiusHalfSmall),
            ),
          ),
          child: Text(
            'wholesale'.tr(context: context),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
    ],
  ),
),

          ],
        ),
      ),
    );
  }
}
