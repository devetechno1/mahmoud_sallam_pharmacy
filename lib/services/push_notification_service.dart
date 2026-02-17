import 'dart:convert';
import 'dart:io';

import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:active_ecommerce_cms_demo_app/screens/orders/order_details.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:one_context/one_context.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import '../helpers/shimmer_helper.dart';
import 'navigation_service.dart';

final FirebaseMessaging _fcm = FirebaseMessaging.instance;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  '0', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class PushNotificationService {
  static Future initialize() async {
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    updateDeviceToken();

    FirebaseMessaging.onMessage.listen((event) async {
      print("onLaunch: ${jsonEncode(event.toMap())}");
      if (Platform.isIOS) {
        _showIosMessage(event);
        return;
      }
      //(Map<String, dynamic> message) async => _showMessage(message);
      final RemoteNotification? notification = event.notification;

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final AndroidNotification? android = notification?.android;
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/notification_icon');

      const InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsIOS);

      BigPictureStyleInformation? bigPictureStyle;
      FilePathAndroidBitmap? image;
      if (android?.imageUrl != null) {
        final String largeIconPath =
            await _downloadAndSaveFile(android!.imageUrl!, 'largeIcon');
        image = FilePathAndroidBitmap(largeIconPath);
        bigPictureStyle = BigPictureStyleInformation(
          image,
          contentTitle: notification?.title,
          summaryText: notification?.body,
          hideExpandedLargeIcon: true,
        );
      }

      final AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        channel.id,
        channel.name,
        importance: Importance.max,
        priority: Priority.max,
        icon: android?.smallIcon,
        styleInformation: bigPictureStyle,
        largeIcon: image,
      );

      const DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails();

      flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          _serialiseAndNavigate(jsonDecode(details.payload ?? '{}'));
        },
      );

      if (notification != null) {
        return flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: androidNotificationDetails,
              iOS: darwinNotificationDetails),
          payload: jsonEncode(event.toMap()),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onResume: ${message.toMap()}");
      _serialiseAndNavigate(message.toMap());
    });
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static Future<void> updateDeviceToken() async {
    if (is_logged_in.$) {
      if (Platform.isIOS) {
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _fcm.getAPNSToken();
        }
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _fcm.getAPNSToken();
        }
      }

      String? fcmToken;
      try {
        fcmToken = await _fcm.getToken();
      } catch (e) {
        print("Error getting FCM token: $e");
      }

      print("fcmToken $fcmToken");

      if (fcmToken != null) {
        await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
      }
    }
  }

  static void _showIosMessage(RemoteMessage message) {
    //print("onMessage: $message");

    OneContext().showDialog(
      // barrierDismissible: false,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text(message.notification!.title!),
          subtitle: message.notification?.apple?.imageUrl == null
              ? Text(message.notification!.body!)
              : _dialogImageBody(message),
        ),
        actions: <Widget>[
          Btn.basic(
            child: Text('close_ucf'.tr(context: context)),
            onPressed: () => Navigator.pop(context),
          ),
          Btn.basic(
            child: Text('go'.tr(context: context)),
            onPressed: () {
              Navigator.pop(context);
              _serialiseAndNavigate(message.toMap());
            },
          ),
        ],
      ),
    );
  }

  static void _serialiseAndNavigate(Map<String, dynamic> message) {
    if (is_logged_in.$ == false) {
      OneContext().showDialog(
          // barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Text('you_are_not_logged_in'.tr(context: context)),
                content: Text('please_log_in'.tr(context: context)),
                actions: <Widget>[
                  Btn.basic(
                    child: Text('close_ucf'.tr(context: context)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Btn.basic(
                      child: Text('log_in'.tr(context: context)),
                      onPressed: () {
                        Navigator.pop(context);
                        OneContext().push(MaterialPageRoute(builder: (_) {
                          return const Login();
                        }));
                      }),
                ],
              ));
      return;
    }
    if (message['data']['item_type'] == 'order') {
      OneContext().push(MaterialPageRoute(builder: (_) {
        return OrderDetails(
            id: int.parse(message['data']['item_type_id']),
            from_notification: true);
      }));
    } else {
      NavigationService.handleUrls(message['data']['link']);
    }
  }
}

class _dialogImageBody extends StatelessWidget {
  const _dialogImageBody(this.message);
  final RemoteMessage message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Text(message.notification!.body!),
        const SizedBox(height: 16),
        ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
            child: Image.network(
              message.notification!.apple!.imageUrl!,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return ShimmerHelper().buildBasicShimmer(height: 120.0);
              },
            )),
      ],
    );
  }
}
