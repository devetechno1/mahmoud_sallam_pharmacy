// // To parse this JSON data, do
// //
// //     final categoryResponse = categoryResponseFromJson(jsonString);
// //https://app.quicktype.io/
// import 'dart:convert';

// CategoryResponse categoryResponseFromJson(String str) =>
//     CategoryResponse.fromJson(json.decode(str));

// String categoryResponseToJson(CategoryResponse data) =>
//     json.encode(data.toJson());

// class CategoryResponse {
//   CategoryResponse({
//     this.categories,
//     this.success,
//     this.status,
//   });

//   List<Category>? categories;
//   bool? success;
//   int? status;

//   factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
//       CategoryResponse(
//         categories:
//             List<Category>.from(json["data"].map((x) => Category.fromJson(x))),
//         success: json["success"],
//         status: json["status"],
//       );

//   Map<String, dynamic> toJson() => {
//         "data": List<dynamic>.from(categories!.map((x) => x.toJson())),
//         "success": success,
//         "status": status,
//       };
// }

// class Category {
//   Category({
//     this.id,
//     this.name,
//     this.slug,
//     this.banner,
//     this.icon,
//     this.number_of_children,
//     this.links,
//   });

//   int? id;
//   String? name;
//   String? slug;
//   String? banner;
//   String? icon;
//   int? number_of_children;
//   Links? links;

//   factory Category.fromJson(Map<String, dynamic> json) => Category(
//         id: json["id"],
//         name: json["name"],
//         slug: json["slug"],
//         banner: json["banner"],
//         icon: json["icon"],
//         number_of_children: json["number_of_children"],
//         links: Links.fromJson(json["links"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "slug": slug,
//         "banner": banner,
//         "icon": icon,
//         "number_of_children": number_of_children,
//         "links": links!.toJson(),
//       };
// }

// class Links {
//   Links({
//     this.products,
//     this.subCategories,
//   });

//   String? products;
//   String? subCategories;

//   factory Links.fromJson(Map<String, dynamic> json) => Links(
//         products: json["products"],
//         subCategories: json["sub_categories"],
//       );

//   Map<String, dynamic> toJson() => {
//         "products": products,
//         "sub_categories": subCategories,
//       };
// }
import 'dart:convert';

import 'package:equatable/equatable.dart';

CategoryResponse categoryResponseFromJson(String str) =>
    CategoryResponse.fromJson(json.decode(str));

String categoryResponseToJson(CategoryResponse data) =>
    json.encode(data.toJson());

class CategoryResponse {
  CategoryResponse({
    this.categories,
    this.success,
    this.status,
  });

  List<Category>? categories;
  bool? success;
  int? status;

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      CategoryResponse(
        categories: json["data"] != null
            ? List<Category>.from(json["data"].map((x) => Category.fromJson(x)))
            : null, // Handle null case for 'data'
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": categories != null
            ? List<dynamic>.from(categories!.map((x) => x.toJson()))
            : null, // Handle null case for categories
        "success": success,
        "status": status,
      };
}

class Category extends Equatable {
  const Category({
    this.id,
    this.name,
    this.slug,
    this.banner,
    this.icon,
    this.number_of_children,
    this.links,
    this.coverImage, // Added cover_image
  });

  final int? id;
  final String? name;
  final String? slug;
  final String? banner;
  final String? icon;
  final int? number_of_children;
  final Links? links;
  final String? coverImage; // Added cover_image

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        banner: json["banner"],
        icon: json["icon"],
        number_of_children: json["number_of_children"],
        links: json["links"] != null ? Links.fromJson(json["links"]) : null,
        coverImage: json["cover_image"], // Added cover_image
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "banner": banner,
        "icon": icon,
        "number_of_children": number_of_children,
        "links": links != null
            ? links!.toJson()
            : null, // Handle null case for links
        "cover_image": coverImage, // Added cover_image
      };

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        banner,
        icon,
        number_of_children,
        links?.toJson(),
        coverImage,
      ];
}

class Links {
  Links({
    this.products,
    this.subCategories,
  });

  String? products;
  String? subCategories;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        products: json["products"],
        subCategories: json["sub_categories"],
      );

  Map<String, dynamic> toJson() => {
        "products": products,
        "sub_categories": subCategories,
      };
}
