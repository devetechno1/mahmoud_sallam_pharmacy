import 'dart:async';

import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/city_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/country_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/state_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/address_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/map_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';

import '../app_config.dart';
import '../custom/input_decorations.dart';
import '../custom/intl_phone_input.dart';
import '../custom/loading.dart';
import '../custom/useful_elements.dart';
import '../data_model/address_add_response.dart';
import '../data_model/address_response.dart' as res;
import '../presenter/cart_counter.dart';
import '../presenter/home_provider.dart';
import 'add_address_screen.dart';

// class Address extends StatelessWidget {
//   const Address({super.key, required this.onPressContinue});
// final void Function(String email, double latitude, double longitude) onPressContinue;
//   @override
//   Widget build(BuildContext context) {
//     return AddressWidgets(onPressContinue: onPressContinue);
//   }
// }
bool get shouldHaveAddress =>
    AppConfig.businessSettingsData.sellerWiseShipping && is_logged_in.$;

class AddressScreen extends StatefulWidget {
  const AddressScreen(
      {Key? key, this.from_shipping_info = false, required this.goHome})
      : super(key: key);
  final bool from_shipping_info;
  final bool goHome;

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final ScrollController _mainScrollController = ScrollController();

  int? _default_shipping_address = 0;

  bool _isInitial = true;
  final List<res.Address> _shippingAddressList = [];

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

  Future fetchAll([bool isRefresh = false]) async {
    await fetchShippingAddressList(isRefresh);
    makeInitDefaultAddress();

    setState(() {});
  }

