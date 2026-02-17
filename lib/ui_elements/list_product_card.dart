import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/screens/product/product_details.dart';
import 'package:flutter/material.dart';

import '../app_config.dart';

class ListProductCard extends StatefulWidget {
  final int? id;
  final String slug;
  final String? image;
  final String? name;
  final String? mainPrice;
  final String? strokedPrice;
  final bool? hasDiscount;

  const ListProductCard(
      {Key? key,
      this.id,
      required this.slug,
      this.image,
      this.name,
      this.mainPrice,
      this.strokedPrice,
      this.hasDiscount})
      : super(key: key);

  @override
  _ListProductCardState createState() => _ListProductCardState();
}

class _ListProductCardState extends State<ListProductCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetails(
            slug: widget.slug,
          );
        }));
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1(),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Container(
              width: 100,
              height: 100,
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
                  top: AppDimensions.paddingSupSmall,
                  left: 12,
                  right: 12,
                  bottom: 14),
              //width: 240,
              height: 100,
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
                          color: MyTheme.font_grey,
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Container(
                    //color:Colors.green,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text(
                          SystemConfig.systemCurrency!.code != null
                              ? widget.mainPrice!.replaceAll(
                                  SystemConfig.systemCurrency!.code!,
                                  SystemConfig.systemCurrency!.symbol!)
                              : widget.mainPrice!,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        widget.hasDiscount!
                            ? Text(
                                SystemConfig.systemCurrency!.code != null
                                    ? widget.strokedPrice!.replaceAll(
                                        SystemConfig.systemCurrency!.code!,
                                        SystemConfig.systemCurrency!.symbol!)
                                    : widget.strokedPrice!,
                                textAlign: TextAlign.left,
                                maxLines: 1,
                                style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: MyTheme.medium_grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
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
