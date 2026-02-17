import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:flutter/material.dart';

import '../data_model/product_details_response.dart';
import '../screens/product/product_details.dart';

class WholesaleTextWidget extends StatelessWidget {
  const WholesaleTextWidget({
    super.key,
    required this.wholesales,
    required this.quantity,
    this.fontSize = 14,
    this.fontWeight,
    this.textBefore,
    this.textAfter,
  });

  final List<Wholesale> wholesales;
  final int quantity;
  final double fontSize;
  final FontWeight? fontWeight;
  final String? textBefore;
  final String? textAfter;

  @override
  Widget build(BuildContext context) {
    final StringBuffer text = StringBuffer();
    const String symbol = ' - ';

    for (int i = 0; i < wholesales.length; i++) {
      final int quantityText = distributeWholesale(
        index: i,
        total: quantity,
        list: wholesales,
      );
      if (quantityText == 0) continue;
      text.write("$symbol$quantityText ${wholesales[i].name}");
    }
    return RichText(
      maxLines: 3,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      textDirection: wholesales[0].name?.direction,
      text: TextSpan(
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        text: textBefore,
        children: [
          TextSpan(text: text.toString().replaceFirst(symbol, '')),
          if (textAfter != null) TextSpan(text: textAfter),
        ],
      ),
    );
  }
}
