import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/address_repository.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:one_context/one_context.dart';

import '../app_config.dart';
import '../custom/btn.dart';
import '../data_model/address_response.dart';
import '../my_theme.dart';
import '../other_config.dart';

class MapLocation extends StatefulWidget {
  const MapLocation({Key? key, required this.address}) : super(key: key);
  final Address address;

  @override
  State<MapLocation> createState() => MapLocationState();
}

class MapLocationState extends State<MapLocation>
    with SingleTickerProviderStateMixin {
  // PickResult? selectedPlace;
  static LatLng kInitialPosition = AppConfig.businessSettingsData.initPlace;

  GoogleMapController? _controller;

  @override
  void dispose() {
    // _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        FocusScope.of(context).unfocus();
      },
    );

    if (widget.address.location_available ?? false) {
      setInitialLocation();
    } else {
      setDummyInitialLocation();
    }
  }

  setInitialLocation() {
    kInitialPosition = LatLng(
        widget.address.lat ?? AppConfig.businessSettingsData.initPlace.latitude,
        widget.address.lang ??
            AppConfig.businessSettingsData.initPlace.longitude);
    setState(() {});
  }

  setDummyInitialLocation() {
    kInitialPosition = AppConfig.businessSettingsData.initPlace;
    setState(() {});
  }

  LatLng selectedPlace = kInitialPosition;
  bool isCameraIdle = false;
  bool isLoadingFormattedAddress = true;
  String? formattedAddress;
  final FocusNode fieldNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: kInitialPosition,
              zoom: 10,
            ),
            zoomControlsEnabled: false,
            compassEnabled: false,
            indoorViewEnabled: true,
            mapToolbarEnabled: true,
            onCameraIdle: () async {
              // locationController.updateMapPosition(_cameraPosition, false, null, context);
              // await onTapPickHere();

              isCameraIdle = true;
              formattedAddress = null;
              setState(() {});

              try {
                final List<Placemark> temp = await placemarkFromCoordinates(
                    selectedPlace.latitude, selectedPlace.longitude);
                formattedAddress =
                    '${temp.first.street}, ${temp.first.locality}, ${temp.first.administrativeArea}, ${temp.first.country}';
              } catch (e) {}

              if (!mounted) return;

              isLoadingFormattedAddress = false;
              // print("onPlacePicked..."+result.toString());
              // Navigator.pop(context);
              setState(() {});
            },
            onCameraMove: (position) {
              selectedPlace = position.target;
              isCameraIdle = false;
              setState(() {});
            },
            myLocationEnabled: !(widget.address.location_available ?? false),
            onMapCreated: (GoogleMapController controller) =>
                _controller = controller,
          ),
          Positioned(
            height: 50,
            bottom: 40.0,
            // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
            left: 16.0,
            right: 16.0,
            child:
                // state == SearchingState.Searching
                //   ? Center(
                //       child: Text(
                //       'calculating'.tr(context: context),
                //       style: TextStyle(color: MyTheme.font_grey),
                //     ))
                //   :
                Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusSmall),
                  bottomLeft: Radius.circular(AppDimensions.radiusSmall),
                  topRight: Radius.circular(AppDimensions.radiusSmall),
                  bottomRight: Radius.circular(AppDimensions.radiusSmall),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Center(
                        child: formattedAddress == null
                            ? const CircularProgressIndicator()
                            : Padding(
                                padding: const EdgeInsets.only(
                                    left: 2.0, right: 2.0),
                                child: Text(
                                  formattedAddress!,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      color: MyTheme.medium_grey),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Btn.basic(
                      color: Theme.of(context).primaryColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(AppDimensions.radiusSmallExtra),
                        bottomLeft:
                            Radius.circular(AppDimensions.radiusSmallExtra),
                        topRight:
                            Radius.circular(AppDimensions.radiusSmallExtra),
                        bottomRight:
                            Radius.circular(AppDimensions.radiusSmallExtra),
                      )),
                      child: Text(
                        'pick_here'.tr(context: context),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        onPickAddress(
                          addressId: widget.address.id,
                          selectedPlace: selectedPlace,
                        );
                        Navigator.pop(OneContext().context!, selectedPlace);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingDefault),
                child: TypeAheadField<Results>(
                  // controller: _countryController,
                  debounceDuration: const Duration(milliseconds: 500),
                  emptyBuilder: (context) {
                    return emptyWidget;
                  },
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.7),
                  focusNode: fieldNode,
                  builder: (context, controller, focusNode) {
                    final OutlineInputBorder outlineInputBorder =
                        OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: MyTheme.textfield_grey, width: 0.5),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusHalfSmall),
                    );
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      obscureText: false,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                          hintText:
                              'your_delivery_location'.tr(context: context),
                          hintStyle: const TextStyle(
                              fontSize: 12.0, color: MyTheme.textfield_grey),
                          enabledBorder: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          border: outlineInputBorder,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          prefixIcon: Icon(Icons.location_on,
                              color: FocusScope.of(context).hasFocus
                                  ? Theme.of(context).primaryColor
                                  : MyTheme.textfield_grey),
                          suffixIcon: const Icon(Icons.search_rounded,
                              color: MyTheme.textfield_grey)),
                    );
                  },
                  suggestionsCallback: getSuggestion,
                  loadingBuilder: (context) {
                    return Container(
                      height: 50,
                      child: Center(
                        child: Text(
                          'loading_countries_ucf'.tr(context: context),
                          style: const TextStyle(color: MyTheme.medium_grey),
                        ),
                      ),
                    );
                  },
                  itemBuilder: (context, Results result) {
                    return ListTile(
                      dense: true,
                      title: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: MyTheme.font_grey),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              result.formattedAddress ?? '',
                              maxLines: 1,
                              style: const TextStyle(
                                  color: MyTheme.font_grey, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onSelected: onSelectSearchedLocation,
                ),
              ),
            ),
          ),
          Align(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isCameraIdle ? 1 : 1.3,
              child: Image.asset(
                AppImages.deliveryMapIcon,
                height: 60,
              ),
            ),
          )
        ],
      ),
    );
  }

  void onSelectSearchedLocation(Results result) {
    // formattedAddress = result.formattedAddress;
    _controller
        ?.animateCamera(CameraUpdate.newLatLng(result.geometry!.latLang!));
    print(result.formattedAddress);
  }

  Future<List<Results>> getSuggestion(String query) async {
    print("query $query");
    try {
      final String url =
          "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=${OtherConfig.GOOGLE_MAP_API_KEY}";
      final http.Response response = await http.get(Uri.parse(url));
      final PlaceRes placeRes = PlaceRes.fromJson(jsonDecode(response.body));
      return placeRes.results ?? [];
    } catch (e) {
      print("Error e = $e");
      return [];
    }
  }
}

