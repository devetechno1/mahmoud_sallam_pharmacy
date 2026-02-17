import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../app_config.dart';
import '../custom/btn.dart';
import '../custom/input_decorations.dart';
import '../custom/intl_phone_input.dart';
import '../custom/toast_component.dart';
import '../custom/useful_elements.dart';
import '../data_model/city_response.dart';
import '../data_model/country_response.dart';
import '../data_model/state_response.dart';
import '../helpers/shared_value_helper.dart';
import '../my_theme.dart';
import '../repositories/address_repository.dart';
import '../status/execute_and_handle_remote_errors.dart';
import '../status/status.dart';
import 'guest_checkout_pages/map_location.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({
    super.key,
    required this.addAddress,
    this.initValue,
  });

  final void Function(AddressDataEntity) addAddress;
  final AddressDataEntity? initValue;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  double? longitude;
  double? latitude;
  bool passNotMatch = true;
  City? _selected_city;
  Country? _selected_country;
  MyState? _selected_state;

  //controllers for add purpose
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _phone = "";
  bool _isValidPhoneNumber = false;
  List<String?> countries_code = <String?>[];
  PhoneNumber initialValue = PhoneNumber(isoCode: AppConfig.default_country);

  Future<void> fetch_country() async {
    final data = await AddressRepository().getCountryList();
    data.countries?.forEach((c) => countries_code.add(c.code));
    setState(() {});
  }

  Future<void> getInitVal() async {
    if (widget.initValue != null) {
      _nameController.text = widget.initValue!.name ?? '';
      _emailController.text = widget.initValue!.email ?? '';
      _addressController.text = widget.initValue!.address ?? '';
      _postalCodeController.text = widget.initValue!.postalCode ?? '';

      _selected_city = widget.initValue!.city;
      _selected_country = widget.initValue!.country;
      _selected_state = widget.initValue!.state;

      _countryController.text = widget.initValue!.country?.name ?? '';
      _stateController.text = widget.initValue!.state?.name ?? '';
      _cityController.text = widget.initValue!.city?.name ?? '';

      _passwordController.text = widget.initValue!.password ?? '';
      _phone = widget.initValue!.phone ?? '';
      longitude = widget.initValue!.longitude;
      latitude = widget.initValue!.latitude;
    } else {
      _phone = user_phone.$.trim();
    }
    if (_phone.trim().isNotEmpty) {
      initialValue = await PhoneNumber.getRegionInfoFromPhoneNumber(_phone);
      _phoneController.text = initialValue.parseNumber().replaceAll("+", '');
    }
    _isValidPhoneNumber = _phoneController.text.isNotEmpty;
    setState(() {});
  }

  void reset() {
    _nameController.clear();
    _emailController.clear();
    _addressController.clear();
    _postalCodeController.clear();
    _phoneController.clear();
    _countryController.clear();
    _stateController.clear();
    _cityController.clear();
    passNotMatch = true;
    longitude = null;
    latitude = null;
  }

  Future<void> _onAddressAdd() async {
    final String address = _addressController.text.toString();
    final String postalCode = _postalCodeController.text.toString();

    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text.trim());

    if (_nameController.text.trim().isEmpty && !is_logged_in.$) {
      ToastComponent.showDialog(
        'name_required'.tr(context: context),
        isError: true,
      );
      return;
    } else if (!AppConfig.businessSettingsData.hideEmailCheckout &&
        _emailController.text.trim().isEmpty &&
        !is_logged_in.$) {
      ToastComponent.showDialog(
        'email_required'.tr(context: context),
        isError: true,
      );
      return;
    } else if (!AppConfig.businessSettingsData.hideEmailCheckout &&
        (!emailValid) &&
        !is_logged_in.$) {
      ToastComponent.showDialog(
        'enter_correct_email'.tr(context: context),
        isError: true,
      );
      return;
    } else if (longitude == null || latitude == null) {
      ToastComponent.showDialog(
        'choose_an_address_or_pickup_point'.tr(context: context),
        isError: true,
      );
      return;
    }
    if (address.trim() == "") {
      ToastComponent.showDialog(
        'enter_address_ucf'.tr(context: context),
        isError: true,
      );
      return;
    }

    if (_selected_country == null) {
      ToastComponent.showDialog(
        'select_a_country'.tr(context: context),
        isError: true,
      );
      return;
    }

    if (_selected_state == null) {
      ToastComponent.showDialog(
        'select_a_state'.tr(context: context),
        isError: true,
      );
      return;
    }

    if (_selected_city == null) {
      ToastComponent.showDialog(
        'select_a_city'.tr(context: context),
        isError: true,
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      ToastComponent.showDialog(
        'enter_phone_number'.tr(context: context),
        isError: true,
      );
      return;
    } else if (!_isValidPhoneNumber) {
      ToastComponent.showDialog(
        'invalid_phone_number'.tr(context: context),
        isError: true,
      );
      return;
    } else if (_passwordController.text.isEmpty && !is_logged_in.$) {
      ToastComponent.showDialog(
        'enter_password'.tr(context: context),
        isError: true,
      );
      return;
    } else if (_passwordController.text.length < 6 && !is_logged_in.$) {
      ToastComponent.showDialog(
        'password_must_contain_at_least_6_characters'.tr(context: context),
        isError: true,
      );
      return;
    } else if (passNotMatch && !is_logged_in.$) {
      ToastComponent.showDialog(
        'passwords_do_not_match'.tr(context: context),
        isError: true,
      );
      return;
    }

    widget.addAddress(
      AddressDataEntity(
        name: _nameController.text.trim(),
        email: AppConfig.businessSettingsData.hideEmailCheckout
            ? null
            : _emailController.text.trim(),
        address: address,
        postalCode: postalCode,
        phone: _phone,
        country: _selected_country!,
        state: _selected_state!,
        city: _selected_city!,
        password: _passwordController.text,
        latitude: latitude!,
        longitude: longitude!,
      ),
    );
  }

  void onSelectCountryDuringAdd(Country country) {
    if (country.id == _selected_country?.id) {
      _countryController.text = country.name ?? '';
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;

    _countryController.text = country.name ?? '';
    _stateController.text = "";
    _cityController.text = "";

    setState(() {});
  }

  void onSelectStateDuringAdd(MyState state) {
    if (_selected_state != null && state.id == _selected_state!.id) {
      setState(() {
        _stateController.text = state.name ?? '';
      });
      return;
    }
    _stateController.text = state.name ?? '';
    _cityController.text = "";

    _selected_state = state;
    _selected_city = null;
    setState(() {});
  }

  void onSelectCityDuringAdd(City city) {
    if (_selected_city != null && city.id == _selected_city!.id) {
      _cityController.text = city.name!;
      return;
    }
    _cityController.text = city.name!;
    _selected_city = city;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getInitVal();
    fetch_country();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.paddingSmall),
            //name
            if (!is_logged_in.$) ...[
              _TitleFieldWidget(
                title: "${'name_ucf'.tr(context: context)} *",
                fieldWidget: TextField(
                  controller: _nameController,
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  decoration: InputDecorations.buildInputDecoration_with_border(
                    'enter_your_name'.tr(context: context),
                  ),
                ),
              ),
              if (!AppConfig.businessSettingsData.hideEmailCheckout)
                _TitleFieldWidget(
                  title: "${'email_ucf'.tr(context: context)} *",
                  fieldWidget: TextField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    autofocus: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        InputDecorations.buildInputDecoration_with_border(
                      'enter_email'.tr(context: context),
                    ),
                  ),
                ),
            ],
            _TitleFieldWidget(
              fieldWidgetHeight: null,
              title: "${'choose_an_address'.tr(context: context)} *",
              fieldWidget: MapLocationWidget(
                latitude: latitude,
                longitude: longitude,
                onPlacePicked: (latLong) {
                  latitude = latLong?.latitude;
                  longitude = latLong?.longitude;
                  handleAddressData(latLong);
                },
              ),
            ),
            _TitleFieldWidget(
              title: "${'address_ucf'.tr(context: context)} *",
              fieldWidget: TextField(
                controller: _addressController,
                autofocus: false,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecorations.buildInputDecoration_with_border(
                  'enter_address_ucf'.tr(context: context),
                ),
              ),
            ),
            _TitleFieldWidget(
              title: "${'country_ucf'.tr(context: context)} *",
              fieldWidget: _DropDownFieldWidget<Country>(
                controller: _countryController,
                hintText: 'enter_country_ucf'.tr(context: context),
                loadingText: 'loading_countries_ucf'.tr(context: context),
                onSelected: onSelectCountryDuringAdd,
                suggestionsCallback: suggestionsCallbackCountry,
              ),
            ),
            _TitleFieldWidget(
              title: "${'state_ucf'.tr(context: context)} *",
              fieldWidget: _DropDownFieldWidget<MyState>(
                controller: _stateController,
                hintText: 'enter_state_ucf'.tr(context: context),
                loadingText: 'loading_states_ucf'.tr(context: context),
                onSelected: onSelectStateDuringAdd,
                suggestionsCallback: suggestionsCallbackState,
              ),
            ),
            _TitleFieldWidget(
              title: "${'city_ucf'.tr(context: context)} *",
              fieldWidget: _DropDownFieldWidget<City>(
                controller: _cityController,
                hintText: 'enter_city_ucf'.tr(context: context),
                loadingText: 'loading_cities_ucf'.tr(context: context),
                onSelected: onSelectCityDuringAdd,
                suggestionsCallback: suggestionsCallbackCity,
              ),
            ),
            _TitleFieldWidget(
              title: "${'phone_ucf'.tr(context: context)} *",
              fieldWidget: CustomInternationalPhoneNumberInput(
                countries: countries_code,
                height: 40,
                backgroundColor: Colors.transparent,
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
                keyboardType:
                    const TextInputType.numberWithOptions(signed: true),
                inputDecoration: InputDecorations.buildInputDecoration_phone(
                  hint_text: "01XXX XXX XXX",
                ),
              ),
            ),
            if (!AppConfig.businessSettingsData.hidePostalCodeCheckout)
              _TitleFieldWidget(
                title: 'postal_code'.tr(context: context),
                fieldWidget: TextField(
                  controller: _postalCodeController,
                  autofocus: false,
                  maxLines: null,
                  decoration: InputDecorations.buildInputDecoration_with_border(
                    'enter_postal_code_ucf'.tr(context: context),
                  ),
                ),
              ),

            //if statement
            if (!is_logged_in.$) ...[
              _TitleFieldWidget(
                title: "${'password_ucf'.tr(context: context)} *",
                fieldWidget: TextField(
                  textInputAction: TextInputAction.next,
                  controller: _passwordController,
                  autofocus: false,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecorations.buildInputDecoration_with_border(
                    "• • • • • • • •",
                  ),
                ),
              ),
              _TitleFieldWidget(
                title: "${'confirm_your_password'.tr(context: context)} *",
                fieldWidget: TextField(
                  textInputAction: TextInputAction.done,
                  autofocus: false,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (val) {
                    passNotMatch = val != _passwordController.text;
                  },
                  decoration: InputDecorations.buildInputDecoration_with_border(
                    "• • • • • • • •",
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            Center(
              child: Btn.minWidthFixHeight(
                minWidth: 300,
                height: 50,
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusHalfSmall),
                ),
                child: Text(
                  'continue_ucf'.tr(context: context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _onAddressAdd,
              ),
            ),
            const SizedBox(height: 20),
            // )
          ],
        ),
      ),
    );
  }

  FutureOr<List<City>?> suggestionsCallbackCity(String name) async {
    if (_selected_state == null) {
      final CityResponse cityResponse =
          await AddressRepository().getCityListByState(); // blank response
      return cityResponse.cities;
    }
    final CityResponse cityResponse = await AddressRepository()
        .getCityListByState(state_id: _selected_state!.id, name: name);
    return cityResponse.cities;
  }

  Future<List<MyState>?> suggestionsCallbackState(String name) async {
    if (_selected_country == null) {
      final stateResponse =
          await AddressRepository().getStateListByCountry(); // blank response
      return stateResponse.states;
    }
    final stateResponse = await AddressRepository()
        .getStateListByCountry(country_id: _selected_country!.id, name: name);
    return stateResponse.states;
  }

  Future<List<Country>?> suggestionsCallbackCountry(name) async {
    final CountryResponse countryResponse =
        await AddressRepository().getCountryList(name: name);
    return countryResponse.countries;
  }

  Future<void> handleAddressData(LatLng? latLong) async {
    if (latLong == null) return;

    final Status<({Country country, MyState state, City city})?> status =
        await executeAndHandleErrors(
      () => AddressRepository().getAddressDataByLatLng(latLong),
    );

    if (status is Failure<
        ({
          Country country,
          MyState state,
          City city,
        })?>) return;

    final response = (status as Success<
            ({
              Country country,
              MyState state,
              City city,
            })?>)
        .data;

    if (response == null) return;

    _selected_country = response.country;
    _selected_state = response.state;
    _selected_city = response.city;

    _countryController.text = _selected_country?.name ?? '';
    _stateController.text = _selected_state?.name ?? '';
    _cityController.text = _selected_city?.name ?? '';

    setState(() {});
  }
}

