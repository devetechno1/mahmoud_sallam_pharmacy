// To parse this JSON VariantData, do
//
//     final variantResponse = variantResponseFromJson(jsonString);

import 'dart:convert';

VariantResponse variantResponseFromJson(String str) =>
    VariantResponse.fromJson(json.decode(str));

String variantResponseToJson(VariantResponse VariantData) =>
    json.encode(VariantData.toJson());

class VariantResponse {
  bool? result;
  VariantData? variantData;

  VariantResponse({
    this.result,
    this.variantData,
  });

  factory VariantResponse.fromJson(Map<String, dynamic> json) =>
      VariantResponse(
        result: json["result"],
        variantData:
            json["data"] == null ? null : VariantData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "data": variantData!.toJson(),
      };
}

class VariantData {
  String? price;
  double basePrice;
  int? stock;
  int? inCart;
  String? stockTxt;
  bool digital;
  String? variant;
  String? variation;
  int? maxLimit;
  int? inStock;
  String? image;

  VariantData({
    this.price,
    this.basePrice = 0.0,
    this.stock,
    this.inCart,
    this.stockTxt,
    this.digital = false,
    this.variant,
    this.variation,
    this.maxLimit,
    this.inStock,
    this.image,
  });

  factory VariantData.fromJson(Map<String, dynamic> json) => VariantData(
        price: json["price"],
        basePrice: double.tryParse(json["base_price"].toString()) ?? 0,
        stock: int.tryParse(json["stock"].toString()) ?? 0,
        inCart: int.tryParse(json["in_cart"].toString()),
        stockTxt: "${json["stock_txt"]}",
        digital: "${json["digital"]}" == '1',
        variant: json["variant"],
        variation: json["variation"],
        maxLimit: int.tryParse(json["max_limit"].toString()) ?? 0,
        inStock: int.tryParse(json["in_stock"].toString()) ?? 0,
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "base_price": basePrice,
        "stock": stock,
        "in_cart": inCart,
        "digital": digital,
        "variant": variant,
        "variation": variation,
        "max_limit": maxLimit,
        "in_stock": inStock,
        "image": image,
      };
}
