import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:one_context/one_context.dart';

import '../constants/app_dimensions.dart';

abstract final class ShowMyDialog {
  const ShowMyDialog();

  // static void error(BuildContext context, {required String body}) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return CustomDialog(
  //         title: localeLang(context).error,
  //         body: body,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         textCancel: localeLang(context).understood,
  //         onPressCancel: Get.back,
  //       );
  //     },
  //   );
  // }

  // static Future<bool?> back({
  //   String? body,
  //   void Function()? onGoBack,
  // }) async {
  //   final bool? result = await Get.dialog<bool>(
  //     CustomDialog(
  //       title: localeLang().goBack,
  //       body: body ?? localeLang().areYouSureYouWantToReturnBack,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       textCancel: localeLang().goBack,
  //       onPressCancel: () {
  //         if (onGoBack != null) onGoBack();
  //         Get.back(result: true);
  //       },
  //       textConfirm: localeLang().stayHere,
  //       onPressConfirm: Get.back,
  //     ),
  //   );
  //   return result;
  // }

  static Future<bool?> locationDialog({
    String? body,
    void Function()? onPressCancel,
    void Function()? onPressConfirm,
  }) async {
    final BuildContext context = OneContext().context!;
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        icon: Icons.location_off,
        crossAxisAlignment: CrossAxisAlignment.center,
        body: "pleaseGoToVerifyYourLocation".tr(),
        title: "locationNotAccessed".tr(),
        textCancel: "cancel_ucf".tr(),
        textConfirm: "goToSetting".tr(),
        onPressCancel: () {
          if (onPressCancel != null) {
            onPressCancel();
          }
          Navigator.maybePop(context, false);
        },
        onPressConfirm: () {
          Geolocator.openLocationSettings();
          Navigator.maybePop(context);
        },
      ),
    );
  }

  // static Future<bool?> dialog({
  //   void Function()? onPressRemove,
  //   String? body,
  //   String? title,
  //   String? textCancel,
  //   String? textConfirm,
  //   void Function()? onPressConfirm,
  //   void Function()? onPressCancel,
  // }) async {
  //   final bool? result = await Get.dialog<bool>(
  //     CustomDialog(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       body: body ?? '',
  //       title: title ?? '',
  //       textCancel: textCancel ?? '',
  //       textConfirm: textConfirm ?? '',
  //       onPressCancel: () {
  //         if (onPressCancel != null) {
  //           onPressCancel();
  //         }
  //         Get.back(result: false);
  //       },
  //       onPressConfirm: () {
  //         if (onPressRemove != null) {
  //           onPressRemove();
  //         }
  //         if (onPressConfirm != null) {
  //           onPressConfirm();
  //         }
  //         Get.back(result: true);
  //       },
  //     ),
  //   );

  //   return result;
  // }
}

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    this.title = 'Title',
    this.icon,
    this.body = 'This is my Body',
    this.bodyAlign,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.customBody,
    this.onPressCancel,
    this.onPressConfirm,
    this.showCancelButton = true,
    this.textConfirm,
    this.textCancel,
  });
  final String title;
  final IconData? icon;
  final String body;
  final String? textConfirm;
  final String? textCancel;
  final bool showCancelButton;
  final Widget? customBody;
  final TextAlign? bodyAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final void Function()? onPressCancel;
  final void Function()? onPressConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: AppDimensions.paddingDefault),
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (icon != null)
                  Icon(icon, color: Theme.of(context).primaryColor),
              ],
            ),
            DialogBody(
              crossAxisAlignment: crossAxisAlignment,
              customBody: customBody,
              body: body,
              bodyAlign: bodyAlign,
              onPressConfirm: onPressConfirm,
              showCancelButton: showCancelButton,
              onPressCancel: onPressCancel,
              textConfirm: textConfirm,
              textCancel: textCancel,
            ),
          ],
        ),
      ),
    );
  }
}

class DialogBody extends StatelessWidget {
  const DialogBody({
    super.key,
    required this.crossAxisAlignment,
    required this.customBody,
    required this.body,
    required this.bodyAlign,
    required this.onPressConfirm,
    required this.showCancelButton,
    required this.onPressCancel,
    required this.textConfirm,
    required this.textCancel,
  });

  final CrossAxisAlignment crossAxisAlignment;
  final Widget? customBody;
  final String body;
  final TextAlign? bodyAlign;
  final void Function()? onPressConfirm;
  final bool showCancelButton;
  final void Function()? onPressCancel;
  final String? textConfirm;
  final String? textCancel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingDefault,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 2 * AppDimensions.paddingDefault),
            child: Visibility(
              visible: customBody == null,
              replacement: customBody ?? const SizedBox.shrink(),
              child: Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: bodyAlign,
              ),
            ),
          ),
          DialogButtons(
            onPressConfirm: onPressConfirm,
            showCancelButton: showCancelButton,
            onPressCancel: onPressCancel,
            textConfirm: textConfirm,
            textCancel: textCancel,
          )
        ],
      ),
    );
  }
}

class DialogButtons extends StatelessWidget {
  const DialogButtons({
    super.key,
    required this.onPressConfirm,
    required this.showCancelButton,
    required this.onPressCancel,
    required this.textConfirm,
    required this.textCancel,
  });

  final String? textConfirm;
  final String? textCancel;

  final void Function()? onPressConfirm;
  final bool showCancelButton;
  final void Function()? onPressCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Visibility(
          visible: onPressConfirm != null,
          child: Expanded(
            flex: 10,
            child: FilledButton(
              onPressed: onPressConfirm,
              child: Text(
                textConfirm ?? "confirm_ucf".tr(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Visibility(
          visible: onPressConfirm != null && showCancelButton,
          child: const Spacer(),
        ),
        Visibility(
          visible: showCancelButton,
          child: Expanded(
            flex: 10,
            child: OutlinedButton(
              onPressed: onPressCancel ?? () => Navigator.maybePop(context),
              child: Text(textCancel ?? "cancel_ucf".tr()),
            ),
          ),
        ),
      ],
    );
  }
}
