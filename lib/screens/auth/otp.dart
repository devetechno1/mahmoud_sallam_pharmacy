import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/num_ex.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../data_model/otp_provider_model.dart';

import '../../presenter/home_provider.dart';
import '../../ui_elements/otp_input_widget.dart';
import '../../ui_elements/select_otp_provider_widget.dart';
import 'custom_otp.dart';

class Otp extends StatefulWidget {
  final String? title;
  final bool fromRegistration;
  final bool isPhone;
  final String? emailOrPhone;
  final OTPProviderModel? provider;
  const Otp({
    Key? key,
    this.title,
    required this.fromRegistration,
    required this.emailOrPhone,
    required this.provider,
    required this.isPhone,
  }) : super(key: key);

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  //controllers
  String _code = '';
  final OtpInputController otpCtrl = OtpInputController();

  OTPProviderModel? selectedProvider;

  CountdownController countdownController =
      CountdownController(autoStart: true);
  bool canResend = false;

  late final homeP = context.read<HomeProvider>();

  @override
  void initState() {
    selectedProvider = widget.provider;
    //on Splash Screen hide statusbar
    if (!widget.fromRegistration) {
      AuthRepository().getResendCodeResponse(selectedProvider?.type);
    }
    otpCtrl.listenOnceUserConsent();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    countdownController.pause();
    otpCtrl.dispose();
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onTapResend() async {
    otpCtrl.listenOnceUserConsent();
    setState(() {
      canResend = false;
    });
    final resendCodeResponse =
        await AuthRepository().getResendCodeResponse(selectedProvider?.type);

    if (resendCodeResponse.result != true) {
      ToastComponent.showDialog(
        resendCodeResponse.message!,
        isError: true,
      );
    } else {
      ToastComponent.showDialog(
        resendCodeResponse.message!,
      );
    }
  }

  Future<void> onPressConfirm() async {
    if (_code.trim() == "") {
      ToastComponent.showDialog(
        'enter_verification_code'.tr(context: context),
        isError: true,
      );
      return;
    }

    final confirmCodeResponse =
        await AuthRepository().getConfirmCodeResponse(_code);

    if (!(confirmCodeResponse.result)) {
      ToastComponent.showDialog(
        confirmCodeResponse.message,
        isError: true,
      );
    } else {
      if (SystemConfig.systemUser != null) {
        SystemConfig.systemUser!.emailVerified = true;
      }
      await homeP.fetchAddressLists(false, false);
      final bool needHandleAddress = homeP.needHandleAddressNavigation();
      if (needHandleAddress) return;
      if (widget.fromRegistration) {
        goHome(context);
      } else {
        context.pop();
      }

      ToastComponent.showDialog(confirmCodeResponse.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double _screen_width = MediaQuery.sizeOf(context).width;
    final double _screen_height = MediaQuery.sizeOf(context).height;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.title != null)
                Text(
                  widget.title!,
                  style:
                      const TextStyle(fontSize: 25, color: MyTheme.font_grey),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 15),
                child: Container(
                  width: 75,
                  height: 75,
                  child: Image.asset(AppImages.loginRegistration),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  width: _screen_width * (3 / 4),
                  child: Text(
                    'check_your_messages_to_retrieve_the_verification_code'.tr(
                      context: context,
                      args: {
                        "phone": "${widget.emailOrPhone ?? ''}",
                      },
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: MyTheme.dark_grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: _screen_width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall),
                      child: SizedBox(
                        height: 55,
                        child: OtpInputWidget(
                          controller: otpCtrl,
                          isDigitOnly: widget.isPhone,
                          onChanged: (val) => _code = val,
                          onCompleted: (val) {
                            _code = val;
                            onPressConfirm();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: _screen_height * 0.1),
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
                          onPressed: onPressConfirm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              if (widget.isPhone)
                SelectOTPProviderWidget(
                  margin: const EdgeInsets.only(
                    bottom: AppDimensions.paddingExtraLarge,
                  ),
                  selectedProvider: selectedProvider,
                  onSelect: (val) => setState(() => selectedProvider = val),
                ),
              Padding(
                padding:
                    const EdgeInsets.only(top: AppDimensions.paddingDefault),
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
                  top: AppDimensions.paddingVeryExtraLarge,
                  bottom: 60,
                ),
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
              // SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.only(
                    top: AppDimensions.paddingVeryExtraLarge),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      onTapLogout(context);
                    },
                    child: Text('logout_ucf'.tr(context: context),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                            fontSize: 13)),
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  onTapLogout(context) {
    try {
      AuthHelper().clearUserData(); // Ensure this clears user data properly
      goHome(context);
    } catch (e) {
      print('Error navigating to Main: $e');
    }
  }
}

class TimerWidget extends StatelessWidget {
  const TimerWidget({
    required this.duration,
    required this.callback,
    required this.controller,
  });
  final CountdownController? controller;

  final Duration duration;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 2, left: 12, right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
      ),
      child: Countdown(
        controller: controller,
        seconds: duration.inSeconds,
        onFinished: callback,
        build: (BuildContext context, double seconds) =>
            Text(seconds.fromSeconds ?? ''),
      ),
    );
  }
}
