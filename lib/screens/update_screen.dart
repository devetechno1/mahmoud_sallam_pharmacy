import 'package:active_ecommerce_cms_demo_app/app_config.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data_model/business_settings/update_model.dart';
import '../services/navigation_service.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UpdateDataModel updateData =
        AppConfig.businessSettingsData.updateData!;
    final bool canGoHome = !updateData.mustUpdate;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (canGoHome) navigateToHome(context);
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMaxLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.applogo,
                  width: 200,
                  height: 250,
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  'avaliable_update'.tr(context: context),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingDefault),
                Text(
                  'please_update_to_continue'.tr(context: context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: AppDimensions.paddingVeryExtraLarge),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.system_update_alt,
                    color: Colors.white,
                  ),
                  label: Text(
                    'update_now_ucf'.tr(context: context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => NavigationService.handleUrls(
                    updateData.storeLink,
                    context: context,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: const Size(500, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                if (canGoHome)
                  TextButton(
                    onPressed: () => navigateToHome(context),
                    child: Text(
                      'skip_ucf'.tr(context: context),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        // decoration: TextDecoration.underline, // يمكن إضافة خط تحت النص ليظهر أكثر وضوحًا
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateToHome(BuildContext context) {
    final GoRouter goRouter = GoRouter.of(context);
    final String newPath = goRouter.state.uri.queryParameters['url'] ?? '/';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      goRouter.go(newPath, extra: {'skipUpdate': true});
    });
  }
}