/*PlacePicker(
      hintText: 'your_delivery_location'.tr(context: context),
      apiKey: OtherConfig.GOOGLE_MAP_API_KEY,
      initialPosition: kInitialPosition,
      useCurrentLocation: !widget.address.location_available,
      selectInitialPosition: true,

      //selectInitialPosition: true,
      //onMapCreated: _onMapCreated, // this causes error , do not open this
      //initialMapType: MapType.terrain,

      //usePlaceDetailSearch: true,
      onPlacePicked: (result) {
        selectedPlace = result;

        // print("onPlacePicked..."+result.toString());
        // Navigator.pop(context);
        setState(() {});
      },
      //forceSearchOnZoomChanged: true,
      //automaticallyImplyAppBarLeading: false,
      //autocompleteLanguage: "ko",
      //region: 'au',
      //selectInitialPosition: true,
      selectedPlaceWidgetBuilder:
          (_, selectedPlace, state, isSearchBarFocused) {
        //print("state: $state, isSearchBarFocused: $isSearchBarFocused");
        //print(selectedPlace.toString());
        //print("-------------");
        /*
        if(!isSearchBarFocused && state != SearchingState.Searching){
          ToastComponent.showDialog("Hello", context,
              gravity: Toast.center, duration: Toast.lengthLong);
        }*/
        return isSearchBarFocused
            ? SizedBox()
            : FloatingCard(
                height: 50,
                bottomPosition: 40.0,
                // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                leftPosition: 16.0,
                rightPosition: 16.0,
                width: 500,
                borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(AppDimensions.radiusSmall),
                  bottomLeft: const Radius.circular(AppDimensions.radiusSmall),
                  topRight: const Radius.circular(AppDimensions.radiusSmall),
                  bottomRight: const Radius.circular(AppDimensions.radiusSmall),
                ),
                child: state == SearchingState.Searching
                    ? Center(
                        child: Text(
                        'calculating'.tr(context: context),
                        style: TextStyle(color: MyTheme.font_grey),
                      ))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2.0, right: 2.0),
                                    child: Text(
                                      selectedPlace!.formattedAddress!,
                                      maxLines: 2,
                                      style:
                                          TextStyle(color: MyTheme.medium_grey),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Btn.basic(
                                color: MyTheme.accent_color,
                                shape: RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.only(
                                  topLeft: const Radius.circular(AppDimensions.radiusSmallExtra),
                                  bottomLeft: const Radius.circular(AppDimensions.radiusSmallExtra),
                                  topRight: const Radius.circular(AppDimensions.radiusSmallExtra),
                                  bottomRight: const Radius.circular(AppDimensions.radiusSmallExtra),
                                )),
                                child: Text(
                                  'pick_here'.tr(context: context),
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
                                  //            this will override default 'Select here' Button.
                                  /*print("do something with [selectedPlace] data");
                                  print(selectedPlace.formattedAddress);
                                  print(selectedPlace.geometry.location.lat);
                                  print(selectedPlace.geometry.location.lng);*/

                                  onTapPickHere(selectedPlace);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              );
      },
      pinBuilder: (context, state) {
        return AnimatedScale(
          duration: Duration(milliseconds: 200),
          scale: state == PinState.Idle ? 1 : 1.3,
          child: Image.asset(
            'assets/delivery_map_icon.png',
            height: 60,
          ),
        );
      },
    );*/

