import 'package:flutter/material.dart';
import '../../app_config.dart';
import '../../screens/home/widgets/featured_category/featured_category_circular.dart';
import '../../screens/home/widgets/featured_category/featured_category_horizontal.dart';
import '../../screens/home/widgets/featured_category/featured_category_vertical.dart';
Widget buildFeaturedCategory(BuildContext context) {
    return CategoryAppStyle.fromValue(
            AppConfig.businessSettingsData.categoryAppStyle)
        .widget;
  }

enum CategoryAppStyle {
  vertical('3', widget: CategoryListVertical(crossAxisCount: 4)),
  horizontal('1',widget:  CategoryListHorizontal()),
      circular('2',
      widget:  CategoryListCircular());


  final String valueString;
  final Widget widget;

  const CategoryAppStyle(this.valueString, {required this.widget});

  factory CategoryAppStyle.fromValue(String? v) {
    for (final s in values) {
      if (s.valueString == (v ?? '').trim()) return s;
    }
    return CategoryAppStyle.vertical; // default
  }
}
