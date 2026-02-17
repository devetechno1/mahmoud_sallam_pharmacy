import 'package:active_ecommerce_cms_demo_app/app_config.dart';

class FlashDeal {
  String? id;
  String? name;
  String? image;
  int? end_date;

  FlashDeal({this.id, this.name, this.image, this.end_date});
}

List<FlashDeal> flashDealList = [
  FlashDeal(
      id: "1",
      name: "Mega Flash Deal",
      image: AppImages.fd1,
      end_date: 1640553743),
  FlashDeal(
      id: "2",
      name: "Maha Flash Deal For Eid",
      image: AppImages.fd2,
      end_date: 1611696143),
  FlashDeal(
      id: "3",
      name: "Supreme Dhamaka Fiesta Of The Year",
      image: AppImages.fd3,
      end_date: 1609017743),
  FlashDeal(
      id: "4",
      name: "Supreme Dhamaka Fiesta Of The Year",
      image: AppImages.fd3,
      end_date: 1610918380),
  FlashDeal(
      id: "5",
      name: "Supreme Dhamaka Fiesta Of The Year",
      image: AppImages.fd3,
      end_date: 1610918380),
  FlashDeal(
      id: "6",
      name: "Supreme Dhamaka Fiesta Of The Year",
      image: AppImages.fd3,
      end_date: 1611936656),
];