class PlaceRes {
  List? htmlAttributions;
  List<Results>? results;
  String? status;

  PlaceRes({this.htmlAttributions, this.results, this.status});

  PlaceRes.fromJson(Map<String, dynamic> json) {
    if (json['html_attributions'] != null) {
      htmlAttributions = [];
      json['html_attributions'].forEach((v) {
        htmlAttributions!.add(v);
      });
    }
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
    status = json['status'];
  }
}

class Results {
  String? formattedAddress;
  Geometry? geometry;
  String? icon;
  String? iconBackgroundColor;
  String? iconMaskBaseUri;
  String? name;
  String? placeId;
  String? reference;
  List<String>? types;

  Results(
      {this.formattedAddress,
      this.geometry,
      this.icon,
      this.iconBackgroundColor,
      this.iconMaskBaseUri,
      this.name,
      this.placeId,
      this.reference,
      this.types});

  Results.fromJson(Map<String, dynamic> json) {
    formattedAddress = json['formatted_address'];
    geometry =
        json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null;
    icon = json['icon'];
    iconBackgroundColor = json['icon_background_color'];
    iconMaskBaseUri = json['icon_mask_base_uri'];
    name = json['name'];
    placeId = json['place_id'];
    reference = json['reference'];
    types = json['types'].cast<String>();
  }
}

class Geometry {
  Location? _location;
  LatLng? latLang;
  Viewport? viewport;

  Geometry({this.latLang, this.viewport});

  Geometry.fromJson(Map<String, dynamic> json) {
    if (json['location'] != null) {
      _location = Location.fromJson(json['location']);
      latLang = LatLng(_location?.lat ?? 0, _location?.lng ?? 0);
    }
    viewport =
        json['viewport'] != null ? Viewport.fromJson(json['viewport']) : null;
  }
}

class Location {
  double? lat;
  double? lng;

  Location({this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class Viewport {
  Location? northeast;
  Location? southwest;

  Viewport({this.northeast, this.southwest});

  Viewport.fromJson(Map<String, dynamic> json) {
    northeast =
        json['northeast'] != null ? Location.fromJson(json['northeast']) : null;
    southwest =
        json['southwest'] != null ? Location.fromJson(json['southwest']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (northeast != null) {
      data['northeast'] = northeast!.toJson();
    }
    if (southwest != null) {
      data['southwest'] = southwest!.toJson();
    }
    return data;
  }
}

Future<void> onPickAddress({
  required int? addressId,
  required LatLng selectedPlace,
}) async {
  final addressUpdateLocationResponse =
      await AddressRepository().getAddressUpdateLocationResponse(
    addressId,
    selectedPlace.latitude,
    selectedPlace.longitude,
  );

  if (addressUpdateLocationResponse.result == false) {
    ToastComponent.showDialog(
      addressUpdateLocationResponse.message,
      isError: true,
    );
    return;
  }

  ToastComponent.showDialog(
    addressUpdateLocationResponse.message,
    color: Colors.green,
  );
}