  Future fetchShippingAddressList([bool isRefresh = true]) async {
    if (isRefresh)
      setState(() {
        _isInitial = false;
      });
    // print("enter fetchShippingAddressList");
    final res.AddressResponse addressResponse =
        await AddressRepository().getAddressList();
    _shippingAddressList.clear();
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
    // _shippingAddressList.clear();
    _isInitial = true;

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
      await fetchAll(true);
    }
  }

  onPopped(value) async {
    reset();
    await fetchAll();
  }

  Future afterAddingAnAddress(bool isRefresh) async {
    reset();
    await fetchAll(isRefresh);
  }

  afterDeletingAnAddress() {
    reset();
    fetchAll();
  }

  afterUpdatingAnAddress() {
    reset();
    fetchAll();
  }

  Future<void> onTapAddressToSwitch(res.Address address) async {
    bool canSwitch = true;
    final CartCounter cart = Provider.of<CartCounter>(context, listen: false);
    if (AppConfig.businessSettingsData.sellerWiseShipping &&
        cart.cartCounter > 0) {
      canSwitch = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                top: 16.0,
                left: 2.0,
                right: 2.0,
                bottom: 2.0,
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  'change_default_address_make_cart_empty'.tr(context: context),
                  maxLines: 3,
                  style: const TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                  ),
                ),
              ),
              actions: [
                Btn.basic(
                  child: Text(
                    'cancel_ucf'.tr(context: context),
                    style: const TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(false);
                  },
                ),
                Btn.basic(
                  color: MyTheme.soft_accent_color,
                  child: Text(
                    'confirm_ucf'.tr(context: context),
                    style: const TextStyle(color: MyTheme.dark_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(true);
                  },
                ),
              ],
            ),
          ) ==
          true;
    }
    if (!canSwitch) return;
    return onAddressSwitch(address);
  }

  Future<void> onAddressSwitch(res.Address address) async {
    final addressMakeDefaultResponse =
        await AddressRepository().getAddressMakeDefaultResponse(address.id);

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
      _default_shipping_address = address.id;
    });

    context.read<HomeProvider>().defaultAddress = address;

    fetchShippingAddressList(false);
  }

  onPressDelete(res.Address address) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  address.set_default == 1
                      ? 'change_default_before_delete'.tr(context: context)
                      : 'are_you_sure_to_remove_this_address'
                          .tr(context: context),
                  maxLines: 3,
                  style:
                      const TextStyle(color: MyTheme.font_grey, fontSize: 14),
                ),
              ),
              actions: [
                Btn.basic(
                  child: Text(
                    'cancel_ucf'.tr(context: context),
                    style: const TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                if (address.set_default != 1)
                  Btn.basic(
                    color: MyTheme.soft_accent_color,
                    child: Text(
                      'confirm_ucf'.tr(context: context),
                      style: const TextStyle(color: MyTheme.dark_grey),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      confirmDelete(address.id);
                    },
                  ),
              ],
            ));
  }

  Future<void> confirmDelete(id) async {
    final addressDeleteResponse =
        await AddressRepository().getAddressDeleteResponse(id);

    if (addressDeleteResponse.result == false) {
      ToastComponent.showDialog(
        addressDeleteResponse.message,
      );
      return;
    }

    ToastComponent.showDialog(
      addressDeleteResponse.message,
    );

    afterDeletingAnAddress();
  }

  _tabOption(int index, int listIndex) {
    switch (index) {
      case 0:
        buildShowUpdateFormDialog(context, listIndex);
        break;
      case 1:
        onPressDelete(_shippingAddressList[listIndex]);
        break;
      case 2:
        _choosePlace(_shippingAddressList[listIndex]);
        //deleteProduct(productId);
        break;
      default:
        break;
    }
  }

  void _choosePlace(res.Address address) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MapLocation(address: address);
    })).then((value) async {
      await onPopped(value);
      if (value != null) {
        makeDefaultAddress(address);
      }
    });
  }

  void makeDefaultAddress(res.Address address) {
    bool hasDefault = false;
    for (res.Address e in _shippingAddressList) {
      if (e.set_default == 1) {
        hasDefault = true;
        break;
      }
    }
    if (!hasDefault) onAddressSwitch(address);
  }

  void makeInitDefaultAddress() {
    if (_shippingAddressList.isNotEmpty) {
      final Set<res.Address> list = {};
      for (res.Address e in _shippingAddressList) {
        if (e.location_available == true) {
          list.add(e);
          if (e.set_default == 1) return;
        }
      }
      res.Address? defaultAddress;
      if (list.isNotEmpty) {
        defaultAddress = list.last;
      } else {
        defaultAddress = _shippingAddressList.last;
      }

      onAddressSwitch(defaultAddress);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  bool get canPop => shouldHaveAddress ? _shippingAddressList.isNotEmpty : true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop && !widget.goHome,
      onPopInvokedWithResult: (didPop, result) {
        if (!canPop) {
          ToastComponent.showDialog(
            'add_default_address'.tr(context: context),
            isError: true,
          );
        } else if (widget.goHome) {
          context.go('/');
        }
      },
      child: Scaffold(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddAddressScreen(
                              addAddress: (addressEntity) async {
                                final LatLng latLang = LatLng(
                                  addressEntity.latitude ??
                                      AppConfig.businessSettingsData.initPlace.latitude,
                                  addressEntity.longitude ??
                                      AppConfig.businessSettingsData.initPlace.longitude,
                                );
                                if (Loading.isLoading) return;

                                Loading.show(OneContext().context!);

                                final AddressAddResponse addressAddResponse =
                                    await AddressRepository()
                                        .getAddressAddResponse(
                                  address: addressEntity.address ?? '',
                                  country_id: addressEntity.country?.id,
                                  state_id: addressEntity.state?.id,
                                  city_id: addressEntity.city?.id,
                                  phone: addressEntity.phone ?? '',
                                  postal_code: addressEntity.postalCode ?? '',
                                  latitude: latLang.latitude,
                                  longitude: latLang.longitude,
                                );

                                if (addressAddResponse.result == false) {
                                  ToastComponent.showDialog(
                                    addressAddResponse.message,
                                    isError: true,
                                  );
                                  return;
                                }

                                ToastComponent.showDialog(
                                  addressAddResponse.message,
                                  color: Colors.green,
                                );

                                Navigator.pop(context);
                                await afterAddingAnAddress(true);
                                final int i = _shippingAddressList.length - 1;
                                // _choosePlace(_shippingAddressList[i]);
                                await onPickAddress(
                                  addressId: _shippingAddressList[i].id,
                                  selectedPlace: latLang,
                                );
                                await afterAddingAnAddress(true);

                                Loading.close();
                              },
                            ),
                          ),
                        );
                        //buildShowAddFormDialog(context);
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
          )),
    );
  }

