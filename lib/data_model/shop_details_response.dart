// To parse this JSON data, do
//
//     final shopDetailsResponse = shopDetailsResponseFromJson(jsonString);
// https://app.quicktype.io/
import 'dart:convert';

ShopDetailsResponse shopDetailsResponseFromJson(String str) =>
    ShopDetailsResponse.fromJson(json.decode(str));

String shopDetailsResponseToJson(ShopDetailsResponse data) =>
    json.encode(data.toJson());

class ShopDetailsResponse {
  ShopDetailsResponse({
    this.shop,
    this.success,
    this.status,
  });

  Shop? shop;
  bool? success;
  int? status;

  factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) =>
      ShopDetailsResponse(
        shop: Shop.fromJson(json["data"]),
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": shop?.toJson(),
        "success": success,
        "status": status,
      };
}

class Shop {
  Shop({
    this.id,
    this.user_id,
    this.name,
    this.logo,
    this.sliders,
    this.address,
    this.facebook,
    this.google,
    this.twitter,
    this.true_rating,
    this.rating,
  });

  int? id;
  int? user_id;
  String? name;
  String? logo;
  List<String>? sliders;
  String? address;
  String? facebook;
  String? google;
  String? twitter;
  int? true_rating;
  int? rating;

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        id: json["id"],
        user_id: json["user_id"],
        name: json["name"],
        logo: json["logo"],
        sliders: List<String>.from(json["sliders"].map((x) => x)),
        address: json["address"],
        facebook: json["facebook"],
        google: json["google"],
        twitter: json["twitter"],
        true_rating: json["true_rating"],
        rating: json["rating"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": user_id,
        "name": name,
        "logo": logo,
        "sliders":
            sliders == null ? [] : List<dynamic>.from(sliders!.map((x) => x)),
        "address": address,
        "facebook": facebook,
        "google": google,
        "twitter": twitter,
        "true_rating": true_rating,
        "rating": rating,
      };
}
