import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/product_details.dart';
import 'package:flutter/material.dart';

import '../app_config.dart';

// ignore: must_be_immutable
class TopSellingProductsCard extends StatefulWidget {
  int? id;
  String slug;
  String? image;
  String? name;
  String? main_price;
  String? stroked_price;
  bool? has_discount;
  String? flatdiscount;

  TopSellingProductsCard(
      {Key? key,
      this.id,
      required this.slug,
      this.image,
      this.name,
      this.main_price,
      this.stroked_price,
      this.has_discount,
      this.flatdiscount})
      : super(key: key);

  @override
  _TopSellingProductsCardState createState() => _TopSellingProductsCardState();
}

class _TopSellingProductsCardState extends State<TopSellingProductsCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetails(
            slug: widget.slug,
          );
        }));
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 0))
            ]),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Container(
              width: 90,
              height: 90,
              child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppDimensions.radiusHalfSmall),
                      right: Radius.zero),
                  child: FadeInImage.assetNetwork(
                    placeholder: AppImages.placeholder,
                    image: widget.image!,
                    fit: BoxFit.cover,
                  ))),
          Flexible(
            child: Container(
              padding: const EdgeInsets.only(
                  top: 14, left: 14, right: 34, bottom: 10),
              //width: 240,
              height: 90,
              //color: Colors.red,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    //color:Colors.blue,
                    child: Text(
                      widget.name!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                          color: Color(0xff6B7377),
                          fontFamily: 'Public Sans',
                          fontSize: 12,
                          height: 1.6,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Container(
                    //color: Colors.green,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text(
                          SystemConfig.systemCurrency!.code != null
                              ? widget.main_price!.replaceAll(
                                  SystemConfig.systemCurrency!.code!,
                                  SystemConfig.systemCurrency!.symbol!)
                              : widget.main_price!,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 18,
                        ),
                        widget.has_discount!
                            ? Text(
                                SystemConfig.systemCurrency!.code != null
                                    ? widget.stroked_price!.replaceAll(
                                        SystemConfig.systemCurrency!.code!,
                                        SystemConfig.systemCurrency!.symbol!)
                                    : widget.stroked_price!,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontFamily: 'Public Sans',
                                    color: Color(0xffA8AFB3),
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal),
                              )
                            : emptyWidget,
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
