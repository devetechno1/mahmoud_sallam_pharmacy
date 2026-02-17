import 'dart:convert';

import 'package:active_ecommerce_cms_demo_app/helpers/color_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PopupBannerModel extends Equatable {
  final String? title;
  final String? summary;
  final String? btnLink;
  final String? btnText;
  final String? btnTextColor;
  final Color? btnBackgroundColor;
  final String? image;

  const PopupBannerModel({
    this.title,
    this.summary,
    this.btnLink,
    this.btnText,
    this.btnTextColor,
    this.btnBackgroundColor,
    this.image,
  });

  factory PopupBannerModel.fromMap(Map<String, dynamic> data) =>
      PopupBannerModel(
        title: data['title'] as String?,
        summary: data['summary'] as String?,
        btnLink: data['btn_link'] as String?,
        btnText: data['btn_text'] as String?,
        btnTextColor: data['btn_text_color'] as String?,
        btnBackgroundColor:
            ColorHelper.stringToColor(data['btn_background_color']) ??
                Colors.white,
        image: data['image'] as String?,
      );

  // Map<String, dynamic> toMap() => {
  //       'title': title,
  //       'summary': summary,
  //       'btn_link': btnLink,
  //       'btn_text': btnText,
  //       'btn_text_color': btnTextColor,
  //       'btn_background_color': btnBackgroundColor,
  //       'image': image,
  //     };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [PopupBannerModel].
  factory PopupBannerModel.fromJson(String data) {
    return PopupBannerModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  // /// `dart:convert`
  // ///
  // /// Converts [PopupBannerModel] to a JSON string.
  // String toJson() => json.encode(toMap());

  PopupBannerModel copyWith({
    String? title,
    String? summary,
    String? btnLink,
    String? btnText,
    String? btnTextColor,
    Color? btnBackgroundColor,
    String? image,
  }) {
    return PopupBannerModel(
      title: title ?? this.title,
      summary: summary ?? this.summary,
      btnLink: btnLink ?? this.btnLink,
      btnText: btnText ?? this.btnText,
      btnTextColor: btnTextColor ?? this.btnTextColor,
      btnBackgroundColor: btnBackgroundColor ?? this.btnBackgroundColor,
      image: image ?? this.image,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      title,
      summary,
      btnLink,
      btnText,
      btnTextColor,
      btnBackgroundColor,
      image,
    ];
  }
}
