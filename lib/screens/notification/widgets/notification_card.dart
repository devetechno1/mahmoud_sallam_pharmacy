import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app_config.dart';
import '../../../custom/box_decorations.dart';
import '../../../custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import '../../orders/order_details.dart';
import 'image_show.dart';

class NotificationListCard extends StatefulWidget {
  final String? id;
  final String? type;
  final int? orderId;
  final String? orderCode;
  final String? status;
  final String? notificationText;
  final dynamic link;
  final String? dateTime;
  final String? image;
  final bool? isChecked;
  final Function(String, bool) onSelect;
  const NotificationListCard(
      {Key? key,
      this.id,
      this.isChecked,
      this.type,
      this.orderId,
      this.orderCode,
      this.status,
      this.notificationText,
      this.link = '',
      this.dateTime,
      required this.onSelect,
      this.image})
      : super(key: key);

  @override
  State<NotificationListCard> createState() => _NotificationListCardState();
}

class _NotificationListCardState extends State<NotificationListCard> {
  _onTap(context) {
    // print('ontap');

    if (widget.type == "App\\Notifications\\CustomNotification") {
      final url = widget.link?.split(AppConfig.DOMAIN_PATH).last ?? "";
      GoRouter.of(context).go(url);
    }

    if (widget.type == "App\\Notifications\\OrderNotification") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderDetails(
                    id: widget.orderId,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1(),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        width: DeviceInfo(context).width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: Row(
            children: [
              Container(
                height: 30,
                width: 30,
                child: Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  value: widget.isChecked,
                  onChanged: (value) {
                    widget.onSelect(widget.id!, value ?? false);
                  },
                ),
              ),
              ImageShow(
                notificationShowType:
                    AppConfig.businessSettingsData.notificationShowType ?? '',
                image: widget.image ?? "",
              ),
              const SizedBox(width: 5),
              Expanded(
                // Wrap the Column with Expanded
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (widget.type == "App\\Notifications\\CustomNotification")
                      Text(
                        "${widget.notificationText}",
                        style: TextStyle(
                            color: (widget.link != '' && widget.link != null)
                                ? Theme.of(context).primaryColor
                                : Colors.black,
                            fontSize: 16),
                      ),
                    if (widget.type == "App\\Notifications\\OrderNotification")
                      Flexible(
                        // Use Flexible instead of Expanded
                        child: RichText(
                          text: TextSpan(
                            text: 'your_order'.tr(context: context),
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: "${widget.orderCode}",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              TextSpan(
                                text:
                                    '${'has_been'.tr(context: context)}${widget.status}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 5),
                    Text(
                      '${widget.dateTime}',
                      style: const TextStyle(color: MyTheme.medium_grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
