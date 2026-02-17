import 'package:active_ecommerce_cms_demo_app/app_config.dart';

class Messenger {
  String? id;
  String? image;
  String? name;
  Messenger({this.id, this.image, this.name});
}

final List<Messenger> messengerList = [
  Messenger(
    id: "1",
    image: AppImages.s1,
    name: "Fashion Vendor",
  ),
  Messenger(
    id: "2",
    image: AppImages.loginRegistration,
    name: "Deve Techno Store",
  ),
  Messenger(
    id: "3",
    image: AppImages.s3,
    name: "Computer Zone",
  ),
  Messenger(
    id: "4",
    image: AppImages.s4,
    name: "New Women Fashion",
  ),
  Messenger(
    id: "5",
    image: AppImages.s5,
    name: "Motorcycle Club",
  ),
  Messenger(
    id: "6",
    image: AppImages.s4,
    name: "New Balance",
  ),
  Messenger(
    id: "7",
    image: AppImages.s7,
    name: "Tiffany and Co.",
  ),
  Messenger(
    id: "8",
    image: AppImages.s8,
    name: "Ugg Australia",
  ),
  Messenger(
    id: "9",
    image: AppImages.s9,
    name: "Vans of The wall",
  ),
  Messenger(
    id: "10",
    image: AppImages.s10,
    name: "Newman Fashion",
  ),
  Messenger(
    id: "11",
    image: AppImages.s11,
    name: "Reddis Fashion",
  ),
  Messenger(
    id: "12",
    image: AppImages.s12,
    name: "FASHION ZARIS",
  ),
];
