// otp_input.dart
import 'dart:io' show Platform;
import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

class OtpInputController extends ChangeNotifier {
  OtpInputController({this.length = 6})
      : _regex = RegExp(r'(?<!\d)\d{' + lengthStr(6) + r'}(?!\d)') {
    _regex = RegExp(r'(?<!\d)\d{' + length.toString() + r'}(?!\d)');
    listenOnceUserConsent();
  }

  final int length;

  final TextEditingController pinController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final SmartAuth _smartAuth = SmartAuth.instance;
  late RegExp _regex;

  String get text => pinController.text;

  void fill(String code) {
    pinController.text = code;
    pinController.selection = TextSelection.fromPosition(
      TextPosition(offset: pinController.text.length),
    );
    notifyListeners();
  }

  void clear() {
    pinController.clear();
    notifyListeners();
  }

  Future<String?> listenOnceUserConsent() async {
    if (!Platform.isAndroid) return null;
    return await _listenOnceUserConsent();
  }

  Future<String?> _listenOnceUserConsent() async {
    try {
      final res = await _smartAuth.getSmsWithUserConsentApi();
      if (res.hasData) {
        final data = res.requireData;
        final code = data.code ?? _extractFromSms(data.sms);
        if (code != null) fill(code);
        return code;
      }
    } catch (e) {
      debugPrint("SmartAuth Error: $e");
    }
    return null;
  }

  Future<void> stopListening() async {
    await _smartAuth.removeUserConsentApiListener();
    await _smartAuth.removeSmsRetrieverApiListener();
  }

  String? _extractFromSms(String? sms) {
    if (sms == null) return null;
    final m = _regex.firstMatch(sms);
    return m?.group(0);
  }

  @override
  void dispose() {
    stopListening();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  static String lengthStr(int n) => n.toString();
}

class OtpInputWidget extends StatelessWidget {
  const OtpInputWidget({
    super.key,
    required this.controller,
    this.onCompleted,
    this.onChanged,
    this.autofocus = true,
    required this.isDigitOnly,
  });

  final OtpInputController controller;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final bool autofocus;
  final bool isDigitOnly;

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
    );

    return SizedBox(
      width: double.maxFinite,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Pinput(
          length: controller.length,
          controller: controller.pinController,
          focusNode: controller.focusNode,
          defaultPinTheme: defaultTheme,
          crossAxisAlignment: CrossAxisAlignment.center,
          separatorBuilder: (index) =>
              const SizedBox(width: AppDimensions.paddingNormal),
          autofocus: autofocus,
          // iOS hint
          autofillHints: const [AutofillHints.oneTimeCode],
          keyboardType: isDigitOnly ? TextInputType.number : TextInputType.text,
          inputFormatters: [
            if (isDigitOnly) FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: onChanged,
          onCompleted: onCompleted,
        ),
      ),
    );
  }
}
