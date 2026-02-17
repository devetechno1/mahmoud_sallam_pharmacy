import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';

import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/guest_checkout_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/auth/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../custom/aiz_route.dart';
import '../../custom/btn.dart';
import '../../custom/loading.dart';
import '../../custom/toast_component.dart';
import '../../data_model/city_response.dart';
import '../../data_model/country_response.dart';
import '../../data_model/state_response.dart';
import '../../my_theme.dart';
import '../../repositories/address_repository.dart';
import '../add_address_screen.dart';
import '../checkout/shipping_info.dart';

class GuestCheckoutAddress extends StatefulWidget {
  const GuestCheckoutAddress({Key? key}) : super(key: key);

  @override
  State<GuestCheckoutAddress> createState() => _GuestCheckoutAddressState();
}

class _GuestCheckoutAddressState extends State<GuestCheckoutAddress> {
  //controllers for add purpose
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  City? _selected_city;
  Country? _selected_country;
  MyState? _selected_state;

  void onSelectCountryDuringAdd(country) {
    if (_selected_country != null && country.id == _selected_country!.id) {
      setState(() {
        _countryController.text = country.name;
      });
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;
    setState(() {});

    setState(() {
      _countryController.text = country.name;
      _stateController.text = "";
      _cityController.text = "";
    });
  }

  void onSelectStateDuringAdd(state) {
    if (_selected_state != null && state.id == _selected_state!.id) {
      setState(() {
        _stateController.text = state.name;
      });
      return;
    }
    _selected_state = state;
    _selected_city = null;
    setState(() {});
    setState(() {
      _stateController.text = state.name;
      _cityController.text = "";
    });
  }

  void onSelectCityDuringAdd(city) {
    if (_selected_city != null && city.id == _selected_city!.id) {
      setState(() {
        _cityController.text = city.name;
      });
      return;
    }
    _selected_city = city;
    setState(() {
      _cityController.text = city.name;
    });
  }

  String? name, email, address, country, state, city, postalCode, phone;
  bool? emailValid;
  setValues() async {
    name = _nameController.text.trim();
    email = _emailController.text.trim();
    address = _addressController.text.trim();
    country = _selected_country!.id.toString();
    state = _selected_state!.id.toString();
    city = _selected_city!.id.toString();
    postalCode = _postalCodeController.text.trim();
    phone = _phoneController.text.trim();
  }

  Future<void> continueToDeliveryInfo() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!requiredFieldVerification()) {
      return;
    }
    Loading.show(context);
    await setValues();

    final Map postValue = {};
    postValue.addAll({
      "email": email,
      "phone": phone,
    });
    final postBody = jsonEncode(postValue);
    final response =
        await GuestCheckoutRepository().guestCustomerInfoCheck(postBody);

    Loading.close();

