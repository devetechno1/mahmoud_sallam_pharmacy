import 'package:flutter/material.dart';

class MenuItemModel {
  final String title;
  final String image;
  final VoidCallback onTap;
  final Color textColor;
  final Color backgroundColor;

  MenuItemModel(
      {required this.image,
      required this.onTap,
      required this.textColor,
      required this.backgroundColor,
      required this.title});
}
