import 'package:active_ecommerce_cms_demo_app/app_config.dart';

class Shop {
  String? id;
  String? image;
  String? name;

  Shop({
    this.id,
    this.image,
    this.name,
  });
}

final List<Shop> shopList = [
  Shop(id: "1", image: AppImages.s1, name: "Baby and Mom"),
  Shop(id: "2", image: AppImages.s2, name: "Clarks"),
  Shop(
    id: "3",
    image: AppImages.s3,
    name: "Computer Seller",
  ),
  Shop(id: "4", image: AppImages.s4, name: "Dress House Private Limited"),
  Shop(id: "5", image: AppImages.s5, name: "Maddison"),
  Shop(id: "6", image: AppImages.s6, name: "New Balance"),
  Shop(id: "7", image: AppImages.s7, name: "Tiffany and Co."),
  Shop(id: "8", image: AppImages.s8, name: "UGG Australia"),
  Shop(id: "9", image: AppImages.s9, name: "Vans \"of the wall\""),
  Shop(id: "10", image: AppImages.s10, name: "Wear Dream Fashion"),
  Shop(id: "11", image: AppImages.s11, name: "Zara"),
  Shop(id: "12", image: AppImages.s12, name: "Zaris Fasion"),
];