    // if email and phone matched return to page with massage
    if (response.result!) {
      ToastComponent.showDialog(
        'already_have_account'.tr(context: context),
      );
    } else if (!response.result!) {
      postValue.addAll({
        "name": name,
        "email": email,
        "address": address,
        "country_id": country,
        "state_id": state,
        "city_id": city,
        "postal_code": postalCode,
        "phone": phone,
        "longitude": null,
        "latitude": null,
        "temp_user_id": temp_user_id.$,
      });
      final postBody = jsonEncode(postValue);

      guestEmail.$ = email!;
      guestEmail.save();
      final bool isPhone = phone?.trim().isNotEmpty == true &&
          AppConfig.businessSettingsData.otpProviders.isNotEmpty;
      AIZRoute.push(
        context,
        ShippingInfo(
          // this is only for when guest checkout shipping address to calculate shipping cost
          guestCheckOutShippingAddress: postBody,
        ),
        isPhone ? phone! : email!,
        null,
        isPhone,
      );
    }
  }

  bool requiredFieldVerification() {
    emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text.trim());

    if (_nameController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(
        'name_required'.tr(context: context),
      );
      return false;
    } else if (_emailController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(
        'email_required'.tr(context: context),
      );
      return false;
    } else if (!emailValid!) {
      ToastComponent.showDialog(
        'enter_correct_email'.tr(context: context),
      );
      return false;
    } else if (_addressController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(
        'shipping_address_required'.tr(context: context),
      );
      return false;
    } else if (_selected_country == null) {
      ToastComponent.showDialog(
        'country_required'.tr(context: context),
      );
      return false;
    } else if (_selected_state == null) {
      ToastComponent.showDialog(
        'state_required'.tr(context: context),
      );
      return false;
    } else if (_selected_city == null) {
      ToastComponent.showDialog(
        'city_required'.tr(context: context),
      );
      return false;
    } else if (_postalCodeController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(
        'postal_code_required'.tr(context: context),
      );
      return false;
    } else if (_phoneController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(
        'phone_number_required'.tr(context: context),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.transparent,
          height: 50,
          child: Btn.minWidthFixHeight(
            minWidth: MediaQuery.sizeOf(context).width,
            height: 50,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            child: Text(
              'continue_to_delivery_info_ucf'.tr(context: context),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              continueToDeliveryInfo();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // name
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text('name_ucf'.tr(context: context),
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _nameController,
                    autofocus: false,
                    decoration: buildAddressInputDecoration(
                        context, 'enter_your_name'.tr(context: context)),
                  ),
                ),
              ),

              // email
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text('email_ucf'.tr(context: context),
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _emailController,
                    autofocus: false,
                    decoration: buildAddressInputDecoration(
                        context, 'enter_email'.tr(context: context)),
                  ),
                ),
              ),
              // address
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${'address_ucf'.tr(context: context)} *",
                    style: const TextStyle(
                        color: MyTheme.dark_font_grey, fontSize: 12)),
              ),

              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 55,
                  child: TextField(
                    controller: _addressController,
                    autofocus: false,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: buildAddressInputDecoration(
                        context, 'enter_address_ucf'.tr(context: context)),
                  ),
                ),
              ),

              // country
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${'country_ucf'.tr(context: context)} *",
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    suggestionsCallback: (name) async {
                      final countryResponse =
                          await AddressRepository().getCountryList(name: name);
                      return countryResponse.countries;
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                'loading_countries_ucf'.tr(context: context),
                                style: const TextStyle(
                                    color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic country) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          country.name,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: true,
                        decoration: buildAddressInputDecoration(
                            context, 'enter_country_ucf'.tr(context: context)),
                      );
                    },
                    onSelected: (value) {
                      onSelectCountryDuringAdd(country);
                    },
                  ),
                ),
              ),
              // state
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${'state_ucf'.tr(context: context)} *",
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    suggestionsCallback: (name) async {
                      if (_selected_country == null) {
                        final stateResponse = await AddressRepository()
                            .getStateListByCountry(); // blank response
                        return stateResponse.states;
                      }
                      final stateResponse = await AddressRepository()
                          .getStateListByCountry(
                              country_id: _selected_country!.id, name: name);
                      return stateResponse.states;
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                'loading_states_ucf'.tr(context: context),
                                style: const TextStyle(
                                    color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic state) {
                      //print(suggestion.toString());
                      return ListTile(
                        dense: true,
                        title: Text(
                          state.name,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: true,
                        decoration: buildAddressInputDecoration(
                            context, 'enter_state_ucf'.tr(context: context)),
                      );
                    },
                    onSelected: (dynamic state) {
                      onSelectStateDuringAdd(state);
                    },
                  ),
                ),
              ),
              // city
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${'city_ucf'.tr(context: context)} *",
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TypeAheadField(
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: true,
                        decoration: buildAddressInputDecoration(
                            context, 'enter_city_ucf'.tr(context: context)),
                      );
                    },
                    suggestionsCallback: (name) async {
                      if (_selected_state == null) {
                        final cityResponse = await AddressRepository()
                            .getCityListByState(); // blank response
                        return cityResponse.cities;
                      }
                      final cityResponse = await AddressRepository()
                          .getCityListByState(
                              state_id: _selected_state!.id, name: name);
                      return cityResponse.cities;
                    },
                    loadingBuilder: (context) {
                      return Container(
                        height: 50,
                        child: Center(
                            child: Text(
                                'loading_cities_ucf'.tr(context: context),
                                style: const TextStyle(
                                    color: MyTheme.medium_grey))),
                      );
                    },
                    itemBuilder: (context, dynamic city) {
                      //print(suggestion.toString());
                      return ListTile(
                        dense: true,
                        title: Text(
                          city.name,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    onSelected: (dynamic city) {
                      onSelectCityDuringAdd(city);
                    },
                  ),
                ),
              ),
              // postal code
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text('postal_code'.tr(context: context),
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _postalCodeController,
                    autofocus: false,
                    decoration: buildAddressInputDecoration(
                        context, 'enter_postal_code_ucf'.tr(context: context)),
                  ),
                ),
              ),
              // phone
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text('phone_ucf'.tr(context: context),
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Container(
                  height: 40,
                  child: TextField(
                    controller: _phoneController,
                    autofocus: false,
                    decoration: buildAddressInputDecoration(
                        context, 'enter_phone_number'.tr(context: context)),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: 'existing_email_address'.tr(context: context),
                  style:
                      const TextStyle(color: MyTheme.font_grey, fontSize: 12),
                  children: <TextSpan>[
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          AIZRoute.push(
                            context,
                            const Login(),
                            null,
                            null,
                            false,
                          );
                        },
                      text: 'login_ucf'.tr(context: context),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: 'first_to_continue'.tr(context: context)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration buildAddressInputDecoration(BuildContext context, hintText) {
  return InputDecoration(
      filled: true,
      fillColor: MyTheme.white,
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.noColor, width: 0.5),
        borderRadius: BorderRadius.all(
          Radius.circular(AppDimensions.radiusSmall),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.noColor, width: 1.0),
        borderRadius: BorderRadius.all(
          Radius.circular(AppDimensions.radiusSmall),
        ),
      ),
      contentPadding: const EdgeInsets.only(
          left: AppDimensions.paddingSmall, top: 5.0, bottom: 5.0));
}
