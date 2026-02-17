import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/product_details.dart';
import 'package:flutter/material.dart';

import '../helpers/shared_value_helper.dart';
import '../locale/custom_localization.dart';

class MiniProductCard extends StatefulWidget {
  final int? id;
  final String slug;
  final String? image;
  final String? name;
  final String? main_price;
  final String? stroked_price;
  final bool? has_discount;
  final bool? isWholesale;
  final TextStyle? priceTextStyle;
  final TextStyle? nameTextStyle;
  final int? rating;
  final String? discount;
  final String? flatdiscount;

  const MiniProductCard({
    Key? key,
    this.id,
    required this.slug,
    this.image,
    this.name,
    this.main_price,
    this.stroked_price,
    this.has_discount,
    this.isWholesale = false,
    this.priceTextStyle,
    this.nameTextStyle,
    this.rating,
    this.discount,
    this.flatdiscount,
  }) : super(key: key);

  @override
  _MiniProductCardState createState() => _MiniProductCardState();
}

class _MiniProductCardState extends State<MiniProductCard> {
  @override
  Widget build(BuildContext context) {
    final TextStyle resolvedNameStyle = widget.nameTextStyle ??
        const TextStyle(
          color: MyTheme.font_grey_Light,
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w400,
        );
    final double nameBoxHeight =
        (resolvedNameStyle.fontSize ?? 12) * (resolvedNameStyle.height ?? 1) * 2 + 2;

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetails(slug: widget.slug);
        }));
      },
      child: SizedBox(
        width: 140,
        height: 275,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
                      child: FadeInImage.assetNetwork(
                        placeholder: AppImages.placeholder,
                        image: widget.image ?? AppImages.placeholder,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (widget.has_discount == true)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
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
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
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
                                if (AppConfig.businessSettingsData.diplayDiscountType == 'flat' &&
                                    widget.flatdiscount != null)
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
                                if (AppConfig.businessSettingsData.diplayDiscountType == 'percentage' ||
                                    widget.flatdiscount == null)
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
                      ),
                    ),

                  if (whole_sale_addon_installed.$ && (widget.isWholesale ?? false))
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(AppDimensions.radiusHalfSmall),
                            bottomLeft: Radius.circular(AppDimensions.radiusHalfSmall),
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
                            applyHeightToFirstAscent: false,
                          ),
                          softWrap: false,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: SizedBox(
                height: nameBoxHeight,
                width: double.maxFinite,
                child: Text(
                  widget.name ?? '',
                  overflow: TextOverflow.ellipsis,
                  textDirection: (widget.name ?? '').direction,
                  maxLines: 3, // زي ما طلبتي: يفضل واخد سطرين
                  style: resolvedNameStyle,
                ),
              ),
            ),

            if (widget.has_discount == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  SystemConfig.systemCurrency != null
                      ? widget.stroked_price?.replaceAll(
                            SystemConfig.systemCurrency!.code!,
                            SystemConfig.systemCurrency!.symbol!,
                          ) ??
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
              ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Text(
                SystemConfig.systemCurrency != null
                    ? (widget.main_price ?? '').replaceAll(
                        SystemConfig.systemCurrency!.code!,
                        SystemConfig.systemCurrency!.symbol!,
                      )
                    : widget.main_price ?? '',
                maxLines: 1,
                style: widget.priceTextStyle ??
                     TextStyle(
                      color: MyTheme.secondaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
