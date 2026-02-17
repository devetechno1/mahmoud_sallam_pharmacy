// To parse this JSON data, do
//
//     final allNotificationListResponse = allNotificationListResponseFromJson(jsonString);

import 'dart:convert';

AllNotificationListResponse allNotificationListResponseFromJson(String str) =>
    AllNotificationListResponse.fromJson(json.decode(str));

String allNotificationListResponseToJson(AllNotificationListResponse data) =>
    json.encode(data.toJson());

class AllNotificationListResponse {
  List<Datum>? data;
  bool? success;
  int? status;

  AllNotificationListResponse({
    this.data,
    this.success,
    this.status,
  });

  factory AllNotificationListResponse.fromJson(Map<String, dynamic> json) =>
      AllNotificationListResponse(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "success": success,
        "status": status,
      };
}

class Datum {
  String? id;
  bool? isChecked;
  String? type;
  Data? data;
  String? notificationText;
  String? image;
  String? date;

  Datum({
    this.isChecked,
    this.id,
    this.type,
    this.data,
    this.notificationText,
    this.image,
    this.date,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        isChecked: json["isChecked"],
        type: json["type"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        notificationText: json["notification_text"],
        image: json["image"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "isChecked": isChecked,
        "type": type,
        "data": data?.toJson(),
        "notification_text": notificationText,
        "image": image,
        "date": date,
      };
}

class Data {
  String? link;
  int? orderId;
  String? orderCode;
  int? userId;
  int? sellerId;
  String? status;

  Data({
    this.link,
    this.orderId,
    this.orderCode,
    this.userId,
    this.sellerId,
    this.status,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        link: json["link"],
        orderId: int.tryParse("${json["order_id"]}"),
        orderCode: json["order_code"],
        userId: int.tryParse("${json["user_id"]}"),
        sellerId: int.tryParse("${json["seller_id"]}"),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "link": link,
        "order_id": orderId,
        "order_code": orderCode,
        "user_id": userId,
        "seller_id": sellerId,
        "status": status,
      };
}
