import 'package:flutter/material.dart';

import '../../../app_config.dart';
import '../../../services/navigation_service.dart';

Widget? get whatsappFloatingButtonWidget {
  final String? phone = AppConfig.businessSettingsData.whatsappNumber
      ?.replaceAll("+", '')
      .replaceAll(RegExp(r'[^\d+]'), '')
      .trim();
  if (phone?.isEmpty ?? true) return null;
  return FloatingActionButton(
    onPressed: () {
      NavigationService.handleUrls("https://wa.me/$phone");
    },
    backgroundColor: const Color(0xff289811),
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      child: Image.asset(AppImages.whatsapp),
    ),
  );
}
