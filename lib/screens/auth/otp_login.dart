import 'dart:developer';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/intl_phone_input.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/custom_otp.dart';
import 'package:active_ecommerce_cms_demo_app/status/execute_and_handle_remote_errors.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../custom/loading.dart';
import '../../data_model/login_response.dart';
import '../../repositories/address_repository.dart';
import '../../status/status.dart';

class OTPLoginScreen extends StatefulWidget {
  final String providerType;
  final String providerName;

  const OTPLoginScreen({
    super.key,
    required this.providerName,
    required this.providerType,
  });
  @override
  _OTPLoginScreenState createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  List<String?> countriesCode = <String?>[];
  PhoneNumber? _phone;

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  Future<void> fetch_country() async {
    try {
      final data = await AddressRepository().getCountryList();
      data.countries?.forEach((c) => countriesCode.add(c.code));
      setState(() {});
    } catch (e) {}
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  Future<void> onPressedLogin() async {
    FocusScope.of(context).unfocus();

    if (_phone?.parseNumber().isNotEmpty != true) {
      return onError("enter_phone_number".tr(context: context));
    }
    final bool isSuccess = await sendOTPLoginCode(
      context,
      _phone,
      widget.providerType,
    );

    if (!isSuccess) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomOTPScreen(
          phone: _phone!,
          provider: widget.providerType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return AuthScreen.buildScreen(
      context,
      "${"login_to".tr(context: context)} " +
          'app_name'.tr(context: context) +
          '\n' +
          "by".tr(context: context, args: {"provider": widget.providerName}),
      buildBody(context, screenWidth),
    );
  }

  Widget buildBody(BuildContext context, double screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingSmallExtra),
                child: Text(
                  "login_screen_phone".tr(context: context),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 36,
                      child: CustomInternationalPhoneNumberInput(
                        countries: countriesCode,
                        hintText: 'phone_number_ucf'.tr(context: context),
                        errorMessage:
                            'invalid_phone_number'.tr(context: context),
                        initialValue:
                            PhoneNumber(isoCode: AppConfig.default_country),
                        onInputChanged: (PhoneNumber number) {
                          setState(() {
                            if (number.isoCode != null)
                              AppConfig.default_country = number.isoCode!;
                            _phone = number;
                          });
                        },
                        onInputValidated: (bool value) {
                          print(value);
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.DIALOG,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle:
                            const TextStyle(color: MyTheme.font_grey),
                        textStyle: const TextStyle(color: MyTheme.font_grey),
                        formatInput: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        inputDecoration:
                            InputDecorations.buildInputDecoration_phone(
                          hint_text: "01XXX XXX XXX",
                        ),
                        onSaved: (PhoneNumber number) {
                          print('On Saved: $number');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: AppDimensions.paddingExtraLarge),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: MyTheme.textfield_grey, width: 1),
                            borderRadius: const BorderRadius.all(
                                Radius.circular(AppDimensions.radiusNormal))),
                        child: Btn.minWidthFixHeight(
                          minWidth: MediaQuery.sizeOf(context).width,
                          height: 50,
                          color: Theme.of(context).primaryColor,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  AppDimensions.radiusHalfSmall))),
                          child: Text(
                            "login_screen_log_in".tr(context: context),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: onPressedLogin,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

void onError(message) {
  log("$message");
  if (message.runtimeType == List) {
    ToastComponent.showDialog(
      message.join("\n"),
      isError: true,
    );
    return;
  }
  ToastComponent.showDialog(
    message.toString(),
    isError: true,
  );
}

Future<bool> sendOTPLoginCode(
    BuildContext context, PhoneNumber? phone, String provider) async {
  Loading.show(context);
  final Status<LoginResponse> status = await executeAndHandleErrors(
    () => AuthRepository().getOTPLoginResponse(
      countryCode: phone?.dialCode ?? '',
      phone: phone?.parseNumber() ?? '',
      provider: provider,
    ),
  );
  Loading.close();

  if (status is Failure<LoginResponse>) {
    onError(status.failure.message);
    return false;
  }

  final LoginResponse loginResponse = (status as Success<LoginResponse>).data;

  if (loginResponse.result == false) {
    onError(loginResponse.message);
    return false;
  }

  ToastComponent.showDialog(loginResponse.message!);
  return true;
}
