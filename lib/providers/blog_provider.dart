import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/blog_mode.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BlogProvider with ChangeNotifier {
  List<BlogModel> _blogs = [];

  List<BlogModel> get blogs => List.unmodifiable(_blogs);

  bool isLoading = false;

  Future<void> fetchBlogs([bool refresh = true]) async {
    isLoading = true;

    if (refresh) notifyListeners();

    try {
      const String url = ("${AppConfig.BASE_URL}/blog-list");
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "System-Key": AppConfig.system_key
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
       debugPrint( const JsonEncoder.withIndent('  ').convert(jsonDecode(response.body)));
        final List<BlogModel> loadedBlogs = [];
        jsonData['blogs']['data'].forEach((blogData) {
          loadedBlogs.add(BlogModel.fromJson(blogData));
        });
        _blogs = loadedBlogs;
      } else {
        throw 'Failed to load blogs';
      }
    } catch (e) {
      print(e);
    }
    isLoading = false;
    notifyListeners();
  }
}
