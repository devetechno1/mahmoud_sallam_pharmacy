import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:geolocator/geolocator.dart';

import 'my_dialogs.dart';
import 'show_my_snack_bar.dart';

abstract final class HandlePermissions {
  static Future<Position?> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      await Geolocator.requestPermission();
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        ShowMySnackBar.error("locationIsDenied".tr());
        return null;
      } else if (permission == LocationPermission.deniedForever) {
        ShowMySnackBar.reRequestPermissionToast(
          text: "locationIsDeniedPermanently".tr(),
          actionText: "goToSetting".tr(),
          onPressed: Geolocator.openAppSettings,
        );
        return null;
      }
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await ShowMyDialog.locationDialog();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // static  Future<bool> requestCameraPermission() async {
  //   PermissionStatus status = await Permission.camera.status;
  //   if (!status.isGranted) {
  //     status = await Permission.camera.request();
  //   }
  //   return status.isGranted;
  // }
}
