import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../../app_config.dart';
import '../../custom/btn.dart';
import '../../helpers/handle_permissions.dart';
import '../../main.dart';
import '../../my_theme.dart';
import '../../other_config.dart';
import '../map_location.dart';

class MapLocationWidget extends StatefulWidget {
  const MapLocationWidget(
      {super.key,
      this.latitude,
      this.longitude,
      this.miniMapWithScroll = false,
      this.onPlacePicked});
  final double? longitude;
  final double? latitude;
  final bool miniMapWithScroll;
  final void Function(LatLng?)? onPlacePicked;

  @override
  State<MapLocationWidget> createState() => MapLocationWidgetState();
}

class MapLocationWidgetState extends State<MapLocationWidget> {
  static LatLng kInitialPosition = AppConfig.businessSettingsData.initPlace;

  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    kInitialPosition = LatLng(
      widget.latitude ?? AppConfig.businessSettingsData.initPlace.latitude,
      widget.longitude ?? AppConfig.businessSettingsData.initPlace.longitude,
    );
    initLocation(kInitialPosition);

    if (widget.latitude == null && widget.longitude == null) {
      HandlePermissions.getCurrentLocation().then(
        (value) {
          if (value != null) {
            kInitialPosition = LatLng(value.latitude, value.longitude);
            initLocation(kInitialPosition);
          }
        },
      );
    }
  }

  void initLocation(LatLng initPosition) {
    selectedPlace = initPosition;
    widget.onPlacePicked?.call(initPosition);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(initPosition, 14),
      ),
    );
  }

  void openFullScreenMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationScreen(
          latitude: selectedPlace.latitude,
          longitude: selectedPlace.longitude,
        ),
      ),
    ).then(
      (value) {
        if (!mounted) return;
        if (value is LatLng) {
          _controller?.animateCamera(CameraUpdate.newLatLng(value));
          setState(() {
            selectedPlace = value;
            widget.onPlacePicked?.call(selectedPlace);
          });
        }
      },
    );
  }

  late LatLng selectedPlace;
  bool isCameraIdle = false;
  bool isLoadingFormattedAddress = true;
  String? formattedAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: kInitialPosition,
                    zoom: 10,
                  ),
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  indoorViewEnabled: true,
                  mapToolbarEnabled: true,
                  scrollGesturesEnabled: widget.miniMapWithScroll,
                  zoomGesturesEnabled: widget.miniMapWithScroll,
                  rotateGesturesEnabled: widget.miniMapWithScroll,
                  tiltGesturesEnabled: widget.miniMapWithScroll,
                  onTap: widget.miniMapWithScroll
                      ? null
                      : (_) => openFullScreenMap(),
                  onCameraIdle: () async {
                    isCameraIdle = true;
                    formattedAddress = null;
                    setState(() {});

                    try {
                      final List<Placemark> temp =
                          await placemarkFromCoordinates(
                              selectedPlace.latitude, selectedPlace.longitude);
                      formattedAddress =
                          '${temp.first.street}, ${temp.first.locality}, ${temp.first.administrativeArea}, ${temp.first.country}';
                    } catch (e) {
                      print("Error in map location widget e = $e");
                    }

                    if (!mounted) return;

                    isLoadingFormattedAddress = false;
                    // print("onPlacePicked..."+result.toString());
                    // Navigator.pop(context);
                    setState(() {});
                  },
                  onCameraMove: (position) {
                    selectedPlace = position.target;
                    widget.onPlacePicked?.call(selectedPlace);
                    isCameraIdle = false;
                    setState(() {});
                  },
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) =>
                      _controller = controller,
                ),
              ),
              Align(
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isCameraIdle ? 0.7 : 1.1,
                  child: const _MarkImage(),
                ),
              ),
              Positioned(
                right: AppDimensions.paddingSmall,
                bottom: AppDimensions.paddingSmall,
                child: InkWell(
                  onTap: openFullScreenMap,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white70,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ],
                    ),
                    child: const Icon(Icons.fullscreen, color: Colors.black45),
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: Text(
            formattedAddress == null
                ? 'your_delivery_location'.tr(context: context)
                : formattedAddress!,
            maxLines: 2,
            style: const TextStyle(color: MyTheme.medium_grey),
          ),
        )
      ],
    );
  }
}

class MapLocationScreen extends StatefulWidget {
  const MapLocationScreen({super.key, this.latitude, this.longitude});
  final double? longitude;
  final double? latitude;

  @override
  State<MapLocationScreen> createState() => MapLocationScreenState();
}

class MapLocationScreenState extends State<MapLocationScreen> {
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

    if (widget.latitude != null && widget.longitude != null) {
      setInitialLocation();
    } else {
      setDummyInitialLocation();
    }
  }

  setInitialLocation() {
    kInitialPosition = LatLng(
        widget.latitude ?? AppConfig.businessSettingsData.initPlace.latitude,
        widget.longitude ?? AppConfig.businessSettingsData.initPlace.longitude);
    setState(() {});
  }

  setDummyInitialLocation() {
    kInitialPosition = AppConfig.businessSettingsData.initPlace;
    setState(() {});
  }

  Future<void> onTapPickHere() async {
    Navigator.pop(context, selectedPlace);
  }

  Future<void> getCurrentLocation() async {
    final Position? value = await HandlePermissions.getCurrentLocation();
    if (value != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(value.latitude, value.longitude), 14),
      );
    }
  }

  LatLng selectedPlace = kInitialPosition;
  bool isCameraIdle = false;
  bool isLoadingFormattedAddress = true;
  String? formattedAddress;
  final FocusNode fieldNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context);
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.small(
          onPressed: getCurrentLocation,
          foregroundColor: Colors.white,
          child: const Icon(Icons.my_location_rounded),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniEndDocked,
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
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onCameraIdle: () async {
                // locationController.updateMapPosition(_cameraPosition, false, null, context);
                // await onTapPickHere();

                isCameraIdle = true;
                formattedAddress = null;
                setState(() {});

                try {
                  final List<Placemark> temp = await placemarkFromCoordinates(
                    selectedPlace.latitude,
                    selectedPlace.longitude,
                  );
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
              onMapCreated: (GoogleMapController controller) =>
                  _controller = controller,
            ),
            Positioned(
              height: 50,
              bottom: 80.0,
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
                        onPressed: onTapPickHere,
                        isLoading: formattedAddress == null,
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
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusHalfSmall),
                      );
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        obscureText: false,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
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
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: FocusScope.of(context).hasFocus
                                ? Theme.of(context).primaryColor
                                : MyTheme.textfield_grey,
                          ),
                          suffixIcon: const Icon(
                            Icons.search_rounded,
                            color: MyTheme.textfield_grey,
                          ),
                        ),
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
                child: const _MarkImage(),
              ),
            )
          ],
        ),
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
    } catch (e, st) {
      recordError(e, st);
      print("Error e = $e");
      return [];
    }
  }
}

class _MarkImage extends StatelessWidget {
  const _MarkImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.deliveryMapIcon,
      height: 60,
      colorBlendMode: BlendMode.srcIn,
      color: Theme.of(context).primaryColor,
    );
  }
}
