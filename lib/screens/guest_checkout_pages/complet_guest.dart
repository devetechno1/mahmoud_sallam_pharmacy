import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/aiz_route.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';

import 'package:active_ecommerce_cms_demo_app/custom/loading.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/city_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/country_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/state_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/address_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/guest_checkout_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/checkout/shipping_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class GuestCheckoutAddress extends StatefulWidget {
  const GuestCheckoutAddress({Key? key, this.from_shipping_info = false})
      : super(key: key);
  final bool from_shipping_info;

  @override
  _GuestCheckoutAddressState createState() => _GuestCheckoutAddressState();
}

class _GuestCheckoutAddressState extends State<GuestCheckoutAddress> {
  final ScrollController _mainScrollController = ScrollController();

  int? _default_shipping_address = 0;
  City? _selected_city;
  Country? _selected_country;
  MyState? _selected_state;

  bool _isInitial = true;
  final List<dynamic> _shippingAddressList = [];

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

  //controllers for add purpose
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  //for update purpose
  final List<TextEditingController> _addressControllerListForUpdate = [];
  final List<TextEditingController> _postalCodeControllerListForUpdate = [];
  final List<TextEditingController> _phoneControllerListForUpdate = [];
  final List<TextEditingController> _cityControllerListForUpdate = [];
  final List<TextEditingController> _stateControllerListForUpdate = [];
  final List<TextEditingController> _countryControllerListForUpdate = [];
  final List<City?> _selected_city_list_for_update = [];
  final List<MyState?> _selected_state_list_for_update = [];
  final List<Country> _selected_country_list_for_update = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  fetchAll() {
    fetchShippingAddressList();

    setState(() {});
  }

  fetchShippingAddressList() async {
    // print("enter fetchShippingAddressList");
    final addressResponse = await AddressRepository().getAddressList();
    _shippingAddressList.addAll(addressResponse.addresses ?? []);
    setState(() {
      _isInitial = false;
    });
    if (_shippingAddressList.isNotEmpty) {
      // var count = 0;
      _shippingAddressList.forEach((address) {
        if (address.set_default == 1) {
          _default_shipping_address = address.id;
        }
        _addressControllerListForUpdate
            .add(TextEditingController(text: address.address));
        _postalCodeControllerListForUpdate
            .add(TextEditingController(text: address.postal_code));
        _phoneControllerListForUpdate
            .add(TextEditingController(text: address.phone));
        _countryControllerListForUpdate
            .add(TextEditingController(text: address.country_name));
        _stateControllerListForUpdate
            .add(TextEditingController(text: address.state_name));
        _cityControllerListForUpdate
            .add(TextEditingController(text: address.city_name));
        _selected_country_list_for_update
            .add(Country(id: address.country_id, name: address.country_name));
        _selected_state_list_for_update
            .add(MyState(id: address.state_id, name: address.state_name));
        _selected_city_list_for_update
            .add(City(id: address.city_id, name: address.city_name));
      });

      // print("fetchShippingAddressList");
    }

    setState(() {});
  }

