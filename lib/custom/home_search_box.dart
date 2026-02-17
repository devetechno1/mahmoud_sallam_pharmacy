import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';

import 'package:active_ecommerce_cms_demo_app/presenter/unRead_notification_counter.dart';
import 'package:active_ecommerce_cms_demo_app/screens/notification/notification_list.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wishlist/widgets/page_animation.dart';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

class HomeSearchBox extends StatelessWidget {
  final BuildContext? context;
  const HomeSearchBox({Key? key, this.context}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
              color: const Color(0xffE4E3E8),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 63, 63, 63).withValues(alpha: .12),
                  blurRadius: 15,
                  spreadRadius: 0.4,
                  offset: const Offset(0.0, 5.0),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.search,
                    height: 16,
                    color: const Color(0xff7B7980),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppConfig.search_bar_text(context),
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: Color(0xff7B7980),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        badges.Badge(
          showBadge: is_logged_in.$,
          position: badges.BadgePosition.topEnd(top: 0, end: 0),
          badgeStyle: badges.BadgeStyle(
            shape: badges.BadgeShape.circle,
            badgeColor: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
            padding: const EdgeInsets.all(3),
          ),
          ignorePointer: true,
          badgeContent: Consumer<UnReadNotificationCounter>(

            builder: (context, notification, child) {
              return Text(
                "${notification.unReadNotificationCounter}",
                style: const TextStyle(fontSize: 9, color: Colors.white),
              );
            },
          ),
          child: GestureDetector(
            onTap: is_logged_in.$
                ? () {
                    Navigator.push(
                    context,
                    PageAnimation.fadeRoute(const NotificationList()),
                  ).then((_) {
                    Provider.of<UnReadNotificationCounter>(context, listen: false).getCount();
                  });
                  }
                : () {
                    ToastComponent.showDialog(
                      'you_need_to_log_in'.tr(context: context),
                      isError: true,
                    );
                  },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xffE4E3E8),
                borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Image.asset(
                  AppImages.notification,
                  height: 18,
                  color: const Color(0xff7B7980),
                  // color: const Color(0xff7B7980),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