// Alart Dialog
  // Future buildShowAddFormDialog(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AddAddressDialog(
  //           shippingAddressList: _shippingAddressList,
  //           afterAddingAnAddress: afterAddingAnAddress,
  //           choosePlace: (index) => _choosePlace(_shippingAddressList[index]),
  //         );
  //       });
  // }

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
      contentPadding: const EdgeInsetsDirectional.only(
        start: 8.0,
        top: 6.0,
        bottom: 6.0,
      ),
    );
  }

  Future buildShowUpdateFormDialog(BuildContext context, index) {
    return showDialog(
        context: context,
        builder: (context) {
          return EditAddressDialog(
            shippingAddress: _shippingAddressList[index],
            afterUpdatingAnAddress: afterUpdatingAnAddress,
            selected_city: _selected_city_list_for_update[index],
            selected_state: _selected_state_list_for_update[index],
            selected_country: _selected_country_list_for_update[index],
            addressControllerText: _addressControllerListForUpdate[index].text,
            postalCodeControllerText:
                _postalCodeControllerListForUpdate[index].text,
            phoneControllerText: _shippingAddressList[index].phone ?? '',
            cityControllerText: _cityControllerListForUpdate[index].text,
            stateControllerText: _stateControllerListForUpdate[index].text,
            countryControllerText: _countryControllerListForUpdate[index].text,
          );
        });
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      leading: canPop
          ? UsefulElements.backButton(
              onPressed: widget.goHome ? () => context.go("/") : null,
            )
          : const SizedBox.shrink(),
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

  InkWell buildAddressItemCard(int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
      onTap: () {
        if (_shippingAddressList[index].location_available != true) {
          _choosePlace(_shippingAddressList[index]);
          // ToastComponent.showDialog('you_have_to_add_location_first'.tr(context: context),isError: true,gravity: ToastGravity.BOTTOM);
          return;
        }
        if (_default_shipping_address != _shippingAddressList[index].id) {
          onTapAddressToSwitch(_shippingAddressList[index]);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
              padding: const EdgeInsets.all(AppDimensions.paddingDefault)
                  .copyWith(bottom: AppDimensions.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LineData(
                    name: 'address_ucf'.tr(context: context),
                    body: "${_shippingAddressList[index].address}",
                  ),
                  LineData(
                    name: 'city_ucf'.tr(context: context),
                    body: "${_shippingAddressList[index].city_name}",
                  ),
                  LineData(
                    name: 'state_ucf'.tr(context: context),
                    body: "${_shippingAddressList[index].state_name}",
                  ),
                  LineData(
                    name: 'country_ucf'.tr(context: context),
                    body: "${_shippingAddressList[index].country_name}",
                  ),
                  LineData(
                    name: 'postal_code'.tr(context: context),
                    body: "${_shippingAddressList[index].postal_code}",
                  ),
                  LineData(
                    name: 'phone_ucf'.tr(context: context),
                    body: "${_shippingAddressList[index].phone}",
                  ),
                  _shippingAddressList[index].location_available != true
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                                bottom: AppDimensions.paddingSmall),
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 9),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusHalfSmall)),
                            child: Text(
                              'you_have_to_add_location_here'
                                  .tr(context: context),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            LineData(
                              name: 'latitude'.tr(context: context),
                              body: "${_shippingAddressList[index].lat}",
                            ),
                            LineData(
                              name: 'longitude'.tr(context: context),
                              body: "${_shippingAddressList[index].lang}",
                            ),
                          ],
                        ),
                ],
              ),
            ),
            // app_language_rtl.$!
            // ?
            PositionedDirectional(
              end: 0.0,
              top: 20,
              child: showOptions(listIndex: index),
            )
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

  Widget showOptions({required int listIndex, int? productId}) {
    return PopupMenuButton<MenuOptions>(
      offset: const Offset(-25, 0),
      child: Container(
        width: 45,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: AlignmentDirectional.topEnd,
        child: Image.asset(AppImages.more,
            width: 4, height: 16, fit: BoxFit.contain, color: MyTheme.grey_153),
      ),
      onSelected: (MenuOptions result) {
        _tabOption(result.index, listIndex);
        // setState(() {
        //   //_menuOptionSelected = result;
        // });
      },
      position: PopupMenuPosition.under,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
        PopupMenuItem<MenuOptions>(
          value: MenuOptions.Edit,
          child: Text('edit_ucf'.tr(context: context)),
        ),
        if (_shippingAddressList.length > 1)
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Delete,
            child: Text('delete_ucf'.tr(context: context)),
          ),
        PopupMenuItem<MenuOptions>(
          value: MenuOptions.AddLocation,
          child: Text('edit_location'.tr(context: context)),
        ),
      ],
    );
  }
}