  reset() {
    _default_shipping_address = 0;
    _shippingAddressList.clear();
    _isInitial = true;

    _addressController.clear();
    _postalCodeController.clear();
    _phoneController.clear();

    _countryController.clear();
    _stateController.clear();
    _cityController.clear();

    //update-ables
    _addressControllerListForUpdate.clear();
    _postalCodeControllerListForUpdate.clear();
    _phoneControllerListForUpdate.clear();
    _countryControllerListForUpdate.clear();
    _stateControllerListForUpdate.clear();
    _cityControllerListForUpdate.clear();
    _selected_city_list_for_update.clear();
    _selected_state_list_for_update.clear();
    _selected_country_list_for_update.clear();
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  afterAddingAnAddress() {
    reset();
    fetchAll();
  }

  afterDeletingAnAddress() {
    reset();
    fetchAll();
  }

  afterUpdatingAnAddress() {
    reset();
    fetchAll();
  }

  Future<void> onAddressSwitch(index) async {
    final addressMakeDefaultResponse =
        await AddressRepository().getAddressMakeDefaultResponse(index);

    if (addressMakeDefaultResponse.result == false) {
      ToastComponent.showDialog(
        addressMakeDefaultResponse.message,
      );
      return;
    }

    ToastComponent.showDialog(
      addressMakeDefaultResponse.message,
    );

    setState(() {
      _default_shipping_address = index;
    });
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

  Future<void> continueToDeliveryInfo() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!requiredFieldVerification()) return;

    Loading.show(context);
    await setValues();

    final Map<String, String> postValue = {
      "email": email!,
      "phone": phone!,
    };

    var postBody = jsonEncode(postValue);
    final response =
        await GuestCheckoutRepository().guestCustomerInfoCheck(postBody);

    Loading.close();

    if (response.result!) {
      ToastComponent.showDialog('already_have_account'.tr(context: context));
    } else {
      postValue.addAll({
        "name": name!,
        "address": address!,
        "country_id": country!,
        "state_id": state!,
        "city_id": city!,
        "postal_code": postalCode!,
        "longitude": '',
        "latitude": '',
        "temp_user_id": temp_user_id.$
      });

      postBody = jsonEncode(postValue);

      guestEmail.$ = email!;
      guestEmail.save();
      final bool isPhone = phone?.trim().isNotEmpty == true &&
          AppConfig.businessSettingsData.otpProviders.isNotEmpty;
      AIZRoute.push(
        context,
        ShippingInfo(
          guestCheckOutShippingAddress: postBody,
        ),
        isPhone ? phone : email!,
        null,
        isPhone,
      );
    }
  }

  void onSelectCountryDuringAdd(country, setModalState) {
    if (_selected_country != null && country.id == _selected_country!.id) {
      setModalState(() {
        _countryController.text = country.name;
      });
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;
    setState(() {});

    setModalState(() {
      _countryController.text = country.name;
      _stateController.text = "";
      _cityController.text = "";
    });
  }

  void onSelectStateDuringAdd(state, setModalState) {
    if (_selected_state != null && state.id == _selected_state!.id) {
      setModalState(() {
        _stateController.text = state.name;
      });
      return;
    }
    _selected_state = state;
    _selected_city = null;
    setState(() {});
    setModalState(() {
      _stateController.text = state.name;
      _cityController.text = "";
    });
  }

  void onSelectCityDuringAdd(city, setModalState) {
    if (_selected_city != null && city.id == _selected_city!.id) {
      setModalState(() {
        _cityController.text = city.name;
      });
      return;
    }
    _selected_city = city;
    setModalState(() {
      _cityController.text = city.name;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(context),
        bottomNavigationBar: buildBottomAppBar(context),
        body: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
          onRefresh: _onRefresh,
          displacement: 0,
          child: CustomScrollView(
            controller: _mainScrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 05, 20, 16),
                  child: Btn.minWidthFixHeight(
                    minWidth: MediaQuery.sizeOf(context).width - 16,
                    height: 90,
                    color: const Color(0xffFEF0D7),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSmall),
                        side: BorderSide(
                            color: Colors.amber.shade600, width: 1.0)),
                    child: Column(
                      children: [
                        Text(
                          "${'add_new_address'.tr(context: context)}",
                          style: const TextStyle(
                              fontSize: 13,
                              color: MyTheme.dark_font_grey,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          Icons.add_sharp,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      ],
                    ),
                    onPressed: () {
                      buildShowAddFormDialog(context);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: buildAddressList(),
                ),
                const SizedBox(
                  height: 100,
                )
              ]))
            ],
          ),
        ));
  }

