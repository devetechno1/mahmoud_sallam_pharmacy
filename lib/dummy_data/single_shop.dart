import 'package:active_ecommerce_cms_demo_app/app_config.dart';

class SingleShop {
  String? logo;
  List<String>? sliders;
  String? name;
  String? address;
  double? rating;

  SingleShop({
    this.logo,
    this.sliders,
    this.name,
    this.address,
    this.rating,
  });
}

List<String> sliders = [
  AppImages.ss1,
  AppImages.ss2,
  AppImages.ss3,
  AppImages.ss4,
];

SingleShop singleShop = SingleShop(
  logo: AppImages.sSeven,
  sliders: sliders,
  name: "A-Z Imports & Exports International",
  address: "92/A Johnson street, New Arlington, NY Usa",
  rating: 3.0,
);