class LineData extends StatelessWidget {
  const LineData({super.key, required this.name, required this.body});

  final String name;
  final String? body;

  @override
  Widget build(BuildContext context) {
    if (body?.isNotEmpty != true) return emptyWidget;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppDimensions.paddingSmall,
        children: [
          Container(
            width: 75,
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xff6B7377),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Flexible(
            child: Text(
              body!,
              maxLines: 2,
              style: const TextStyle(
                color: MyTheme.dark_grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum MenuOptions { Edit, Delete, AddLocation }

class EditAddressDialog extends StatefulWidget {
  const EditAddressDialog({
    super.key,
    required this.shippingAddress,
    required this.afterUpdatingAnAddress,
    required this.selected_city,
    required this.selected_state,
    required this.selected_country,
    required this.addressControllerText,
    required this.postalCodeControllerText,
    required this.phoneControllerText,
    required this.cityControllerText,
    required this.stateControllerText,
    required this.countryControllerText,
  });
  final shippingAddress;
  final City? selected_city;
  final MyState? selected_state;
  final Country? selected_country;
  final String addressControllerText;
  final String postalCodeControllerText;
  final String phoneControllerText;
  final String cityControllerText;
  final String stateControllerText;
  final String countryControllerText;

  final void Function() afterUpdatingAnAddress;

  @override
  State<EditAddressDialog> createState() => _EditAddressDialogState();
}

class _EditAddressDialogState extends State<EditAddressDialog> {
  late TextEditingController _addressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;

  late City? _selected_city = widget.selected_city;
  late MyState? _selected_state = widget.selected_state;
  late Country? _selected_country = widget.selected_country;

  String _phone = "";
  bool _isValidPhoneNumber = false;
  List<String?> countries_code = <String?>[];
  PhoneNumber initialValue = PhoneNumber(isoCode: AppConfig.default_country);

  Future<void> fetch_country() async {
    final data = await AddressRepository().getCountryList();
    data.countries?.forEach((c) => countries_code.add(c.code));
    setState(() {});
  }

  Future<void> getSavedPhone(String phone) async {
    _phone = phone.trim();
    initialValue = await PhoneNumber.getRegionInfoFromPhoneNumber(_phone);
    _phoneController.text = initialValue.parseNumber().replaceAll("+", '');
    _isValidPhoneNumber = _phoneController.text.isNotEmpty;
  }

  Future<void> getInitVal() async {
    _addressController =
        TextEditingController(text: widget.addressControllerText);
    _postalCodeController =
        TextEditingController(text: widget.postalCodeControllerText);
    _phoneController = TextEditingController(text: widget.phoneControllerText);
    _cityController = TextEditingController(text: widget.cityControllerText);
    _stateController = TextEditingController(text: widget.stateControllerText);
    _countryController =
        TextEditingController(text: widget.countryControllerText);

    await getSavedPhone(_phoneController.text);

    if (!_isValidPhoneNumber) {
      getSavedPhone(user_phone.$);
    }

    setState(() {});
  }

  Future<void> onAddressUpdate(int id) async {
    final String address = _addressController.text.toString();
    final String postalCode = _postalCodeController.text.toString();

    if (address == "") {
      ToastComponent.showDialog(
        'enter_address_ucf'.tr(context: context),
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
    if (_phone.trim().isEmpty) {
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
    }

    final addressUpdateResponse = await AddressRepository()
        .getAddressUpdateResponse(
            id: id,
            address: address,
            country_id: _selected_country!.id,
            state_id: _selected_state!.id,
            city_id: _selected_city!.id,
            postal_code: postalCode,
            phone: _phone);

    if (addressUpdateResponse.result == false) {
      ToastComponent.showDialog(
        addressUpdateResponse.message,
        isError: true,
      );
      return;
    }

    ToastComponent.showDialog(
      addressUpdateResponse.message,
      color: Colors.green,
    );

    Navigator.of(context, rootNavigator: true).pop();
    widget.afterUpdatingAnAddress();
  }

  void onSelectCountryDuringUpdate(country) {
    if (country.id == _selected_country?.id) {
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

  void onSelectStateDuringUpdate(state) {
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

  void onSelectCityDuringUpdate(city) {
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

  @override
  void initState() {
    super.initState();
    getInitVal();
    fetch_country();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${'address_ucf'.tr(context: context)} *",
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12)),
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
                    decoration:
                        InputDecorations.buildInputDecoration_with_border(
                            'enter_address_ucf'.tr(context: context)),
                  ),
                ),
              ),
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
                    controller: _countryController,
                    suggestionsCallback: (name) async {
                      final countryResponse =
                          await AddressRepository().getCountryList(name: name);
                      return countryResponse.countries;
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: false,
                        decoration:
                            InputDecorations.buildInputDecoration_with_border(
                                'enter_city_ucf'.tr(context: context)),
                      );
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
                      //print(suggestion.toString());
                      return ListTile(
                        dense: true,
                        title: Text(
                          country.name,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    onSelected: (value) {
                      onSelectCountryDuringUpdate(value);
                    },
                  ),
                ),
              ),
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
                    controller: _stateController,
                    suggestionsCallback: (name) async {
                      final stateResponse = await AddressRepository()
                          .getStateListByCountry(
                              country_id: _selected_country?.id, name: name);
                      return stateResponse.states;
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: false,
                        decoration:
                            InputDecorations.buildInputDecoration_with_border(
                                'enter_city_ucf'.tr(context: context)),
                      );
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
                    onSelected: (value) {
                      onSelectStateDuringUpdate(value);
                    },
                  ),
                ),
              ),
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
                    controller: _cityController,
                    suggestionsCallback: (name) async {
                      if (_selected_state == null) {
                        final CityResponse cityResponse =
                            await AddressRepository()
                                .getCityListByState(); // blank response
                        return cityResponse.cities;
                      }
                      final CityResponse cityResponse =
                          await AddressRepository().getCityListByState(
                              state_id: _selected_state?.id, name: name);
                      return cityResponse.cities;
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: false,
                        decoration:
                            InputDecorations.buildInputDecoration_with_border(
                                'enter_city_ucf'.tr(context: context)),
                      );
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
                    itemBuilder: (context, City city) {
                      //print(suggestion.toString());
                      return ListTile(
                        dense: true,
                        title: Text(
                          city.name!,
                          style: const TextStyle(color: MyTheme.font_grey),
                        ),
                      );
                    },
                    onSelected: (City city) {
                      onSelectCityDuringUpdate(city);
                    },
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Text("${'phone_ucf'.tr(context: context)} *",
                    style: const TextStyle(
                        color: Color(0xff3E4447),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              Container(
                margin:
                    const EdgeInsets.only(bottom: AppDimensions.paddingDefault),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusHalfSmall),
                  // boxShadow: [MyTheme.commonShadow()],
                ),
                height: 40,
                child: CustomInternationalPhoneNumberInput(
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
                      hint_text: "01XXX XXX XXX"),
                  onSaved: (PhoneNumber number) {},
                ),
              ),
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
                    decoration:
                        InputDecorations.buildInputDecoration_with_border(
                            'enter_postal_code_ucf'.tr(context: context)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Btn.minWidthFixHeight(
                minWidth: 75,
                height: 40,
                color: const Color.fromRGBO(253, 253, 253, 1),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusHalfSmall),
                    side: const BorderSide(
                        color: MyTheme.light_grey, width: 1.0)),
                child: Text(
                  'close_all_capital'.tr(context: context),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 13),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ),
            const SizedBox(width: 1),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 28.0),
              child: Btn.minWidthFixHeight(
                minWidth: 75,
                height: 40,
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusHalfSmall),
                ),
                child: Text(
                  'update_all_capital'.tr(context: context),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  onAddressUpdate(widget.shippingAddress.id);
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