class _DropDownFieldWidget<T> extends StatefulWidget {
  const _DropDownFieldWidget({
    super.key,
    this.controller,
    required this.hintText,
    required this.loadingText,
    this.onSelected,
    required this.suggestionsCallback,
    this.textInputAction,
  });
  final TextEditingController? controller;
  final String hintText;
  final String loadingText;
  final TextInputAction? textInputAction;
  final void Function(T)? onSelected;
  final FutureOr<List<T>?> Function(String) suggestionsCallback;

  @override
  State<_DropDownFieldWidget<T>> createState() =>
      _DropDownFieldWidgetState<T>();
}

class _DropDownFieldWidgetState<T> extends State<_DropDownFieldWidget<T>> {
  final SuggestionsController<T> suggestionsController =
      SuggestionsController<T>();

  @override
  void dispose() {
    suggestionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<T>(
      controller: widget.controller,
      suggestionsController: suggestionsController,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          onTap: () {
            if (!focusNode.hasFocus) suggestionsController.refresh();
          },
          focusNode: focusNode,
          textInputAction: widget.textInputAction,
          obscureText: false,
          decoration: InputDecorations.buildInputDecoration_with_border(
            widget.hintText,
          ),
        );
      },
      suggestionsCallback: widget.suggestionsCallback,
      loadingBuilder: (context) {
        return Container(
          height: 50,
          child: Center(
            child: Text(
              widget.loadingText,
              style: const TextStyle(color: MyTheme.medium_grey),
            ),
          ),
        );
      },
      itemBuilder: (context, dynamic type) {
        return ListTile(
          dense: true,
          title: Text(
            type.name,
            style: const TextStyle(color: MyTheme.font_grey),
          ),
        );
      },
      onSelected: widget.onSelected,
    );
  }
}

