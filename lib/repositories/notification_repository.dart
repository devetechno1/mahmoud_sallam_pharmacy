import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/data_model/common_response.dart';

import '../app_config.dart';
import '../helpers/main_helpers.dart';
import '../middlewares/banned_user.dart';
import '../screens/notification/models/all_notification_list_response.dart';
import '../screens/notification/models/unread_notification_list_response.dart';
import 'api-request.dart';

class NotificationRepository {
  Future<AllNotificationListResponse> getAllNotification() async {
    const String url = ("${AppConfig.BASE_URL}/all-notification");
    final Map<String, String> header = commonHeader;
    header.addAll(authHeader);
    final response = await ApiRequest.get(
        url: url, headers: header, middleware: BannedUser());

    return allNotificationListResponseFromJson(response.body);
  }

  Future<UnreadNotificationListResponse> getUnreadNotification() async {
    const String url = ("${AppConfig.BASE_URL}/unread-notifications");
    final Map<String, String> header = commonHeader;
    header.addAll(authHeader);
    final response = await ApiRequest.get(
        url: url, headers: header, middleware: BannedUser());

    // print('response body for notification');
    // print(response.body);

    return unreadNotificationListResponseFromJson(response.body);
  }

  Future<CommonResponse> notificationBulkDelete(notificationIds) async {
    final postBody = jsonEncode({"notification_ids": "$notificationIds"});

    print(postBody);
    const String url = ("${AppConfig.BASE_URL}/notifications/bulk-delete");
    final Map<String, String> header = commonHeader;
    header.addAll(authHeader);
    final response = await ApiRequest.post(
        url: url, headers: header, middleware: BannedUser(), body: postBody);

    // print('response body for notification');
    // print(response.body);

    return commonResponseFromJson(response.body);
  }
}
