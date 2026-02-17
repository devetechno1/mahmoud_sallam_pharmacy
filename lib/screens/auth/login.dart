import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/intl_phone_input.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/auth_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/other_config.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/password_forget.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/registration.dart';
import 'package:active_ecommerce_cms_demo_app/screens/main.dart';
import 'package:active_ecommerce_cms_demo_app/status/execute_and_handle_remote_errors.dart';
// import 'package:active_ecommerce_cms_demo_app/social_config.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/auth_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:twitter_login/twitter_login.dart';

import '../../custom/loading.dart';
import '../../data_model/login_response.dart';
import '../../data_model/otp_provider_model.dart';
import '../../presenter/home_provider.dart';
import '../../repositories/address_repository.dart';
import '../../status/status.dart';
import 'otp.dart';
import 'otp_login.dart';

class Login extends StatefulWidget {
  final String? token;

  const Login({super.key, this.token});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _login_by = otp_addon_installed.$ ? "phone" : "email"; //phone or email

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  List<String?> countries_code = <String?>[];

  String? _phone = "";

  //controllers
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final homeP = context.read<HomeProvider>();

  bool showLoginFields = AppConfig.showFullLoginFields;
  final Duration duration = const Duration(milliseconds: 300);

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => loginWithToken(),
    );
  }

  fetch_country() async {
    final data = await AddressRepository().getCountryList();
    data.countries?.forEach((c) => countries_code.add(c.code));
    setState(() {});
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  Future<void> loginWithToken() async {
    if (widget.token == null) return;

    final String token = Uri.decodeComponent(widget.token!);

    access_token.$ = token;

    Loading.show(context);
    await access_token.save();

    final Status<LoginResponse> loginStatus = await executeAndHandleErrors(
      () => AuthRepository().getUserByTokenResponse(),
    );
    if (loginStatus is Success<LoginResponse> &&
        loginStatus.data.result == true) {
      final loginResponse = loginStatus.data;

      print("in the success block ");

      await AuthHelper().setUserData(loginResponse);

      await Future.wait([
        // push notification starts
        saveFCMToken(),
        homeP.fetchAddressLists(false, false),
      ]);

      Loading.close();
      ToastComponent.showDialog(loginResponse.message!);

      final bool needHandleAddress = homeP.needHandleAddressNavigation();
      if (needHandleAddress) return;

      // redirect
      if (loginResponse.user!.emailVerified!) {
        context.push("/");
      } else {
        goOTPOrHome(loginResponse);
      }
    } else {
      AuthHelper().clearUserData();
      Loading.close();

      String error = "an_error_occurred".tr(context: context);

      if (loginStatus.data?.message.runtimeType == List) {
        error = loginStatus.data!.message!.join("\n");
      } else if (loginStatus.data?.message != null) {
        error = loginStatus.data!.message.toString();
      }
      ToastComponent.showDialog(error, isError: true);
    }
    await Future.delayed(Duration.zero);
  }

  void goOTPOrHome(LoginResponse loginResponse) {
    final isPhone =
        AppConfig.businessSettingsData.mustOtp && _login_by == "phone";
    if ((AppConfig.businessSettingsData.mailVerificationStatus &&
            _login_by == "email") ||
        isPhone) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Otp(
            fromRegistration: false,
            isPhone: isPhone,
            emailOrPhone:
                isPhone ? loginResponse.user?.phone : loginResponse.user?.email,
            provider: AppConfig.businessSettingsData.otpProviders.firstOrNull,
          ),
        ),
      );
    } else {
      context.push("/");
    }
  }

  Future<void> onPressedLogin(ctx) async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.toString();
    final password = _passwordController.text.toString();

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog(
        "enter_email".tr(context: context),
        isError: true,
      );
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
        "enter_phone_number".tr(context: context),
        isError: true,
      );
      return;
    } else if (password == "") {
      ToastComponent.showDialog(
        "enter_password".tr(context: context),
        isError: true,
      );
      return;
    }
    Loading.show(context);

    final loginResponse = await AuthRepository().getLoginResponse(
        _login_by == 'email' ? email : _phone, password, _login_by);

    // // empty temp user id after logged in
    // temp_user_id.$ = "";
    // temp_user_id.save();

    if (loginResponse.result == false) {
      Loading.close();

      if (loginResponse.message.runtimeType == List) {
        ToastComponent.showDialog(
          loginResponse.message!.join("\n"),
          isError: true,
        );
        return;
      }
      ToastComponent.showDialog(
        loginResponse.message!.toString(),
        isError: true,
      );
    } else {
      print("in the success block ");

      await AuthHelper().setUserData(loginResponse);

      await Future.wait([
        // push notification starts
        saveFCMToken(),
        homeP.fetchAddressLists(false, false),
      ]);

      Loading.close();
      ToastComponent.showDialog(loginResponse.message!);

      final bool needHandleAddress = homeP.needHandleAddressNavigation();
      if (needHandleAddress) return;

      // redirect
      if (loginResponse.user!.emailVerified!) {
        context.push("/");
      } else {
        goOTPOrHome(loginResponse);
      }
    }
  }

  Future<void> onPressedFacebookLogin() async {
    try {
      final facebookLogin = await FacebookAuth.instance
          .login(loginBehavior: LoginBehavior.webOnly);

      if (facebookLogin.status == LoginStatus.success) {
        // get the user data
        // by default we get the userId, email,name and picture
        final userData = await FacebookAuth.instance.getUserData();
        final loginResponse = await AuthRepository().getSocialLoginResponse(
            "facebook",
            userData['name'].toString(),
            userData['email'].toString(),
            userData['id'].toString(),
            access_token: facebookLogin.accessToken!.tokenString);
        // print("..........................${loginResponse.toString()}");
        if (loginResponse.result == false) {
          ToastComponent.showDialog(
            loginResponse.message!,
          );
        } else {
          ToastComponent.showDialog(
            loginResponse.message!,
          );

          await AuthHelper().setUserData(loginResponse);
          await Future.wait([
            // push notification starts
            saveFCMToken(),
            homeP.fetchAddressLists(false),
          ]);

          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const Main();
          }));
          FacebookAuth.instance.logOut();
        }
        // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      } else {
        print("....Facebook auth Failed.........");
        // print(facebookLogin.status);
        // print(facebookLogin.message);
      }
    } on Exception catch (e) {
      print(e);
      // TODO
    }
  }

  Future<void> onPressedGoogleLogin() async {
    try {
      final GoogleSignInAccount googleUser = (await GoogleSignIn().signIn())!;

      print(googleUser.toString());

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;
      final String? accessToken = googleSignInAuthentication.accessToken;

      // print("displayName ${googleUser.displayName}");
      // print("email ${googleUser.email}");
      // print("googleUser.id ${googleUser.id}");

      final loginResponse = await AuthRepository().getSocialLoginResponse(
          "google", googleUser.displayName, googleUser.email, googleUser.id,
          access_token: accessToken);

      if (loginResponse.result == false) {
        ToastComponent.showDialog(
          loginResponse.message!,
        );
      } else {
        ToastComponent.showDialog(
          loginResponse.message!,
        );
        await AuthHelper().setUserData(loginResponse);
        await Future.wait([
          // push notification starts
          saveFCMToken(),
          homeP.fetchAddressLists(false),
        ]);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const Main();
        }));
      }
      GoogleSignIn().disconnect();
    } on Exception catch (e) {
      print("error is ....... $e");
      // TODO
    }
  }

  Future<void> onPressedOTPLogin({
    required String providerName,
    required String providerType,
  }) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OTPLoginScreen(
          providerName: providerName,
          providerType: providerType,
        ),
      ),
    );
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final loginResponse = await AuthRepository().getSocialLoginResponse(
          "apple",
          appleCredential.givenName,
          appleCredential.email,
          appleCredential.userIdentifier,
          access_token: appleCredential.identityToken);

      if (loginResponse.result == false) {
        ToastComponent.showDialog(
          loginResponse.message!,
        );
      } else {
        ToastComponent.showDialog(
          loginResponse.message!,
        );
        await AuthHelper().setUserData(loginResponse);
        await Future.wait([
          // push notification starts
          saveFCMToken(),
          homeP.fetchAddressLists(false),
        ]);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const Main();
        }));
      }
    } on Exception catch (e) {
      print(e);
      // TODO
    }

    // Create an `OAuthCredential` from the credential returned by Apple.
    // final oauthCredential = OAuthProvider("apple.com").credential(
    //   idToken: appleCredential.identityToken,
    //   rawNonce: rawNonce,
    // );
    //print(oauthCredential.accessToken);

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    //return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Widget build(BuildContext context) {
    final _screen_width = MediaQuery.sizeOf(context).width;
    final bool canPop = !(!AppConfig.showFullLoginFields && showLoginFields);
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!canPop) {
          showLoginFields = false;
          setState(() {});
        }
      },
      child: AuthScreen.buildScreen(
        context,
        "${"login_to".tr(context: context)} " + 'app_name'.tr(context: context),
        buildBody(context, _screen_width),
      ),
    );
  }

  Widget buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.maxFinite),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmallExtra),
                      child: Text(
                        _login_by == "email"
                            ? "email_ucf".tr(context: context)
                            : "login_screen_phone".tr(context: context),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_login_by == "email")
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 36,
                              child: TextField(
                                controller: _emailController,
                                textInputAction: TextInputAction.next,
                                autofocus: false,
                                decoration:
                                    InputDecorations.buildInputDecoration_1(
                                        hint_text: "user@example.com"),
                              ),
                            ),
                            otp_addon_installed.$
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _login_by = "phone";
                                      });
                                    },
                                    child: Text(
                                      'or_login_with_a_phone'
                                          .tr(context: context),
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                : emptyWidget
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 36,
                              child: CustomInternationalPhoneNumberInput(
                                keyboardAction: TextInputAction.next,
                                countries: countries_code,

                                hintText:
                                    'phone_number_ucf'.tr(context: context),
                                errorMessage:
                                    'invalid_phone_number'.tr(context: context),
                                initialValue: PhoneNumber(
                                    isoCode: AppConfig.default_country),
                                onInputChanged: (PhoneNumber number) {
                                  setState(() {
                                    if (number.isoCode != null)
                                      AppConfig.default_country =
                                          number.isoCode!;
                                    _phone = number.phoneNumber;
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
                                textStyle:
                                    const TextStyle(color: MyTheme.font_grey),
                                // initialValue: PhoneNumber(
                                //     isoCode: countries_code[0].toString()),
                                textFieldController: _phoneNumberController,
                                formatInput: true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        signed: true, decimal: true),
                                inputDecoration:
                                    InputDecorations.buildInputDecoration_phone(
                                        hint_text: "01XXX XXX XXX"),
                                onSaved: (PhoneNumber number) {
                                  print('On Saved: $number');
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _login_by = "email";
                                });
                              },
                              child: Text(
                                "or_login_with_an_email".tr(context: context),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmallExtra),
                      child: Text(
                        "password_ucf".tr(context: context),
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
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => onPressedLogin(context),
                              decoration:
                                  InputDecorations.buildInputDecoration_1(
                                      hint_text: "• • • • • • • •"),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return PasswordForget();
                              }));
                            },
                            child: Text(
                              'login_screen_forgot_password'
                                  .tr(context: context),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                crossFadeState: showLoginFields
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: duration,
              ),
              Container(
                height: 45,
                margin:
                    const EdgeInsets.only(top: AppDimensions.paddingExtraLarge),
                decoration: BoxDecoration(
                    border: Border.all(color: MyTheme.textfield_grey, width: 1),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(AppDimensions.radiusNormal))),
                child: Btn.minWidthFixHeight(
                  minWidth: MediaQuery.sizeOf(context).width,
                  height: 50,
                  color: Theme.of(context).primaryColor,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(AppDimensions.radiusHalfSmall))),
                  child: Text(
                    "login_screen_log_in".tr(context: context),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    if (!showLoginFields) {
                      showLoginFields = true;
                      setState(() {});
                      return;
                    }

                    onPressedLogin(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                child: Center(
                    child: Text(
                  'login_screen_or_create_new_account'.tr(context: context),
                  style:
                      const TextStyle(color: MyTheme.font_grey, fontSize: 12),
                )),
              ),
              SizedBox(
                height: 45,
                child: Btn.minWidthFixHeight(
                  minWidth: MediaQuery.sizeOf(context).width,
                  height: 50,
                  color: MyTheme.amber,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(AppDimensions.radiusHalfSmall))),
                  child: Text(
                    "login_screen_sign_up".tr(context: context),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Registration();
                    }));
                  },
                ),
              ),
              if (Platform.isIOS &&
                  AppConfig.businessSettingsData.allowAppleLogin)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.paddingLarge,
                  ),
                  child: SignInWithAppleButton(onPressed: signInWithApple),
                ),
              Visibility(
                visible: AppConfig.businessSettingsData.otherLogins,
                child: AnimatedPadding(
                  duration: duration,
                  padding: EdgeInsets.only(
                    top: showLoginFields
                        ? AppDimensions.paddingLarge
                        : AppDimensions.paddingVeryExtraLarge,
                  ),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: duration,
                      style: showLoginFields
                          ? const TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 14,
                            )
                          : const TextStyle(
                              color: MyTheme.dark_font_grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                      child: Text(
                        "login_screen_login_with".tr(context: context),
                      ),
                    ),
                  ),
                ),
              ),
              Builder(builder: (context) {
                final w = min(MediaQuery.sizeOf(context).width,
                    AppDimensions.phoneMaxWidth);

                final h = min(w, MediaQuery.sizeOf(context).height);
                final l = loginWith(context);
                return AnimatedScale(
                  duration: duration,
                  scale: showLoginFields ? 1.0 : 1.3,
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    child: AnimatedContainer(
                      duration: duration,
                      padding: const EdgeInsets.only(top: 15.0),
                      margin: showLoginFields
                          ? EdgeInsets.zero
                          : EdgeInsets.all(w * 0.1).copyWith(
                              top: 0,
                              bottom: l.length *
                                  h *
                                  (w < AppDimensions.phoneMaxWidth
                                      ? 0.03
                                      : 0.02),
                            ),
                      child: Wrap(
                        runAlignment: WrapAlignment.center,
                        alignment: WrapAlignment.spaceAround,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppDimensions.paddingDefault,
                        runSpacing: AppDimensions.paddingLarge,
                        children: l,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        )
      ],
    );
  }

  List<Widget> loginWith(BuildContext context) {
    return [
      if (AppConfig.businessSettingsData.allowGoogleLogin)
        LoginWith3rd(
          onTap: onPressedGoogleLogin,
          name: 'google_ucf'.tr(context: context),
          assetImage: AppImages.google,
        ),
      if (AppConfig.businessSettingsData.allowFacebookLogin)
        LoginWith3rd(
          onTap: onPressedFacebookLogin,
          name: 'facebook_ucf'.tr(context: context),
          assetImage: AppImages.facebook,
        ),
      // if (AppConfig.businessSettingsData.allowOTPLogin)
      //   LoginWith3rd(
      //     onTap: onPressedOTPLogin,
      //     name: "OTP",
      //     assetImage: AppImages.otp,
      //     imageColor: Theme.of(context).primaryColor,
      //   ),
      if (AppConfig.businessSettingsData.allowOTPLogin)
        ...List.generate(
          AppConfig.businessSettingsData.otpProviders.length,
          (i) {
            final OTPProviderModel otpProvider =
                AppConfig.businessSettingsData.otpProviders[i];

            final String providerName = otpProvider.sendOTPText ?? "OTP";
            return LoginWith3rd(
              onTap: () => onPressedOTPLogin(
                providerName: providerName,
                providerType: otpProvider.type,
              ),
              name: providerName,
              networkImage: otpProvider.image,
              assetImage: AppImages.otp,
            );
          },
        ),
    ];
  }
}

