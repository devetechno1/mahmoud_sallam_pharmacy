// To parse this JSON data, do
//
//     final cartResponse = cartResponseFromJson(jsonString);

import 'dart:convert';
import 'dart:math';

import 'product_details_response.dart';

CartResponse cartResponseFromJson(String str) =>
    CartResponse.fromJson(json.decode(str));

String cartResponseToJson(CartResponse data) => json.encode(data.toJson());

class CartResponse {
  String? grandTotal;
  List<Datum>? data;

  CartResponse({
    this.grandTotal,
    this.data,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) => CartResponse(
        grandTotal: json["grand_total"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "grand_total": grandTotal,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? name;
  int? ownerId;
  String? subTotal;
  List<CartItem> cartItems = [];

  Datum({
    this.name,
    this.ownerId,
    this.subTotal,
    required this.cartItems,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        name: json["name"],
        ownerId: json["owner_id"],
        subTotal: json["sub_total"],
        cartItems: json["cart_items"] == null
            ? []
            : List<CartItem>.from(
                json["cart_items"]!.map((x) => CartItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "owner_id": ownerId,
        "sub_total": subTotal,
        "cart_items": cartItems == null
            ? []
            : List<dynamic>.from(cartItems!.map((x) => x.toJson())),
      };
}

class CartItem {
  int? id;
  int? ownerId;
  int? userId;
  int? productId;
  String? productName;
  int? auctionProduct;
  String? productThumbnailImage;
  String? variation;
  String? price;
  String? currencySymbol;
  String? tax;
  ProductUnit? productUnit;
  // double? shippingCost;
  int quantity;
  int? lowerLimit;
  int upperLimit;
  int? _maxQty;
  bool isDigital;
  bool isPrescription;
  bool isLoading;
  List<PrescriptionImages> prescriptionImages;
  List<Wholesale> wholesales;

  int get maxQuantity =>
      isDigital ? 999999 : min(upperLimit, _maxQty ?? upperLimit);
  int get minQuantity => lowerLimit ?? 1;

  bool get isNotAvailable => maxQuantity < quantity || quantity < minQuantity;

  CartItem({
    this.id,
    this.ownerId,
    this.userId,
    this.productId,
    this.productName,
    this.auctionProduct,
    this.productThumbnailImage,
    this.variation,
    this.price,
    this.currencySymbol,
    this.tax,
    this.productUnit,
    // this.shippingCost,
    this.quantity = 0,
    this.lowerLimit,
    this.upperLimit = 0,
    this.isDigital = false,
    this.isPrescription = false,
    this.prescriptionImages = const [],
    int? maxQty,
    this.isLoading = false,
    this.wholesales = const [],
  }) {
    _maxQty = maxQty;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json["id"],
        ownerId: json["owner_id"],
        maxQty: json["max_qty"],
        productUnit: json["product_unit"] == null
            ? null
            : ProductUnit.fromJson(json["product_unit"]),
        userId: json["user_id"],
        productId: json["product_id"],
        productName: json["product_name"],
        auctionProduct: int.tryParse("${json["auction_product"]}"),
        productThumbnailImage: json["product_thumbnail_image"],
        variation: json["variation"],
        price: json["price"],
        currencySymbol: json["currency_symbol"],
        tax: json["tax"],
        // shippingCost: json["shipping_cost"],
        quantity: json["quantity"] ?? 0,
        lowerLimit: json["lower_limit"],
        upperLimit: json["upper_limit"] ?? 0,
        isDigital: "${json["is_digital"]}" == "1",
        isPrescription: "${json["is_prescription"]}" == "1",
        prescriptionImages: json["prescription_images"] is List
            ? (json["prescription_images"] as List)
                .map((e) => PrescriptionImages.fromJson(e))
                .toList()
            : [],
        wholesales: json["wholesale_variation"] == null
            ? []
            : List<Wholesale>.from((json["wholesale_variation"] as List)
                .map((x) => Wholesale.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "owner_id": ownerId,
        "max_qty": _maxQty,
        "user_id": userId,
        "product_id": productId,
        "product_name": productName,
        "auction_product": auctionProduct,
        "product_thumbnail_image": productThumbnailImage,
        "variation": variation,
        "price": price,
        "currency_symbol": currencySymbol,
        "tax": tax,
        "product_unit": productUnit?.toJson(),
        // "shipping_cost": shippingCost,
        "quantity": quantity,
        "lower_limit": lowerLimit,
        "upper_limit": upperLimit,
        "is_prescription": isPrescription ? "1" : "0",
        "is_digital": isDigital ? "1" : "0",
        "wholesale_variation":
            List<dynamic>.from(wholesales.map((x) => x.toJson())),
      };
}

class PrescriptionImages {
  final String id;
  final String image;

  const PrescriptionImages({
    required this.id,
    required this.image,
  });

  factory PrescriptionImages.fromJson(Map<String, dynamic> json) =>
      PrescriptionImages(
        id: json["id"],
        image: json["path"],
      );
}