class _TitleFieldWidget extends StatelessWidget {
  const _TitleFieldWidget({
    required this.title,
    required this.fieldWidget,
    this.fieldWidgetHeight = 40,
  });

  final String title;
  final double? fieldWidgetHeight;
  final Widget fieldWidget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.constrainedBoxDefaultWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xff3E4447),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              height: fieldWidgetHeight,
              child: fieldWidget,
            ),
            const SizedBox(height: AppDimensions.paddingNormal),
          ],
        ),
      ),
    );
  }
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    centerTitle: false,
    leading: UsefulElements.backButton(),
    title: Text(
      'add_new_address'.tr(context: context),
      style: const TextStyle(
        fontSize: 16,
        color: MyTheme.dark_font_grey,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevation: 0.0,
    titleSpacing: 0,
  );
}

class AddressDataEntity {
  final String? name;
  final String? email;
  final String? address;
  final String? postalCode;
  final String? phone;
  final Country? country;
  final MyState? state;
  final City? city;
  final String? password;
  final double? latitude;
  final double? longitude;

  const AddressDataEntity({
    required this.name,
    required this.email,
    required this.address,
    required this.postalCode,
    required this.phone,
    required this.country,
    required this.state,
    required this.city,
    required this.password,
    required this.latitude,
    required this.longitude,
  });
}
