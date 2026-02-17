import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/otp.dart';
import 'package:active_ecommerce_cms_demo_app/screens/index.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../../custom/loading.dart';
import '../../data_model/login_response.dart';
import '../../helpers/auth_helper.dart';
import '../../presenter/home_provider.dart';
import '../../status/execute_and_handle_remote_errors.dart';
import '../../status/status.dart';
import '../../ui_elements/otp_input_widget.dart';

import 'login.dart';
import 'otp_login.dart';

class CustomOTPScreen extends StatefulWidget {
  const CustomOTPScreen({
    Key? key,
    required this.phone,
    required this.provider,
  }) : super(key: key);
  final PhoneNumber phone;
  final String provider;

  @override
  _CustomOTPScreenState createState() => _CustomOTPScreenState();
}

class _CustomOTPScreenState extends State<CustomOTPScreen> {
  //controllers
  String _code = '';

  final OtpInputController otpCtrl = OtpInputController();

  CountdownController countdownController =
      CountdownController(autoStart: true);
  bool canResend = false;

  @override
  void initState() {
    otpCtrl.listenOnceUserConsent();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    otpCtrl.dispose();
    countdownController.pause();
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  Future<void> onPressConfirm() async {
    FocusScope.of(context).unfocus();

    if (_code.trim().isEmpty) {
      ToastComponent.showDialog(
        'enter_the_code'.tr(context: context),
      );
      return;
    }

    Loading.show(context);
    final Status<LoginResponse> status = await executeAndHandleErrors(
      () => AuthRepository().verifyOTPLoginResponse(
        countryCode: widget.phone.dialCode ?? '',
        phone: widget.phone.parseNumber(),
        otpCode: _code,
      ),
    );

    if (status is Failure<LoginResponse>) {
      Loading.close();
      return onError(status.failure.message);
    }

    final LoginResponse response = (status as Success<LoginResponse>).data;

    if (response.result == false) {
      Loading.close();
      return onError(response.message);
    }

    await AuthHelper().setUserData(response);

    final homeP = context.read<HomeProvider>();

    await Future.wait([
      saveFCMToken(),
      homeP.fetchAddressLists(true, false),
    ]);

    Loading.close();

    final bool needHandleAddress = homeP.needHandleAddressNavigation();
    if (needHandleAddress) return;

    goHome(context);
    await Future.delayed(Duration.zero);

    ToastComponent.showDialog(response.message!);
  }

  Future<void> onTapResend() async {
    otpCtrl.listenOnceUserConsent();

    setState(() {
      canResend = false;
    });
    await sendOTPLoginCode(context, widget.phone, widget.provider);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return AuthScreen.buildScreen(
      context,
      'enter_the_code_sent'.tr(context: context),
      buildBody(context, screenWidth),
    );
  }

  Widget buildBody(BuildContext context, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
          child: SizedBox(
            width: screenWidth * (3 / 4),
            child: Text(
              'check_your_messages_to_retrieve_the_verification_code'.tr(
                context: context,
                args: {"phone": "${widget.phone.phoneNumber}"},
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MyTheme.dark_grey,
                fontSize: 14,
              ),
            ),
          ),
        ),
        Container(
          width: screenWidth * (3 / 4),
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
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: SizedBox(
                  height: 55,
                  child: OtpInputWidget(
                    controller: otpCtrl,
                    isDigitOnly: true,
                    onChanged: (val) => _code = val,
                    onCompleted: (val) {
                      _code = val;
                      onPressConfirm();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: AppDimensions.paddingVeryExtraLarge),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: MyTheme.textfield_grey),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppDimensions.radiusNormal),
                    ),
                  ),
                  child: Btn.basic(
                    minWidth: MediaQuery.sizeOf(context).width,
                    color: Theme.of(context).primaryColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.radiusNormal),
                      ),
                    ),
                    child: Text(
                      'confirm_ucf'.tr(context: context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: onPressConfirm,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50),
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
    );
  }
}

void goHome(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const Index()),
    (route) => false,
  ).then(
    (value) {
      final BuildContext? _context = OneContext().context;
      if (_context == null) return;
      final String x = GoRouter.of(_context).state.fullPath.toString();
      if (x != "/") _context.go("/");
    },
  );
}
