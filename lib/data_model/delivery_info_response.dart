// To parse this JSON data, do
//
//     final deliveryInfoResponse = deliveryInfoResponseFromJson(jsonString);

import 'dart:convert';

import 'cart_response.dart';
import 'product_details_response.dart';

List<DeliveryInfoResponse> deliveryInfoResponseFromJson(String str) =>
    List<DeliveryInfoResponse>.from(
        json.decode(str).map((x) => DeliveryInfoResponse.fromJson(x)));

String deliveryInfoResponseToJson(List<DeliveryInfoResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeliveryInfoResponse {
  DeliveryInfoResponse({
    this.name,
    this.ownerId,
    this.cartItems,
    this.carriers,
    this.pickupPoints,
  });

  String? name;
  int? ownerId;
  List<CartItem>? cartItems;
  Carriers? carriers;
  List<PickupPoint>? pickupPoints;

  factory DeliveryInfoResponse.fromJson(Map<String, dynamic> json) =>
      DeliveryInfoResponse(
        name: json["name"],
        ownerId: json["owner_id"],
        cartItems: List<CartItem>.from(
            json["cart_items"].map((x) => CartItem.fromJson(x))),
        carriers: Carriers.fromJson(json["carriers"]),
        pickupPoints: List<PickupPoint>.from(
            json["pickup_points"].map((x) => PickupPoint.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "owner_id": ownerId,
        "cart_items": List<dynamic>.from(cartItems!.map((x) => x.toJson())),
        "carriers": carriers!.toJson(),
        "pickup_points":
            List<dynamic>.from(pickupPoints!.map((x) => x.toJson())),
      };
}

class Carriers {
  Carriers({
    this.data,
  });

  List<Datum>? data;

  factory Carriers.fromJson(Map<String, dynamic> json) => Carriers(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    this.id,
    this.name,
    this.logo,
    this.transitTime,
    this.freeShipping,
    this.transitPrice,
  });

  var id;
  String? name;
  String? logo;
  var transitTime;
  bool? freeShipping;
  String? transitPrice;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        logo: json["logo"],
        transitTime: json["transit_time"],
        freeShipping: json["free_shipping"],
        transitPrice: json["transit_price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "logo": logo,
        "transit_time": transitTime,
        "free_shipping": freeShipping,
        "transit_price": transitPrice,
      };
}

class CartItem {
  CartItem({
    this.id,
    this.ownerId,
    this.userId,
    this.productId,
    this.productQuantity,
    this.productPrice,
    this.productName,
    this.productThumbnailImage,
    this.isDigital,
    this.isPrescription,
    this.prescriptionImages = const [],
    this.wholesales = const [],
  });

  int? id;
  int? ownerId;
  int? userId;
  int? productId;
  double? productPrice;
  int? productQuantity;
  String? productName;
  String? productThumbnailImage;
  bool? isDigital;
  bool? isPrescription;
  List<PrescriptionImages> prescriptionImages;

  List<Wholesale> wholesales;

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json["id"],
        ownerId: json["owner_id"],
        userId: json["user_id"],
        productId: json["product_id"],
        productName: json["product_name"],
        productPrice: double.tryParse('${json["product_price"]}'),
        productQuantity: int.tryParse("${json["product_quantity"]}"),
        productThumbnailImage: json["product_thumbnail_image"],
        isDigital: json["product_is_digital"],
        isPrescription: "${json["is_prescription"]}" == "1",
        prescriptionImages: json["prescription_images"] == null
            ? []
            : List<PrescriptionImages>.from(
                (json["prescription_images"] as List)
                    .map((x) => PrescriptionImages.fromJson(x))),
        wholesales: json["wholesale_variation"] == null
            ? []
            : List<Wholesale>.from((json["wholesale_variation"] as List)
                .map((x) => Wholesale.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "owner_id": ownerId,
        "user_id": userId,
        "product_id": productId,
        "product_name": productName,
        "product_price": productPrice,
        "product_quantity": productQuantity,
        "product_thumbnail_image": productThumbnailImage,
        "wholesale_variation":
            List<dynamic>.from(wholesales.map((x) => x.toJson())),
      };
}

class PickupPoint {
  PickupPoint({
    this.id,
    this.staffId,
    this.name,
    this.address,
    this.phone,
    this.pickUpStatus,
    this.cashOnPickupStatus,
  });

  var id;
  var staffId;
  String? name;
  String? address;
  String? phone;
  var pickUpStatus;
  dynamic cashOnPickupStatus;

  factory PickupPoint.fromJson(Map<String, dynamic> json) => PickupPoint(
        id: json["id"],
        staffId: json["staff_id"],
        name: json["name"],
        address: json["address"],
        phone: json["phone"],
        pickUpStatus: json["pick_up_status"],
        cashOnPickupStatus: json["cash_on_pickup_status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "staff_id": staffId,
        "name": name,
        "address": address,
        "phone": phone,
        "pick_up_status": pickUpStatus,
        "cash_on_pickup_status": cashOnPickupStatus,
      };
}
