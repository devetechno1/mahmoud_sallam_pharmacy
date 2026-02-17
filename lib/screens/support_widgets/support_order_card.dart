import 'package:flutter/material.dart';
import '../../my_theme.dart';
import '../../custom/box_decorations.dart';
import '../../locale/custom_localization.dart';
import '../../data_model/order_mini_response.dart';
import '../../constants/app_dimensions.dart';

class SupportOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const SupportOrderCard({
    Key? key,
    required this.order,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dynamic o = order;
    final String date = (o.date ?? '').toString();
    final String paymentText = (o.payment_status_string ?? '').toString();
    final Color? paymentColor = o.paymentStatus?.color;
    final String deliveryText = (o.delivery_status_string ?? '').toString();
    final String total = (o.grand_total ?? o.total ?? '').toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
             borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusDefault),
            bottomRight: Radius.circular(AppDimensions.radiusDefault),
            bottomLeft: Radius.circular(AppDimensions.radiusDefault),
          ),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(
                        color: MyTheme.dark_font_grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "${'payment_status_ucf'.tr(context: context)} - ",
                    style: const TextStyle(
                      color: MyTheme.dark_font_grey,
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      paymentText,
                      style: TextStyle(
                        color: paymentColor ?? MyTheme.dark_font_grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                   Text(
                    "${'delivery_status_ucf'.tr(context: context)} - ",
                    style: const TextStyle(
                      color: MyTheme.dark_font_grey,
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      deliveryText,
                      style: const TextStyle(
                        color: MyTheme.dark_font_grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (total.isNotEmpty) ...[
                 const SizedBox(height: 10),
                 Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    total,
                    style: const TextStyle(
                      color: Color(0xFF2B2B2B),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
