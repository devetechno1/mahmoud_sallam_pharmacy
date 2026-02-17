import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import '../../app_config.dart';

enum StoreType {
  appGallery,
  playStore,
  appleStore,
  unknown;

  const StoreType();

  static Future<StoreType> thisDeviceType() async {
    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
      AppConfig.deviceInfo = {"device_type": "ios", "info": iosInfo.data};
      return appleStore;
    }

    final AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    AppConfig.deviceInfo = {"device_type": "android", "info": androidInfo.data};

    if (androidInfo.manufacturer.toLowerCase() == 'huawei') return appGallery;
    return playStore;
  }
}

class UpdateDataModel {
  final bool mustUpdate;
  final String? version;
  final String? storeLink;

  const UpdateDataModel({
    required this.mustUpdate,
    required this.version,
    required this.storeLink,
  });
}
