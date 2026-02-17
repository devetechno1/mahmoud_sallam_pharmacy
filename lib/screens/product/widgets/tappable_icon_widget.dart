import 'package:flutter/material.dart';

import '../../../custom/box_decorations.dart';

class TappableIconWidget extends StatelessWidget {
  final dynamic icon;
  final dynamic color;

  const TappableIconWidget({
    super.key,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecorations.buildCircularButtonDecoration_for_productDetails(),
      width: 32,
      height: 32,
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }
}
