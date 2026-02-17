// To parse this JSON data, do
//
//     final paymentTypeResponse = paymentTypeResponseFromJson(jsonString);

import 'dart:convert';

List<PaymentTypeResponse> paymentTypeResponseFromJson(String str) =>
    List<PaymentTypeResponse>.from(
        json.decode(str).map((x) => PaymentTypeResponse.fromJson(x)));

String paymentTypeResponseToJson(List<PaymentTypeResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PaymentTypeResponse {
  PaymentTypeResponse({
    this.payment_type,
    this.payment_type_key,
    this.image,
    this.name,
    this.title,
    this.offline_payment_id,
    this.integrations = const [],
    this.details,
  });

  String? payment_type;
  String? payment_type_key;
  String? image;
  String? name;
  String? title;
  int? offline_payment_id;
  String? details;
  List<SubPayment> integrations;

  factory PaymentTypeResponse.fromJson(Map<String, dynamic> json) =>
      PaymentTypeResponse(
        payment_type: json["payment_type"],
        payment_type_key: json["payment_type_key"],
        image: json["image"],
        name: json["name"],
        title: json["title"],
        offline_payment_id: json["offline_payment_id"],
        details: json["details"],
        integrations: json["integrations"] == null
            ? <SubPayment>[]
            : () {
                final List<SubPayment> integrations = <SubPayment>[];
                for (final e in (json["integrations"] as List<dynamic>)) {
                  final s = SubPayment.fromJson(e);
                  if (s.status == true) integrations.add(s);
                }

                return integrations;
              }(),
      );

  Map<String, dynamic> toJson() => {
        "payment_type": payment_type,
        "payment_type_key": payment_type_key,
        "image": image,
        "name": name,
        "title": title,
        "offline_payment_id": offline_payment_id,
        "details": details,
        "integrations": integrations.map((sub) => sub.toJson()).toList(),
      };
}

class SubPayment {
  String? type;
  String? name;
  String? value;
  bool? status;
  String? image;

  SubPayment({this.type, this.name, this.value, this.status, this.image});

  SubPayment.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    name = json['name'];
    value = json['value']?.toString();
    status = "${json['status']}" == "1";
    image = json['img_full_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['type'] = type;
    data['name'] = name;
    data['value'] = value;
    data['status'] = status == true ? "1" : "0";
    data['img_full_path'] = image;
    return data;
  }
}
