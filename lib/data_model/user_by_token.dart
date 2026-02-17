// To parse this JSON data, do
//
//     final userByTokenResponse = userByTokenResponseFromJson(jsonString);

import 'dart:convert';

UserByTokenResponse userByTokenResponseFromJson(String str) =>
    UserByTokenResponse.fromJson(json.decode(str));

String userByTokenResponseToJson(UserByTokenResponse data) =>
    json.encode(data.toJson());

class UserByTokenResponse {
  UserByTokenResponse({
    this.result,
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.avatar_original,
    this.phone,
  });

  bool? result;
  int? id;
  String? name;
  String? email;
  String? avatar;
  String? avatar_original;
  String? phone;

  factory UserByTokenResponse.fromJson(Map<String, dynamic> json) =>
      UserByTokenResponse(
        result: json["result"],
        id: json["id"],
        name: json["name"],
        email: json["email"],
        avatar: json["avatar"],
        avatar_original: json["avatar_original"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "id": id,
        "name": name,
        "email": email,
        "avatar": avatar,
        "avatar_original": avatar_original,
        "phone": phone,
      };
}
