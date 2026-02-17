import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/otp.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:one_context/one_context.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../../data_model/otp_provider_model.dart';
import '../../ui_elements/otp_input_widget.dart';
import '../../ui_elements/select_otp_provider_widget.dart';

class PasswordOtp extends StatefulWidget {
  const PasswordOtp({
    Key? key,
    this.verify_by = "email",
    this.email_or_code,
    this.provider,
  }) : super(key: key);
  final String verify_by;
  final String? email_or_code;
  final OTPProviderModel? provider;

  @override
  _PasswordOtpState createState() => _PasswordOtpState();
}

class _PasswordOtpState extends State<PasswordOtp> {
  //controllers
  String _code = '';
  final OtpInputController otpCtrl = OtpInputController();
  OTPProviderModel? selectedProvider;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  CountdownController countdownController =
      CountdownController(autoStart: true);
  bool canResend = false;

  String headeText = "";

  FlipCardController cardController = FlipCardController();

  @override
  void initState() {
    selectedProvider = widget.provider;
    otpCtrl.listenOnceUserConsent();
    Future.delayed(Duration.zero).then((value) {
      headeText = 'enter_the_code_sent'.tr(context: context);
      setState(() {});
    });
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    otpCtrl.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    countdownController.pause();
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  Future<void> onPressConfirm() async {
    // final code = _codeController.text.toString();
    final password = _passwordController.text.toString();
    final passwordConfirm = _passwordConfirmController.text.toString();

    if (_code.trim().isEmpty) {
      ToastComponent.showDialog(
        'enter_the_code'.tr(context: context),
      );
      return;
    } else if (password == "") {
      ToastComponent.showDialog(
        'enter_password'.tr(context: context),
      );
      return;
    } else if (passwordConfirm == "") {
      ToastComponent.showDialog(
        'confirm_your_password'.tr(context: context),
      );
      return;
    } else if (password.length < 6) {
      ToastComponent.showDialog(
        'password_must_contain_at_least_6_characters'.tr(context: context),
      );
      return;
    } else if (password != passwordConfirm) {
      ToastComponent.showDialog(
        'passwords_do_not_match'.tr(context: context),
      );
      return;
    }

    final passwordConfirmResponse =
        await AuthRepository().getPasswordConfirmResponse(_code, password);

    if (passwordConfirmResponse.result == false) {
      ToastComponent.showDialog(
        passwordConfirmResponse.message!,
        isError: true,
      );
    } else {
      ToastComponent.showDialog(
        passwordConfirmResponse.message!,
      );

      headeText = 'password_changed_ucf'.tr(context: context);
      cardController.toggleCard();
      setState(() {});
    }
  }

  onTapResend() async {
    otpCtrl.listenOnceUserConsent();
    setState(() {
      canResend = false;
    });
    final passwordResendCodeResponse =
        await AuthRepository().getPasswordForgetResponse(
      widget.email_or_code,
      widget.verify_by,
      selectedProvider?.type,
    );

    if (passwordResendCodeResponse.result != true) {
      ToastComponent.showDialog(
        passwordResendCodeResponse.message!,
        isError: true,
      );
    } else {
      ToastComponent.showDialog(
        passwordResendCodeResponse.message!,
      );
    }
  }

  gotoLoginScreen() {
    Navigator.pop(context);
    Navigator.pop(OneContext().context!);
  }

  @override
  Widget build(BuildContext context) {
    final String _verify_by = widget.verify_by; //phone or email
    final _screen_width = MediaQuery.sizeOf(context).width;
    return AuthScreen.buildScreen(
        context,
        headeText,
        WillPopScope(
            onWillPop: () {
              gotoLoginScreen();
              return Future.value(false);
            },
            child: buildBody(context, _screen_width, _verify_by)));
  }

  Widget buildBody(
      BuildContext context, double _screen_width, String _verify_by) {
    return FlipCard(
      flipOnTouch: false,
      controller: cardController,
      //fill: Fill.fillBack, // Fill the back side of the card to make in the same size as the front.
      direction: FlipDirection.HORIZONTAL,
      // default
      front: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
              child: Container(
                  width: _screen_width * (3 / 4),
                  child: _verify_by == "email"
                      ? Text(
                          'enter_the_verification_code_that_sent_to_your_email_recently'
                              .tr(context: context),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: MyTheme.dark_grey, fontSize: 14))
                      : Text(
                          'check_your_messages_to_retrieve_the_verification_code'
                              .tr(
                            context: context,
                            args: {"phone": "${widget.email_or_code}"},
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: MyTheme.dark_grey, fontSize: 14))),
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
                      'code'.tr(context: context),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingSmall,
                    ),
                    child: SizedBox(
                      height: 55,
                      child: OtpInputWidget(
                        controller: otpCtrl,
                        isDigitOnly: widget.verify_by != "email",
                        onChanged: (val) => _code = val,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmallExtra),
                    child: Text(
                      'password_ucf'.tr(context: context),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 36,
                          child: TextField(
                            controller: _passwordController,
                            autofocus: false,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: InputDecorations.buildInputDecoration_1(
                                hint_text: "• • • • • • • •"),
                          ),
                        ),
                        Text(
                          'password_must_contain_at_least_6_characters'
                              .tr(context: context),
                          style: const TextStyle(
                              color: MyTheme.textfield_grey,
                              fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmallExtra),
                    child: Text(
                      'retype_password_ucf'.tr(context: context),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Container(
                      height: 36,
                      child: TextField(
                        controller: _passwordConfirmController,
                        autofocus: false,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecorations.buildInputDecoration_1(
                            hint_text: "• • • • • • • •"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppDimensions.paddingVeryExtraLarge),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: MyTheme.textfield_grey, width: 1),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(AppDimensions.radiusNormal))),
                      child: Btn.basic(
                        minWidth: MediaQuery.sizeOf(context).width,
                        color: Theme.of(context).primaryColor,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(AppDimensions.radiusNormal))),
                        child: Text(
                          'confirm_ucf'.tr(context: context),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          onPressConfirm();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            if (_verify_by != 'email')
              SelectOTPProviderWidget(
                margin: const EdgeInsets.only(
                  bottom: AppDimensions.paddingExtraLarge,
                ),
                selectedProvider: selectedProvider,
                onSelect: (val) => setState(() => selectedProvider = val),
              ),
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingDefault),
              child: InkWell(
                onTap: canResend ? onTapResend : null,
                child: Text('resend_code_ucf'.tr(context: context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: canResend
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                        decoration: TextDecoration.underline,
                        fontSize: 13)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: AppDimensions.paddingVeryExtraLarge, bottom: 60),
              child: Visibility(
                visible: !canResend,
                child: TimerWidget(
                  duration: const Duration(seconds: 90),
                  callback: () {
                    setState(() {
                      countdownController.restart();
                      canResend = true;
                    });
                  },
                  controller: countdownController,
                ),
              ),
            ),
          ],
        ),
      ),
      back: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
              child: Container(
                  width: _screen_width * (3 / 4),
                  child: Text('congratulations_ucf'.tr(context: context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
              child: Container(
                  width: _screen_width * (3 / 4),
                  child: Text(
                      'you_have_successfully_changed_your_password'
                          .tr(context: context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                      ))),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingLarge),
              child: Image.asset(
                AppImages.changedPassword,
                width: DeviceInfo(context).width! / 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: AppDimensions.paddingVeryExtraLarge),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 45,
                child: Btn.basic(
                  minWidth: MediaQuery.sizeOf(context).width,
                  color: Theme.of(context).primaryColor,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(AppDimensions.radiusHalfSmall))),
                  child: Text(
                    'back_to_Login_ucf'.tr(context: context),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    gotoLoginScreen();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
