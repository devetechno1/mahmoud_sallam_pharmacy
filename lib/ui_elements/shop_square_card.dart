import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/screens/seller_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

class ShopSquareCard extends StatefulWidget {
  final int? id;
  final String? image;
  final String shopSlug;
  final String? name;
  final double? stars;
  final String? flatdiscount;

  const ShopSquareCard({
    Key? key,
    this.id,
    this.image,
    this.name,
    this.stars,
    required this.shopSlug,
    this.flatdiscount,
  }) : super(key: key);

  @override
  _ShopSquareCardState createState() => _ShopSquareCardState();
}

class _ShopSquareCardState extends State<ShopSquareCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerDetails(slug: widget.shopSlug),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Container(
                height: 165,
                width: 170,
                alignment: Alignment.topCenter,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
                ),
                child: _buildImage(),
              ),
            ),
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 5),
                _buildName(),
                const SizedBox(height: 5),
                _buildRating(),
                const SizedBox(height: 8),
                _buildVisitStoreButton(),
                const SizedBox(height: 2)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return FadeInImage.assetNetwork(
      placeholder: AppImages.placeholder,
      image: widget.image ?? AppImages.placeholder,
      fit: BoxFit.cover,
    );
  }

  Widget _buildName() {
    return Text(
      widget.name ?? 'no_name'.tr(context: context),
      textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: const TextStyle(
        color: MyTheme.dark_font_grey,
        fontSize: 13,
        height: 1.6,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRating() {
    return Container(
      height: 15,
      child: RatingBar(
        ignoreGestures: true,
        initialRating: widget.stars ?? 0.0,
        maxRating: 5,
        direction: Axis.horizontal,
        itemSize: 15.0,
        itemCount: 5,
        ratingWidget: RatingWidget(
          full: const Icon(Icons.star, color: Colors.amber),
          half: const Icon(Icons.star_half),
          empty:
              const Icon(Icons.star, color: Color.fromRGBO(224, 224, 225, 1)),
        ),
        onRatingUpdate: (newValue) {},
      ),
    );
  }

  Widget _buildVisitStoreButton() {
    return Container(
      height: 23,
      width: 103,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber),
        color: MyTheme.amber,
        borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
      ),
      child: Text(
        'visit_store_ucf'.tr(context: context),
        style: TextStyle(
          fontSize: 10,
          color: Colors.amber.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
