import 'dart:convert';
import 'package:equatable/equatable.dart';

TodaysDealBannerResponse todaysDealBannerResponseFromJson(String str) =>
    TodaysDealBannerResponse.fromJson(json.decode(str));

String todaysDealBannerResponseToJson(TodaysDealBannerResponse data) =>
    json.encode(data.toJson());

class TodaysDealBannerResponse extends Equatable {
  const TodaysDealBannerResponse({
    this.todaysDealBannerSmall,
    this.todaysDealBanner,
  });

  final String? todaysDealBannerSmall;
  final String? todaysDealBanner;

  factory TodaysDealBannerResponse.fromJson(Map<String, dynamic> json) =>
      TodaysDealBannerResponse(
        todaysDealBannerSmall: json['todays_deal_banner_small'],
        todaysDealBanner: json['todays_deal_banner'],
      );

  Map<String, dynamic> toJson() => {
        "todays_deal_banner_small": todaysDealBannerSmall,
        "todays_deal_banner": todaysDealBanner,
      };

  @override
  List<Object?> get props => [ todaysDealBanner, todaysDealBannerSmall];
}
