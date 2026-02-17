import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';

import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';

import 'package:active_ecommerce_cms_demo_app/helpers/file_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/profile_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../app_config.dart';
import '../custom/intl_phone_input.dart';
import '../repositories/address_repository.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final ScrollController _mainScrollController = ScrollController();
  final TextEditingController _nameController =
      TextEditingController(text: "${user_name.$}");
  final TextEditingController _phoneController =
      TextEditingController(text: "${user_phone.$}");
  final TextEditingController _emailController =
      TextEditingController(text: "${user_email.$}");
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String _phone = "";
  List<String?> countries_code = <String?>[];
  PhoneNumber initialValue = PhoneNumber(isoCode: AppConfig.default_country);
  bool _isValidPhoneNumber = false;

  //for image uploading
  final ImagePicker _picker = ImagePicker();
  XFile? _file;

  Future<void> chooseAndUploadImage(context) async {
    await Permission.camera.request();
    // var status = await Permission.photos.request();
    //
    // if (status.isDenied) {
    //   // We didn't ask for permission yet.
    //   showDialog(
    //       context: context,
    //       builder: (BuildContext context) => CupertinoAlertDialog(
    //             title: Text('photo_permission_ucf'.tr(context: context)),
    //             content: Text(
    //                 'this_app_needs_permission'.tr(context: context)),
    //             actions: <Widget>[
    //               CupertinoDialogAction(
    //                 child: Text('deny_ucf'.tr(context: context)),
    //                 onPressed: () => Navigator.pop(context),
    //               ),
    //               CupertinoDialogAction(
    //                 child: Text('settings_ucf'.tr(context: context)),
    //                 onPressed: () => openAppSettings(),
    //               ),
    //             ],
    //           ));
    // } else if (status.isRestricted) {
    //   ToastComponent.showDialog(
    //       'go_to_your_application_settings_and_give_photo_permission'.tr(context: context),
    //       gravity: Toast.center,
    //       duration: Toast.lengthLong);
    // } else if (status.isGranted) {}

    //file = await ImagePicker.pickImage(source: ImageSource.camera);
    _file = await _picker.pickImage(source: ImageSource.gallery);

    if (_file == null) {
      ToastComponent.showDialog(
        'no_file_is_chosen'.tr(context: context),
      );
      return;
    }

    //return;
    final String base64Image = FileHelper.getBase64FormateFile(_file!.path);
    final String fileName = _file!.path.split("/").last;

    final profileImageUpdateResponse =
        await ProfileRepository().getProfileImageUpdateResponse(
      base64Image,
      fileName,
    );

    if (profileImageUpdateResponse.result == false) {
      ToastComponent.showDialog(
        profileImageUpdateResponse.message,
      );
      return;
    } else {
      ToastComponent.showDialog(
        profileImageUpdateResponse.message,
      );

      avatar_original.$ = profileImageUpdateResponse.path;
      setState(() {});
    }
  }

  Future<void> _onPageRefresh() async {}

  Future<void> onPressUpdate() async {
    final name = _nameController.text.toString();

    if (name == "") {
      ToastComponent.showDialog(
        'enter_your_name'.tr(context: context),
      );
      return;
    }
    if (_phone.trim().isEmpty) {
      ToastComponent.showDialog('enter_phone_number'.tr(context: context),
          color: Theme.of(context).colorScheme.error);
      return;
    } else if (!_isValidPhoneNumber) {
      ToastComponent.showDialog('invalid_phone_number'.tr(context: context),
          color: Theme.of(context).colorScheme.error);
      return;
    }

    final postBody = jsonEncode({"name": "$name", "phone": _phone.trim()});

    final profileUpdateResponse =
        await ProfileRepository().getProfileUpdateResponse(post_body: postBody);

    if (profileUpdateResponse.result == false) {
      ToastComponent.showDialog(profileUpdateResponse.message,
          color: Theme.of(context).colorScheme.error);
    } else {
      ToastComponent.showDialog(profileUpdateResponse.message,
          color: Colors.green);

      user_name.$ = name;
      user_phone.$ = _phone;
      setState(() {});
    }
  }

  Future<void> onPressUpdatePassword() async {
    final password = _passwordController.text.toString();
    final passwordConfirm = _passwordConfirmController.text.toString();

    final changePassword = password != "" ||
        passwordConfirm !=
            ""; // if both fields are empty we will not change user's password

    if (!changePassword && password == "") {
      ToastComponent.showDialog(
        'enter_password'.tr(context: context),
      );
      return;
    }
    if (!changePassword && passwordConfirm == "") {
      ToastComponent.showDialog(
        'confirm_your_password'.tr(context: context),
      );
      return;
    }
    if (changePassword && password.length < 6) {
      ToastComponent.showDialog(
        'password_must_contain_at_least_6_characters'.tr(context: context),
      );
      return;
    }
    if (changePassword && password != passwordConfirm) {
      ToastComponent.showDialog(
        'passwords_do_not_match'.tr(context: context),
      );
      return;
    }

    final postBody = jsonEncode({"password": "$password"});

    final profileUpdateResponse =
        await ProfileRepository().getProfileUpdateResponse(
      post_body: postBody,
    );

    if (profileUpdateResponse.result == false) {
      ToastComponent.showDialog(
        profileUpdateResponse.message,
      );
    } else {
      ToastComponent.showDialog(
        profileUpdateResponse.message,
      );
      setState(() {});
    }
  }

  Future<void> fetch_country() async {
    final data = await AddressRepository().getCountryList();
    data.countries?.forEach((c) => countries_code.add(c.code));
    setState(() {});
  }

  Future<void> getInitVal() async {
    _phone = user_phone.$.trim();
    initialValue = await PhoneNumber.getRegionInfoFromPhoneNumber(_phone);
    _phoneController.text = initialValue.parseNumber().replaceAll("+", '');
    _isValidPhoneNumber = _phoneController.text.isNotEmpty;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetch_country();
    getInitVal();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();

    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        body: buildBody(context),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
              app_language_rtl.$!
                  ? CupertinoIcons.arrow_right
                  : CupertinoIcons.arrow_left,
              color: MyTheme.dark_grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'edit_profile_ucf'.tr(context: context),
        style: const TextStyle(
            fontSize: 16,
            color: Color(0xff3E4447),
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget buildBody(context) {
    if (is_logged_in.$ == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            'please_log_in_to_see_the_profile'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        onRefresh: _onPageRefresh,
        displacement: 10,
        child: CustomScrollView(
          controller: _mainScrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                buildTopSection(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
                buildProfileForm(context)
              ]),
            )
          ],
        ),
      );
    }
  }

  Column buildTopSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0.0, bottom: 8.0),
          child: Stack(
            children: [
              // UsefulElements.roundImageWithPlaceholder(
              //     url: avatar_original.$,
              //     height: 80.0,
              //     width: 80.0,
              //     borderRadius: BorderRadius.circular(AppDimensions.radiusVeryEtraLarge),
              //     elevation: 8.0),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  boxShadow: [MyTheme.commonShadow()],
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusVeryExtra),

                  //shape: BoxShape.rectangle,
                ),
                child: ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(AppDimensions.radiusVeryExtra)),
                    child: FadeInImage.assetNetwork(
                      placeholder: AppImages.placeholder,
                      image: "${avatar_original.$}",
                      fit: BoxFit.fill,
                    )),
              ),
              // Positioned(
              //   right: 2,
              //   bottom: 0,
              //   child: SizedBox(
              //     width: 24,
              //     height: 24,
              //     child: Btn.basic(
              //       padding: EdgeInsets.all(0),
              //       child: Icon(
              //         Icons.edit,
              //         color: Color(0xff3E4447),
              //         size: 14,
              //       ),
              //       shape: CircleBorder(
              //         side:
              //             new BorderSide(color: MyTheme.light_grey, width: 1.0),
              //       ),
              //       color: Color(0xffDBDFE2),
              //       onPressed: () {
              //         chooseAndUploadImage(context);
              //       },
              //     ),
              //   ),
              // )
              Positioned(
                right: 2,
                bottom: 0,
                child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      boxShadow: [MyTheme.commonShadow()],
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusVeryExtra),

                      //shape: BoxShape.rectangle,
                    ),
                    child: Btn.basic(
                      // padding: const EdgeInsets.all(0),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xff3E4447),
                        size: 14,
                      ),
                      shape: const CircleBorder(),
                      color: const Color(0xffDBDFE2),
                      onPressed: () {
                        chooseAndUploadImage(context);
                      },
                    )),
              )
            ],
          ),
        ),
      ],
    );
  }

  Padding buildProfileForm(context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AppDimensions.paddingSmall,
          bottom: AppDimensions.paddingSmall,
          left: AppDimensions.paddingDefault,
          right: AppDimensions.paddingDefault),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBasicInfo(context),
            buildChangePassword(context),
          ],
        ),
      ),
    );
  }

  Column buildChangePassword(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingLarge,
              bottom: AppDimensions.paddingSupSmall),
          child: Center(
            child: Text(
              'password_changes_ucf'.tr(context: context),
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 16,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textHeightBehavior:
                  const TextHeightBehavior(applyHeightToFirstAscent: false),
              textAlign: TextAlign.center,
              softWrap: false,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingSupSmall),
          child: Text(
            'new_password_ucf'.tr(context: context),
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xff3E4447),
                fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecorations.buildBoxDecoration_with_shadow(),
                height: 36,
                child: TextField(
                  style: const TextStyle(fontSize: 12),
                  controller: _passwordController,
                  autofocus: false,
                  obscureText: !_showPassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecorations.buildInputDecoration_1(
                          hint_text: "• • • • • • • •")
                      .copyWith(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        _showPassword = !_showPassword;
                        setState(() {});
                      },
                      child: Icon(
                        _showPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: AppDimensions.paddingSmallExtra),
                child: Text(
                  'password_must_contain_at_least_6_characters'
                      .tr(context: context),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontStyle: FontStyle.italic),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingSupSmall),
          child: Text(
            'retype_password_ucf'.tr(context: context),
            style: const TextStyle(
                fontSize: 12,
                color: MyTheme.dark_font_grey,
                fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
          child: Container(
            decoration: BoxDecorations.buildBoxDecoration_with_shadow(),
            height: 36,
            child: TextField(
              controller: _passwordConfirmController,
              autofocus: false,
              obscureText: !_showConfirmPassword,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: "• • • • • • • •")
                  .copyWith(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          _showConfirmPassword = !_showConfirmPassword;
                          setState(() {});
                        },
                        child: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                      )),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              onPressUpdatePassword();
            },
            child: Container(
              alignment: Alignment.center,
              width: 129,
              height: 42,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSmall)),
              child: Text(
                textAlign: TextAlign.center,
                'save_changes'.tr(context: context),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column buildBasicInfo(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingNormal),
          child: Text(
            'basic_information_ucf'.tr(context: context),
            style: const TextStyle(
                color: Color(0xff6B7377),
                fontWeight: FontWeight.bold,
                fontSize: 14.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingSupSmall),
          child: Text(
            'name_ucf'.tr(context: context),
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xff3E4447),
                fontWeight: FontWeight.normal),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingNormal),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusHalfSmall),
                boxShadow: [MyTheme.commonShadow()]),
            height: 36,
            child: TextField(
              controller: _nameController,
              autofocus: false,
              style: const TextStyle(color: Color(0xff999999), fontSize: 12),
              decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: 'name_ucf'.tr(context: context))
                  .copyWith(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
        ),
        if (_phoneController.text.trim().isNotEmpty) ...[
          Padding(
            padding:
                const EdgeInsets.only(bottom: AppDimensions.paddingSupSmall),
            child: Text(
              'phone_ucf'.tr(context: context),
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xff3E4447),
                  fontWeight: FontWeight.normal),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingNormal),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusHalfSmall),
              boxShadow: [MyTheme.commonShadow()],
            ),
            height: 36,
            child: CustomInternationalPhoneNumberInput(
              countries: countries_code,
              readOnly: true,
              hintText: 'phone_number_ucf'.tr(context: context),
              errorMessage: 'invalid_phone_number'.tr(context: context),
              initialValue: initialValue,
              onInputChanged: (PhoneNumber number) {
                setState(() {
                  if (number.isoCode != null)
                    AppConfig.default_country = number.isoCode!;
                  _phone = number.phoneNumber ?? '';
                  print(_phone);
                });
              },
              onInputValidated: (bool value) {
                print(value);
                _isValidPhoneNumber = value;
                setState(() {});
              },
              selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: const TextStyle(color: MyTheme.font_grey),
              textStyle: const TextStyle(color: MyTheme.font_grey),
              textFieldController: _phoneController,
              formatInput: true,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              inputDecoration: InputDecorations.buildInputDecoration_phone(
                  hint_text: "01XXX XXX XXX"),
              onSaved: (PhoneNumber number) {
                print('On Saved: $number');
              },
            ),
          ),
        ],
        if (_emailController.text.trim().isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    bottom: AppDimensions.paddingSupSmall),
                child: Text(
                  'email_ucf'.tr(context: context),
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff3E4447),
                      fontWeight: FontWeight.normal),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingNormal),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusHalfSmall),
                        boxShadow: [MyTheme.commonShadow()]),
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _emailController.text,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xff999999)),
                    )
                    /*TextField(
                          style: TextStyle(color:MyTheme.grey_153,fontSize: 12),
                          enabled: false,
                          enableIMEPersonalizedLearning: true,
                          controller: _emailController,
                          autofocus: false,
                          decoration: InputDecorations.buildInputDecoration_1(
          
                              hint_text: "jhon@example.com").copyWith(
                            //enabled: false,
                        labelStyle: TextStyle(color: MyTheme.grey_153),
                        enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        ),
          
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
          
                        ),),
                        ),*/
                    ),
              ),
            ],
          ),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              onPressUpdate();
            },
            child: Container(
              alignment: Alignment.center,
              width: 129,
              height: 42,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSmall)),
              child: Text(
                textAlign: TextAlign.center,
                'update_profile_ucf'.tr(context: context),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
