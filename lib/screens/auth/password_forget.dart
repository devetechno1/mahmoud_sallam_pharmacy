import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/intl_phone_input.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/password_otp.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../app_config.dart';
import '../../data_model/otp_provider_model.dart';
import '../../repositories/address_repository.dart';
import '../../ui_elements/select_otp_provider_widget.dart';

class PasswordForget extends StatefulWidget {
  @override
  _PasswordForgetState createState() => _PasswordForgetState();
}

class _PasswordForgetState extends State<PasswordForget> {
  OTPProviderModel? provider =
      AppConfig.businessSettingsData.otpProviders.firstOrNull;
  String _send_code_by = otp_addon_installed.$ ? "phone" : "email";
  String? _phone = "";
  var countries_code = <String?>[];
  //controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  Future<void> onPressSendCode() async {
    final email = _emailController.text.toString();

    if (_send_code_by == 'email' && email == "") {
      ToastComponent.showDialog(
        'enter_email'.tr(context: context),
        isError: true,
      );
      return;
    } else if (_send_code_by == 'phone') {
      if (_phone?.trim().isNotEmpty != true) {
        ToastComponent.showDialog(
          'enter_phone_number'.tr(context: context),
          isError: true,
        );
        return;
      } else if (provider == null) {
        ToastComponent.showDialog(
          'please_select_otp_provider'.tr(context: context),
          isError: true,
        );
        return;
      }
    }
    final passwordForgetResponse =
        await AuthRepository().getPasswordForgetResponse(
      _send_code_by == 'email' ? email : _phone,
      _send_code_by,
      provider?.type,
    );

    if (passwordForgetResponse.result == false) {
      ToastComponent.showDialog(
        passwordForgetResponse.message!,
        isError: true,
      );
    } else {
      ToastComponent.showDialog(
        passwordForgetResponse.message!,
      );

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PasswordOtp(
          verify_by: _send_code_by,
          email_or_code: _send_code_by == 'email' ? email : _phone,
          provider: provider,
        );
      }));
    }
  }

  fetch_country() async {
    final data = await AddressRepository().getCountryList();
    data.countries?.forEach((c) => countries_code.add(c.code));
  }

  @override
  Widget build(BuildContext context) {
    final _screen_width = MediaQuery.sizeOf(context).width;
    return AuthScreen.buildScreen(
        context,
        'forget_password'.tr(context: context),
        buildBody(_screen_width, context));
  }

  Column buildBody(double _screen_width, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 20,
        ),
        Container(
          width: _screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingSmallExtra),
                child: Text(
                  _send_code_by == "email"
                      ? 'email_ucf'.tr(context: context)
                      : 'phone_ucf'.tr(context: context),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              if (_send_code_by == "email")
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 36,
                        child: TextField(
                          controller: _emailController,
                          autofocus: false,
                          decoration: InputDecorations.buildInputDecoration_1(
                              hint_text: "user@example.com"),
                        ),
                      ),
                      otp_addon_installed.$
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _send_code_by = "phone";
                                });
                              },
                              child: Text(
                                'or_send_code_via_phone_number'
                                    .tr(context: context),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline),
                              ),
                            )
                          : emptyWidget
                    ],
                  ),
                )
              else ...[
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 36,
                        child: CustomInternationalPhoneNumberInput(
                          countries: countries_code,
                          hintText: 'phone_number_ucf'.tr(context: context),
                          errorMessage:
                              'invalid_phone_number'.tr(context: context),
                          initialValue:
                              PhoneNumber(isoCode: AppConfig.default_country),
                          onInputChanged: (PhoneNumber number) {
                            //print(number.phoneNumber);
                            setState(() {
                              if (number.isoCode != null)
                                AppConfig.default_country = number.isoCode!;
                              _phone = number.phoneNumber;
                            });
                          },
                          onInputValidated: (bool value) {
                            //print(value);
                          },
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle:
                              const TextStyle(color: MyTheme.font_grey),
                          // initialValue: phoneCode,
                          textFieldController: _phoneNumberController,
                          formatInput: true,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputDecoration:
                              InputDecorations.buildInputDecoration_phone(
                                  hint_text: "01XX XXX XXXX"),
                          onSaved: (PhoneNumber number) {
                            //print('On Saved: $number');
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _send_code_by = "email";
                          });
                        },
                        child: Text(
                          'or_send_code_via_email'.tr(context: context),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingDefault),
                      SelectOTPProviderWidget(
                        selectedProvider: provider,
                        onSelect: (val) => setState(() => provider = val),
                      ),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(
                    top: AppDimensions.paddingVeryExtraLarge),
                child: SizedBox(
                  height: 45,
                  child: Btn.basic(
                    minWidth: MediaQuery.sizeOf(context).width,
                    color: Theme.of(context).primaryColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.radiusHalfSmall),
                      ),
                    ),
                    child: Text(
                      'send_code_ucf'.tr(context: context),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      onPressSendCode();
                    },
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