class LoginWith3rd extends StatelessWidget {
  const LoginWith3rd({
    super.key,
    required this.name,
    required this.assetImage,
    this.networkImage,
    this.imageColor,
    this.isSelected = false,
    this.onTap,
  });
  final String name;
  final String assetImage;
  final String? networkImage;
  final Color? imageColor;
  final bool isSelected;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final Image assetImageWidget = Image.asset(assetImage, color: imageColor);
    return Tooltip(
      message: name,
      margin: const EdgeInsets.all(AppDimensions.paddingDefault),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
          horizontal: AppDimensions.paddingSmallExtra,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall))
            : null,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          child: Column(
            spacing: AppDimensions.paddingSmall,
            children: [
              SizedBox.square(
                dimension: 46,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSmall),
                  child: networkImage != null
                      ? CachedNetworkImage(
                          imageUrl: networkImage!,
                          color: imageColor,
                          errorWidget: (context, url, error) =>
                              assetImageWidget,
                        )
                      : assetImageWidget,
                ),
              ),
              Text(
                name,
                style: isSelected
                    ? TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> saveFCMToken() async {
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

    if (Platform.isIOS) {
      String? apnsToken = await _fcm.getAPNSToken();
      if (apnsToken == null) {
        await Future.delayed(const Duration(seconds: 3));
        apnsToken = await _fcm.getAPNSToken();
      }
      if (apnsToken == null) {
        await Future.delayed(const Duration(seconds: 3));
        apnsToken = await _fcm.getAPNSToken();
      }
    }

    String? fcmToken;
    try {
      fcmToken = await _fcm.getToken();
    } catch (e) {
      print("Error getting FCM token: $e");
    }

    print("--fcm token-- login");
    print("fcmToken $fcmToken");
    // update device token
    if (fcmToken != null && is_logged_in.$) {
      await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
    }
  }
}
