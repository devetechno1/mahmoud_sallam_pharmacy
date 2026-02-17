import 'package:flutter/material.dart';

class DeviceInfo {
  BuildContext context;
  double? height, width;

  DeviceInfo(this.context) {
    height = MediaQuery.sizeOf(context).height;
    width = MediaQuery.sizeOf(context).width;
  }
}
