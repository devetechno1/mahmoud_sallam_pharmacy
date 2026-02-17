import 'dart:io';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/google_recaptcha.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/intl_phone_input.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/other_config.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:active_ecommerce_cms_demo_app/screens/common_webview_screen.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

import '../../custom/loading.dart';
import '../../data_model/otp_provider_model.dart';
import '../../helpers/auth_helper.dart';
import '../../helpers/business_setting_helper.dart';
import '../../presenter/home_provider.dart';
import '../../repositories/address_repository.dart';
import '../../ui_elements/select_otp_provider_widget.dart';
import 'otp.dart';
import 'package:go_router/go_router.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  List<String?> countries_code = <String?>[];

  String _phone = "";
  bool _isValidPhoneNumber = false;
  bool? _isAgree = false;
  bool _isCaptchaShowing = false;
  String googleRecaptchaKey = "";

  OTPProviderModel? provider =
      AppConfig.businessSettingsData.otpProviders.firstOrNull;

  late final homeP = context.read<HomeProvider>();

  //controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  fetch_country() async {
    final data = await AddressRepository().getCountryList();
    data.countries?.forEach((c) => countries_code.add(c.code));
    setState(() {});
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> onPressSignUp() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String passwordConfirm = _passwordConfirmController.text;

    if (name == "") {
      ToastComponent.showDialog(
        'enter_your_name'.tr(context: context),
        isError: true,
      );
      return;
    } else if (email.isNotEmpty && !isEmail(email)) {
      ToastComponent.showDialog(
        'enter_correct_email'.tr(context: context),
        isError: true,
      );
      return;
    } else if (_phoneNumberController.text.trim() == "") {
      ToastComponent.showDialog(
        'enter_phone_number'.tr(context: context),
        isError: true,
      );
      return;
    } else if (_isValidPhoneNumber) {
      ToastComponent.showDialog(
        'invalid_phone_number'.tr(context: context),
        isError: true,
      );
      return;
    } else if (AppConfig.businessSettingsData.mustOtp && provider == null) {
      BusinessSettingHelper.getOTPLoginProviders();
      setState(() {});
      ToastComponent.showDialog(
        'please_select_otp_provider'.tr(context: context),
        isError: true,
      );
      return;
    } else if (password == "") {
      ToastComponent.showDialog(
        'enter_password'.tr(context: context),
        isError: true,
      );
      return;
    } else if (passwordConfirm == "") {
      ToastComponent.showDialog(
        'confirm_your_password'.tr(context: context),
        isError: true,
      );
      return;
    } else if (password.length < 6) {
      ToastComponent.showDialog(
        'password_must_contain_at_least_6_characters'.tr(context: context),
        isError: true,
      );
      return;
    } else if (password != passwordConfirm) {
      ToastComponent.showDialog(
        'passwords_do_not_match'.tr(context: context),
        isError: true,
      );
      return;
    }
    if (Loading.isLoading) return;
    Loading.show(context);

    // final String tempEmail =
    //     email.trim().isEmpty ? "$_phone@email.com" : email.trim();

    final signupResponse = await AuthRepository().getSignupResponse(
        name,
        email.trim(),
        _phone,
        password,
        passwordConfirm,
        googleRecaptchaKey,
        provider?.type);
    Loading.close();

    if (signupResponse.result == false) {
      var message = "";
      signupResponse.message.forEach((value) {
        message += value + "\n";
      });

      ToastComponent.showDialog(message, isError: true);
    } else {
      ToastComponent.showDialog(
        signupResponse.message,
      );
      await AuthHelper().setUserData(signupResponse);

      // redirect to main
      // Navigator.pushAndRemoveUntil(context,
      //     MaterialPageRoute(builder: (context) {
      //       return Main();
      //     }), (newRoute) => false);
      // context.go("/");

      // push notification starts
      if (OtherConfig.USE_PUSH_NOTIFICATION) {
        final FirebaseMessaging _fcm = FirebaseMessaging.instance;
        await _fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        String? fcmToken;
        try {
          fcmToken = await _fcm.getToken();
        } catch (e) {
          if (Platform.isIOS) {
            fcmToken = await _fcm.getAPNSToken();
          }
          print('Caught exception: $e');
        }

        print("--fcm token--");
        print("fcmToken $fcmToken");
        if (is_logged_in.$ == true && fcmToken?.isNotEmpty == true) {
          // update device token
          await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken!);
        }
      }

      // context.go("/");

      if (AppConfig.businessSettingsData.mailVerificationStatus ||
          AppConfig.businessSettingsData.mustOtp) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Otp(
            fromRegistration: true,
            isPhone: AppConfig.businessSettingsData.mustOtp,
            emailOrPhone:
                AppConfig.businessSettingsData.mustOtp ? _phone : email,
            provider: provider,
            // verify_by: _register_by,
            // user_id: signupResponse.user_id,
          );
        }));
      } else {
        OneContext().context!.push("/");
        await Future.delayed(Duration.zero);
        if (AppConfig.businessSettingsData.sellerWiseShipping) {
          homeP.handleAddressNavigation(true);
        }

        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return Home();
        // }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screen_width = MediaQuery.sizeOf(context).width;
    return AuthScreen.buildScreen(
        context,
        "${'join_ucf'.tr(context: context)} " + 'app_name'.tr(context: context),
        buildBody(context, _screen_width));
  }

  Column buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SignUpField(
                fieldController: _nameController,
                keyboardType: TextInputType.name,
                label: 'name_ucf'.tr(context: context),
              ),
              _SignUpField(
                isRequired: false,
                fieldController: _emailController,
                label: 'email_ucf'.tr(context: context),
                hint: 'johndoe@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              _SignUpField(
                label: 'phone_ucf'.tr(context: context),
                customWidget: CustomInternationalPhoneNumberInput(
                  countries: countries_code,
                  hintText: 'phone_number_ucf'.tr(context: context),
                  errorMessage: 'invalid_phone_number'.tr(context: context),
                  initialValue: PhoneNumber(isoCode: AppConfig.default_country),
                  keyboardAction: TextInputAction.next,
                  onInputChanged: (PhoneNumber number) {
                    _phoneNumberController.text = number.parseNumber();
                    setState(() {
                      if (number.isoCode != null)
                        AppConfig.default_country = number.isoCode!;
                      _phone = number.phoneNumber ?? '';
                    });
                  },
                  onInputValidated: (bool isNotValid) {
                    print(isNotValid);
                    _isValidPhoneNumber = !isNotValid;
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DIALOG,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: const TextStyle(color: MyTheme.font_grey),
                  // initialValue: PhoneNumber(
                  //     isoCode: countries_code[0].toString()),
                  formatInput: true,
                  inputDecoration: InputDecorations.buildInputDecoration_phone(
                    hint_text: "01XXX XXX XXX",
                  ),
                  onSaved: (PhoneNumber number) {
                    //print('On Saved: $number');
                  },
                ),
              ),
              if (AppConfig.businessSettingsData.mustOtp)
                SelectOTPProviderWidget(
                  margin: const EdgeInsets.only(
                    top: AppDimensions.paddingSmall,
                    bottom: AppDimensions.paddingDefault,
                  ),
                  selectedProvider: provider,
                  onSelect: (val) => setState(() => provider = val),
                ),
              _SignUpField(
                fieldController: _passwordController,
                label: 'password_ucf'.tr(context: context),
                hint: '• • • • • • • •',
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                otherWidgets: [
                  Text(
                    'password_must_contain_at_least_6_characters'
                        .tr(context: context),
                    style: const TextStyle(
                      color: MyTheme.textfield_grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              _SignUpField(
                fieldController: _passwordConfirmController,
                label: 'retype_password_ucf'.tr(context: context),
                hint: '• • • • • • • •',
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
              ),
              if (AppConfig.businessSettingsData.googleRecaptcha)
                Container(
                  height: _isCaptchaShowing ? 350 : 50,
                  width: 300,
                  child: Captcha(
                    (keyValue) {
                      googleRecaptchaKey = keyValue;
                      setState(() {});
                    },
                    handleCaptcha: (data) {
                      if (_isCaptchaShowing.toString() != data) {
                        _isCaptchaShowing = data;
                        setState(() {});
                      }
                    },
                    isIOS: Platform.isIOS,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.paddingLarge),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      child: Checkbox(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusHalfSmall)),
                          value: _isAgree,
                          onChanged: (newValue) {
                            _isAgree = newValue;
                            setState(() {});
                          }),
                    ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(start: 8.0),
                        width: DeviceInfo(context).width! - 130,
                        child: RichText(
                            maxLines: 2,
                            text: TextSpan(
                                style: const TextStyle(
                                    color: MyTheme.font_grey, fontSize: 12),
                                children: [
                                  TextSpan(
                                    text: 'i_agree_to_the'.tr(context: context),
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CommonWebviewScreen(
                                                      page_name:
                                                          'terms_conditions_ucf'
                                                              .tr(
                                                                  context:
                                                                      context),
                                                      url:
                                                          "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
                                                    )));
                                      },
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                    text:
                                        " ${'terms_conditions_ucf'.tr(context: context)}",
                                  ),
                                  const TextSpan(
                                    text: " &",
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CommonWebviewScreen(
                                                      page_name:
                                                          'privacy_policy_ucf'
                                                              .tr(
                                                                  context:
                                                                      context),
                                                      url:
                                                          "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
                                                    )));
                                      },
                                    text:
                                        " ${'privacy_policy_ucf'.tr(context: context)}",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  )
                                ])),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: AppDimensions.paddingExtraLarge),
                child: Container(
                  height: 45,
                  child: Btn.minWidthFixHeight(
                    minWidth: MediaQuery.sizeOf(context).width,
                    height: 50,
                    color: Theme.of(context).primaryColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(AppDimensions.radiusHalfSmall))),
                    child: Text(
                      'sign_up_ucf'.tr(context: context),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: _isAgree!
                        ? () {
                            onPressSignUp();
                          }
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.paddingLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                      'already_have_an_account'.tr(context: context),
                      style: const TextStyle(
                          color: MyTheme.font_grey, fontSize: 12),
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: Text(
                        'log_in'.tr(context: context),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const Login();
                        }));
                      },
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

class _SignUpField extends StatelessWidget {
  const _SignUpField({
    this.isRequired = true,
    this.obscureText = false,
    this.fieldController,
    this.customWidget,
    this.keyboardType,
    required this.label,
    this.hint,
    this.otherWidgets = const [],
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController? fieldController;
  final bool isRequired;
  final bool obscureText;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final Widget? customWidget;
  final TextInputAction textInputAction;
  final List<Widget> otherWidgets;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppDimensions.paddingSmallExtra,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "$label${isRequired ? ' *' : ''}",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 36,
          child: customWidget ??
              TextField(
                controller: fieldController,
                autofocus: false,
                obscureText: obscureText,
                textInputAction: textInputAction,
                keyboardType: keyboardType,
                decoration: InputDecorations.buildInputDecoration_1(
                  hint_text: hint ?? label,
                ),
              ),
        ),
        ...otherWidgets,
        const SizedBox(height: AppDimensions.paddingSmallExtra),
      ],
    );
  }
}
