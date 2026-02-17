import 'package:active_ecommerce_cms_demo_app/app_config.dart';

class FeaturedCategory {
  String? id;
  String? image;
  String? name;
  bool? has_children;

  FeaturedCategory({this.id, this.image, this.name, this.has_children});
}

final List<FeaturedCategory> featuredCategoryList = [
  FeaturedCategory(
      id: "1",
      image: AppImages.fc1,
      name: "Men Clothing & Fashion",
      has_children: true),
  FeaturedCategory(
      id: "2",
      image: AppImages.fc2,
      name: "Computer & Accessories",
      has_children: true),
  FeaturedCategory(
      id: "3",
      image: AppImages.fc3,
      name: "Automobile & Motorcycle",
      has_children: false),
  FeaturedCategory(
      id: "4", image: AppImages.fc4, name: "Kids & toy", has_children: true),
  FeaturedCategory(
      id: "5",
      image: AppImages.fc5,
      name: "Sports & outdoor",
      has_children: true),
  FeaturedCategory(
      id: "6",
      image: AppImages.fc6,
      name: "Cellphones & Tabs",
      has_children: true),
  FeaturedCategory(
      id: "7",
      image: AppImages.fc7,
      name: "Beauty, Health & Hair",
      has_children: true),
  FeaturedCategory(
      id: "8",
      image: AppImages.fc8,
      name: "Home Improvement & Tools",
      has_children: false),
  FeaturedCategory(
      id: "9",
      image: AppImages.fc9,
      name: "Home decoration & Appliance",
      has_children: true),
  FeaturedCategory(
      id: "10",
      image: AppImages.fc10,
      name: "Farming Equipments and Tractors",
      has_children: true),
];
