// To parse this JSON data, do
//
//     final addressResponse = addressResponseFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

AddressResponse addressResponseFromJson(String str) =>
    AddressResponse.fromJson(json.decode(str));

String addressResponseToJson(AddressResponse data) =>
    json.encode(data.toJson());

class AddressResponse {
  AddressResponse({
    this.addresses,
    this.success,
    this.status,
  });

  List<Address>? addresses;
  bool? success;
  int? status;

  factory AddressResponse.fromJson(Map<String, dynamic> json) =>
      AddressResponse(
        addresses: List<Address>.from(
            (json["data"]?.map((x) => Address.fromJson(x))) ?? []),
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(addresses!.map((x) => x.toJson())),
        "success": success,
        "status": status,
      };
}

class Address extends Equatable {
  const Address(
      {this.id,
      this.user_id,
      this.address,
      this.country_id,
      this.state_id,
      this.city_id,
      this.country_name,
      this.state_name,
      this.city_name,
      this.postal_code,
      this.phone,
      this.set_default,
      this.location_available,
      this.lat,
      this.lang});

  final int? id;
  final int? user_id;
  final String? address;
  final int? country_id;
  final int? state_id;
  final int? city_id;
  final String? country_name;
  final String? state_name;
  final String? city_name;
  final String? postal_code;
  final String? phone;
  final int? set_default;
  final bool? location_available;
  final double? lat;
  final double? lang;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"],
        user_id: json["user_id"],
        address: json["address"],
        country_id: json["country_id"],
        state_id: json["state_id"],
        city_id: json["city_id"],
        country_name: json["country_name"],
        state_name: json["state_name"],
        city_name: json["city_name"],
        postal_code: json["postal_code"] ?? "",
        phone: json["phone"] ?? "",
        set_default: json["set_default"],
        location_available: json["location_available"],
        lat: double.tryParse("${json["lat"]}"),
        lang: double.tryParse("${json["lang"]}"),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": user_id,
        "address": address,
        "country_id": country_id,
        "state_id": state_id,
        "city_id": city_id,
        "country_name": country_name,
        "state_name": state_name,
        "city_name": city_name,
        "postal_code": postal_code,
        "phone": phone,
        "set_default": set_default,
        "location_available": location_available,
        "lat": lat,
        "lang": lang,
      };

  @override
  List<Object?> get props => [
        id,
        user_id,
        address,
        country_id,
        state_id,
        city_id,
        country_name,
        state_name,
        city_name,
        postal_code,
        phone,
        set_default,
        location_available,
        lat,
        lang,
      ];
}
