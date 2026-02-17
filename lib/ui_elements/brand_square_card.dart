import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/screens/brand_products.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';

import '../app_config.dart';

class BrandSquareCard extends StatefulWidget {
  final int? id;
  final String slug;
  final String? image;
  final String? name;

  const BrandSquareCard(
      {Key? key, this.id, this.image, required this.slug, this.name})
      : super(key: key);

  @override
  _BrandSquareCardState createState() => _BrandSquareCardState();
}

class _BrandSquareCardState extends State<BrandSquareCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return BrandProducts(slug: widget.slug);
        }));
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecorations.buildBoxDecoration_1(
            radius: AppDimensions.radiusDefault),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: FadeInImage.assetNetwork(
                    placeholder: AppImages.placeholder,
                    image: widget.image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (AppConfig.businessSettingsData.showBrandName == true)
              SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    widget.name!,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