// Alart Dialog
  Future buildShowAddFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setModalState /*You can rename this!*/) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusDefault)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              contentPadding: const EdgeInsets.only(
                  top: 23.0, left: 20.0, right: 20.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
//////////////////////////////////////////////name
                      Padding(
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingSmallExtra),
                        child: Text("${'name_ucf'.tr(context: context)} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingNormal),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _nameController,
                            autofocus: false,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: buildAddressInputDecoration(context,
                                'enter_your_name'.tr(context: context)),
                          ),
                        ),
                      ),

                      ////
                      //////////////////////////////////////////////email
                      Padding(
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingSmallExtra),
                        child: Text("${'email_ucf'.tr(context: context)} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingNormal),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _emailController,
                            autofocus: false,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: buildAddressInputDecoration(
                                context, 'enter_email'.tr(context: context)),
                          ),
                        ),
                      ),
                      //////////////////////////////////

                      Padding(
                        padding: const EdgeInsets.all(
                            AppDimensions.paddingSmallExtra),
                        child: Text("${'address_ucf'.tr(context: context)} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingNormal),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _addressController,
                            autofocus: false,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: buildAddressInputDecoration(context,
                                'enter_address_ucf'.tr(context: context)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text("${'country_ucf'.tr(context: context)} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingNormal),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            controller: _countryController,
                            builder: (context, controller, focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                obscureText: false,
                                decoration: buildAddressInputDecoration(context,
                                    'enter_country_ucf'.tr(context: context)),
                              );
                            },
                            suggestionsCallback: (name) async {
                              final countryResponse = await AddressRepository()
                                  .getCountryList(name: name);
                              return countryResponse.countries;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        'loading_countries_ucf'
                                            .tr(context: context),
                                        style: const TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic country) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  country.name,
                                  style:
                                      const TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {
                              onSelectCountryDuringAdd(value, setModalState);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text("${'state_ucf'.tr(context: context)} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            builder: (context, controller, focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                obscureText: false,
                                decoration: buildAddressInputDecoration(context,
                                    'enter_state_ucf'.tr(context: context)),
                              );
                            },
                            controller: _stateController,
                            suggestionsCallback: (name) async {
                              if (_selected_country == null) {
                                final stateResponse = await AddressRepository()
                                    .getStateListByCountry(); // blank response
                                return stateResponse.states;
                              }
                              final stateResponse = await AddressRepository()
                                  .getStateListByCountry(
                                      country_id: _selected_country!.id,
                                      name: name);
                              return stateResponse.states;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        'loading_states_ucf'
                                            .tr(context: context),
                                        style: const TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic state) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  state.name,
                                  style:
                                      const TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {
                              onSelectStateDuringAdd(value, setModalState);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text("${'city_ucf'.tr(context: context)} *",
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            controller: _cityController,
                            suggestionsCallback: (name) async {
                              if (_selected_state == null) {
                                final cityResponse = await AddressRepository()
                                    .getCityListByState(); // blank response
                                return cityResponse.cities;
                              }
                              final cityResponse = await AddressRepository()
                                  .getCityListByState(
                                      state_id: _selected_state!.id,
                                      name: name);
                              return cityResponse.cities;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        'loading_cities_ucf'
                                            .tr(context: context),
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
                                  style:
                                      const TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {
                              onSelectCityDuringAdd(value, setModalState);
                            },
                            builder: (context, controller, focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                obscureText: false,
                                decoration: buildAddressInputDecoration(context,
                                    'enter_city_ucf'.tr(context: context)),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text('postal_code'.tr(context: context),
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _postalCodeController,
                            autofocus: false,
                            decoration: buildAddressInputDecoration(context,
                                'enter_postal_code_ucf'.tr(context: context)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text('phone_ucf'.tr(context: context),
                            style: const TextStyle(
                                color: Color(0xff3E4447),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _phoneController,
                            autofocus: false,
                            decoration: buildAddressInputDecoration(context,
                                'enter_phone_number'.tr(context: context)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: const Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusHalfSmall),
                            side: const BorderSide(
                                color: MyTheme.light_grey, width: 1)),
                        child: Text(
                          'close_ucf'.tr(context: context),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingExtraLarge),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusHalfSmall),
                        ),
                        child: Text(
                          'add_ucf'.tr(context: context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          continueToDeliveryInfo();
                        },
                      ),
                    )
                  ],
                )
              ],
            );
          });
        });
  }

  InputDecoration buildAddressInputDecoration(BuildContext context, hintText) {
    return InputDecoration(
        filled: true,
        fillColor: const Color(0xffF6F7F8),
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 12.0, color: Color(0xff999999)),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.noColor, width: 0.5),
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.radiusHalfSmall),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.noColor, width: 1.0),
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.radiusHalfSmall),
          ),
        ),
        contentPadding: const EdgeInsets.only(
            left: AppDimensions.paddingSmall, top: 6.0, bottom: 6.0));
  }

  Future buildShowUpdateFormDialog(BuildContext context, index) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setModalState /*You can rename this!*/) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              contentPadding: const EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text("${'address_ucf'.tr(context: context)} *",
                            style: const TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 55,
                          child: TextField(
                            controller: _addressControllerListForUpdate[index],
                            autofocus: false,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: buildAddressInputDecoration(context,
                                'enter_address_ucf'.tr(context: context)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text("${'country_ucf'.tr(context: context)} *",
                            style: const TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            controller: _countryControllerListForUpdate[index],
                            suggestionsCallback: (name) async {
                              final countryResponse = await AddressRepository()
                                  .getCountryList(name: name);
                              return countryResponse.countries;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        'loading_countries_ucf'
                                            .tr(context: context),
                                        style: const TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic country) {
                              //print(suggestion.toString());
                              return ListTile(
                                dense: true,
                                title: Text(
                                  country.name,
                                  style:
                                      const TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {},
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text("${'state_ucf'.tr(context: context)} *",
                            style: const TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            controller: _stateControllerListForUpdate[index],
                            suggestionsCallback: (name) async {
                              final stateResponse = await AddressRepository()
                                  .getStateListByCountry(
                                      country_id:
                                          _selected_country_list_for_update[
                                                  index]
                                              .id,
                                      name: name);
                              return stateResponse.states;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        'loading_states_ucf'
                                            .tr(context: context),
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
                                  style:
                                      const TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {},
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text("${'city_ucf'.tr(context: context)} *",
                            style: const TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            controller: _cityControllerListForUpdate[index],
                            suggestionsCallback: (name) async {
                              if (_selected_state_list_for_update[index] ==
                                  null) {
                                final cityResponse = await AddressRepository()
                                    .getCityListByState(); // blank response
                                return cityResponse.cities;
                              }
                              final cityResponse = await AddressRepository()
                                  .getCityListByState(
                                      state_id: _selected_state_list_for_update[
                                              index]!
                                          .id,
                                      name: name);
                              return cityResponse.cities;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        'loading_cities_ucf'
                                            .tr(context: context),
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
                                  style:
                                      const TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            onSelected: (value) {},
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text('postal_code'.tr(context: context),
                            style: const TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingDefault),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller:
                                _postalCodeControllerListForUpdate[index],
                            autofocus: false,
                            decoration: buildAddressInputDecoration(context,
                                'enter_postal_code_ucf'.tr(context: context)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Text('phone_ucf'.tr(context: context),
                            style: const TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _phoneControllerListForUpdate[index],
                            autofocus: false,
                            decoration: buildAddressInputDecoration(context,
                                'enter_phone_number'.tr(context: context)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: const Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusHalfSmall),
                            side: const BorderSide(
                                color: MyTheme.light_grey, width: 1.0)),
                        child: Text(
                          'close_all_capital'.tr(context: context),
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 13),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingExtraLarge),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusHalfSmall),
                        ),
                        child: Text(
                          'update_all_capital'.tr(context: context),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {},
                      ),
                    )
                  ],
                )
              ],
            );
          });
        });
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
              color: MyTheme.dark_font_grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'addresses_of_user'.tr(context: context),
            style: const TextStyle(
                fontSize: 16,
                color: Color(0xff3E4447),
                fontWeight: FontWeight.bold),
          ),
          Text(
            "* ${'tap_on_an_address_to_make_it_default'.tr(context: context)}",
            style: const TextStyle(fontSize: 12, color: Color(0xff6B7377)),
          ),
        ],
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget? buildAddressList() {
    // print("is Initial: ${_isInitial}");
    if (is_logged_in == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            'you_need_to_log_in'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    } else if (_isInitial && _shippingAddressList.isEmpty) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_shippingAddressList.isNotEmpty) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 16,
            );
          },
          itemCount: _shippingAddressList.length,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildAddressItemCard(index);
          },
        ),
      );
    } else if (!_isInitial && _shippingAddressList.isEmpty) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            'no_address_is_added'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    }
    return null;
  }

  GestureDetector buildAddressItemCard(index) {
    return GestureDetector(
      onTap: () {
        if (_default_shipping_address != _shippingAddressList[index].id) {
          onAddressSwitch(_shippingAddressList[index].id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
            border: Border.all(
                color:
                    _default_shipping_address == _shippingAddressList[index].id
                        ? Theme.of(context).primaryColor
                        : MyTheme.light_grey,
                width:
                    _default_shipping_address == _shippingAddressList[index].id
                        ? 1.0
                        : 0.0)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            'address_ucf'.tr(context: context),
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 175,
                          child: Text(
                            _shippingAddressList[index].address,
                            maxLines: 2,
                            style: const TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            'city_ucf'.tr(context: context),
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].city_name,
                            maxLines: 2,
                            style: const TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            'state_ucf'.tr(context: context),
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].state_name,
                            maxLines: 2,
                            style: const TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            'country_ucf'.tr(context: context),
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].country_name,
                            maxLines: 2,
                            style: const TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            'postal_code'.tr(context: context),
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].postal_code,
                            maxLines: 2,
                            style: const TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            'phone_ucf'.tr(context: context),
                            style: const TextStyle(
                                color: Color(0xff6B7377),
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].phone,
                            maxLines: 2,
                            style: const TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            app_language_rtl.$!
                ? Positioned(
                    left: 0.0,
                    top: 10.0,
                    child: showOptions(listIndex: index),
                  )
                : Positioned(
                    right: 0.0,
                    top: 10.0,
                    child: showOptions(listIndex: index),
                  ),
          ],
        ),
      ),
    );
  }

  Visibility buildBottomAppBar(BuildContext context) {
    return Visibility(
      visible: widget.from_shipping_info,
      child: BottomAppBar(
        color: Colors.transparent,
        child: Container(
          height: 50,
          child: Btn.minWidthFixHeight(
            minWidth: MediaQuery.sizeOf(context).width,
            height: 50,
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            child: Text(
              'back_to_shipping_info'.tr(context: context),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              return Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget showOptions({listIndex, productId}) {
    return Container(
      width: 45,
      child: PopupMenuButton<MenuOptions>(
        offset: const Offset(-25, 0),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Container(
            width: 45,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.topRight,
            child: Image.asset(AppImages.more,
                width: 4,
                height: 16,
                fit: BoxFit.contain,
                color: MyTheme.grey_153),
          ),
        ),
        onSelected: (MenuOptions result) {
          // setState(() {
          //   //_menuOptionSelected = result;
          // });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Edit,
            child: Text('edit_ucf'.tr(context: context)),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Delete,
            child: Text('delete_ucf'.tr(context: context)),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.AddLocation,
            child: Text('add_location_ucf'.tr(context: context)),
          ),
        ],
      ),
    );
  }
}

enum MenuOptions { Edit, Delete, AddLocation }
