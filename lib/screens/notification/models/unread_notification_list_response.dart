// To parse this JSON data, do
//
//     final unreadNotificationListResponse = unreadNotificationListResponseFromJson(jsonString);

import 'dart:convert';

UnreadNotificationListResponse unreadNotificationListResponseFromJson(
        String str) =>
    UnreadNotificationListResponse.fromJson(json.decode(str));

String unreadNotificationListResponseToJson(
        UnreadNotificationListResponse data) =>
    json.encode(data.toJson());

class UnreadNotificationListResponse {
  int? count;
  UnreadNotificationListResponseData? data;

  UnreadNotificationListResponse({
    this.count,
    this.data,
  });

  factory UnreadNotificationListResponse.fromJson(Map<String, dynamic> json) =>
      UnreadNotificationListResponse(
        count: json["count"],
        data: json["data"] == null
            ? null
            : UnreadNotificationListResponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "data": data?.toJson(),
      };
}

class UnreadNotificationListResponseData {
  List<Datum>? data;

  UnreadNotificationListResponseData({
    this.data,
  });

  factory UnreadNotificationListResponseData.fromJson(
          Map<String, dynamic> json) =>
      UnreadNotificationListResponseData(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? type;
  DatumData? data;
  String? notificationText;
  String? image;
  String? date;

  Datum({
    this.type,
    this.data,
    this.notificationText,
    this.image,
    this.date,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        type: json["type"],
        data: json["data"] == null ? null : DatumData.fromJson(json["data"]),
        notificationText: json["notification_text"],
        image: json["image"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "data": data?.toJson(),
        "notification_text": notificationText,
        "image": image,
        "date": date,
      };
}

class DatumData {
  String? link;

  DatumData({
    this.link,
  });

  factory DatumData.fromJson(Map<String, dynamic> json) => DatumData(
        link: json["link"],
      );

  Map<String, dynamic> toJson() => {
        "link": link,
      };
}
