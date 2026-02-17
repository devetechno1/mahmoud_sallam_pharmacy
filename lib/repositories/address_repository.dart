import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/address_add_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/address_delete_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/address_make_default_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/address_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/address_update_in_cart_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/address_update_location_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/address_update_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/city_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/country_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/shipping_cost_response.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/state_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/middlewares/banned_user.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/api-request.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressRepository {
  Future<AddressResponse> getAddressList() async {
    const String url = ("${AppConfig.BASE_URL}/user/shipping/address");
    final response = await ApiRequest.get(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!,
      },
    );
    return addressResponseFromJson(response.body);
  }

  Future<({Country country, MyState state, City city})?> getAddressDataByLatLng(
      LatLng latLng) async {
    const String url = ("${AppConfig.BASE_URL}/location/city-by-coords");
    final response = await ApiRequest.post(
      url: url,
      headers: {"Authorization": ""},
      body: jsonEncode({"lat": latLng.latitude, "lng": latLng.longitude}),
    );
    final json = jsonDecode(response.body);
    return json['success'] == true
        ? (
            country: Country.fromJson(json['country_id']),
            state: MyState.fromJson(json['state_id']),
            city: City.fromJson(json['city_id']),
          )
        : null;
  }

  Future<dynamic> getHomeDeliveryAddress() async {
    const String url = ("${AppConfig.BASE_URL}/get-home-delivery-address");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        middleware: BannedUser());
    return addressResponseFromJson(response.body);
  }

  Future<AddressAddResponse> getAddressAddResponse({
    required String address,
    required int? country_id,
    required int? state_id,
    required int? city_id,
    required String postal_code,
    required String phone,
    required double latitude,
    required double longitude,
  }) async {
    final postBody = jsonEncode({
      "user_id": "${user_id.$}",
      "address": "$address",
      "country_id": "$country_id",
      "state_id": "$state_id",
      "city_id": "$city_id",
      "postal_code": "$postal_code",
      "phone": "$phone",
      "latitude": "$latitude",
      "longitude": "$longitude"
    });

    const String url = ("${AppConfig.BASE_URL}/user/shipping/create");
    final response = await ApiRequest.post(
      url: url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$!
      },
      body: postBody,
      middleware: BannedUser(),
    );
    return addressAddResponseFromJson(response.body);
  }

  Future<dynamic> getAddressUpdateResponse(
      {required int? id,
      required String address,
      required int? country_id,
      required int? state_id,
      required int? city_id,
      required String postal_code,
      required String phone}) async {
    final postBody = jsonEncode({
      "id": "$id",
      "user_id": "${user_id.$}",
      "address": "$address",
      "country_id": "$country_id",
      "state_id": "$state_id",
      "city_id": "$city_id",
      "postal_code": "$postal_code",
      "phone": "$phone"
    });

    const String url = ("${AppConfig.BASE_URL}/user/shipping/update");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: postBody,
        middleware: BannedUser());
    return addressUpdateResponseFromJson(response.body);
  }

  Future<dynamic> getAddressUpdateLocationResponse(
    int? id,
    double? latitude,
    double? longitude,
  ) async {
    final postBody = jsonEncode({
      "id": "$id",
      "user_id": "${user_id.$}",
      "latitude": "$latitude",
      "longitude": "$longitude"
    });

    const String url = ("${AppConfig.BASE_URL}/user/shipping/update-location");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: postBody,
        middleware: BannedUser());
    return addressUpdateLocationResponseFromJson(response.body);
  }

  Future<AddressMakeDefaultResponse> getAddressMakeDefaultResponse(
    int? id,
  ) async {
    final postBody = jsonEncode({
      "id": "$id",
    });

    const String url = ("${AppConfig.BASE_URL}/user/shipping/make_default");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}"
        },
        body: postBody,
        middleware: BannedUser());
    return addressMakeDefaultResponseFromJson(response.body);
  }

  Future<dynamic> getAddressDeleteResponse(
    int? id,
  ) async {
    final String url = ("${AppConfig.BASE_URL}/user/shipping/delete/$id");
    final response = await ApiRequest.get(
        url: url,
        headers: {
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        middleware: BannedUser());

    return addressDeleteResponseFromJson(response.body);
  }

  Future<CityResponse> getCityListByState({state_id = 0, name = ""}) async {
    final String url =
        ("${AppConfig.BASE_URL}/cities-by-state/$state_id?name=$name");
    final response = await ApiRequest.get(url: url, middleware: BannedUser());
    return cityResponseFromJson(response.body);
  }

  Future<dynamic> getStateListByCountry({country_id = 0, name = ""}) async {
    final String url =
        ("${AppConfig.BASE_URL}/states-by-country/$country_id?name=$name");
    final response = await ApiRequest.get(url: url, middleware: BannedUser());
    return myStateResponseFromJson(response.body);
  }

  Future<CountryResponse> getCountryList({name = ""}) async {
    final String url = ("${AppConfig.BASE_URL}/countries?name=$name");
    final response = await ApiRequest.get(url: url, middleware: BannedUser());
    return countryResponseFromJson(response.body);
  }

  Future<dynamic> getShippingCostResponse({shipping_type = ""}) async {
    // var post_body = jsonEncode({"seller_list": shipping_type});
    String postBody;

    const String url = ("${AppConfig.BASE_URL}/shipping_cost");
    if (AppConfig.businessSettingsData.guestCheckoutStatus && !is_logged_in.$) {
      postBody = jsonEncode(
          {"temp_user_id": temp_user_id.$, "seller_list": shipping_type});
    } else {
      postBody =
          jsonEncode({"user_id": user_id.$, "seller_list": shipping_type});
    }
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!,
        },
        body: postBody,
        middleware: BannedUser());
    return shippingCostResponseFromJson(response.body);
  }

  Future<dynamic> getAddressUpdateInCartResponse(
      {int? address_id = 0, int pickup_point_id = 0}) async {
    final postBody = jsonEncode({
      "address_id": "$address_id",
      "pickup_point_id": "$pickup_point_id",
      "user_id": "${user_id.$}"
    });

    const String url = ("${AppConfig.BASE_URL}/update-address-in-cart");
    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: postBody,
        middleware: BannedUser());

    return addressUpdateInCartResponseFromJson(response.body);
  }

  Future<dynamic> getShippingTypeUpdateInCartResponse(
      {required int shipping_id, shipping_type = "home_delivery"}) async {
    final postBody = jsonEncode({
      "shipping_id": "$shipping_id",
      "shipping_type": "$shipping_type",
    });

    const String url = ("${AppConfig.BASE_URL}/update-shipping-type-in-cart");

    final response = await ApiRequest.post(
        url: url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$!
        },
        body: postBody,
        middleware: BannedUser());

    return addressUpdateInCartResponseFromJson(response.body);
  }
}
