// import 'dart:convert';
// import 'package:active_ecommerce_cms_demo_app/app_config.dart';
// import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
// import 'package:active_ecommerce_cms_demo_app/riaj/single_banner/model.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class PhotoProvider with ChangeNotifier {
//   List<SingleBanner> _singleBanner = [];

//   List<SingleBanner> get singleBanner => _singleBanner;

//   Future<void> fetchPhotos() async {
//     const url =
//         "${AppConfig.BASE_URL}/banners-two"; // Replace with your actual API
//     final response = await http.get(Uri.parse(url), headers: {
//       "App-Language": app_language.$!,
//       "Authorization": "Bearer ${access_token.$}",
//       "Content-Type": "application/json",
//       "System-key": "${AppConfig.system_key}"
//     });

//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       if (responseData['success']) {
//         _singleBanner = (responseData['data'] as List)
//             .map((data) => SingleBanner.fromJson(data))
//             .toList();
//         notifyListeners();
//       }
//     }
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';

import 'package:active_ecommerce_cms_demo_app/single_banner/model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhotoProvider with ChangeNotifier {
  Future<List<SingleBanner>> fetchPhotos(String slug) async {
    final url = "${AppConfig.BASE_URL}/$slug";

    try {
      final response = await http.get(Uri.parse(url), headers: {
        "App-Language": app_language.$ ?? 'en',
        "Authorization":
            access_token.$ != null ? "Bearer ${access_token.$}" : '',
        "Content-Type": "application/json",
        "System-key": AppConfig.system_key
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success']) {
          return (responseData['data'] as List)
              .map((data) => SingleBanner.fromJson(data))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
            "Failed to load photos. Status code: ${response.statusCode}");
      }
    } on TimeoutException catch (_) {
      print("Request timed out");
      return [];
    } catch (error) {
      print("Error fetching photos: $error");
      return [];
    }
  }
}
