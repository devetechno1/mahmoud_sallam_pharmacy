import 'package:active_ecommerce_cms_demo_app/repositories/notification_repository.dart';
import 'package:flutter/material.dart';

class UnReadNotificationCounter extends ChangeNotifier {
  int unReadNotificationCounter = 0;

  getCount() async {
    final res = await NotificationRepository().getUnreadNotification();
    unReadNotificationCounter = res.count ?? 0;
    notifyListeners();
  }
}
