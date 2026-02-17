import 'package:active_ecommerce_cms_demo_app/app_config.dart';

class PaymentMethod {
  String? id;
  String? key;
  String? name;
  String? image;

  PaymentMethod({this.id, this.key, this.name, this.image});
}

List<PaymentMethod> paymentMethodList = [
  PaymentMethod(
      id: "1",
      key: "paypal",
      name: "Checkout with Paypal",
      image: AppImages.paypal),
  PaymentMethod(
      id: "2",
      key: "stripe",
      name: "Checkout with Stripe",
      image: AppImages.stripe),
  PaymentMethod(
      id: "3",
      key: "flutterwave",
      name: "Checkout with Flutterwave",
      image: AppImages.flutterwave),
  PaymentMethod(
      id: "4",
      key: "iyzico",
      name: "Checkout with IYZICO",
      image: AppImages.iyzico),
  PaymentMethod(
      id: "5",
      key: "mpesa",
      name: "Checkout with Mpesa",
      image: AppImages.mpesa),
  PaymentMethod(
      id: "6",
      key: "payfast",
      name: "Checkout with Payfast",
      image: AppImages.payfast),
  PaymentMethod(
      id: "7",
      key: "payhere",
      name: "Checkout with Payhere",
      image: AppImages.payhere),
  PaymentMethod(
      id: "8",
      key: "paystack",
      name: "Checkout with Paystack",
      image: AppImages.ngenius),
  PaymentMethod(
      id: "9",
      key: "paytm",
      name: "Checkout with Paytm",
      image: AppImages.paytm),
  PaymentMethod(
      id: "10", key: "wallet", name: "Wallet Payment", image: AppImages.wallet),
  PaymentMethod(
      id: "11",
      key: "cash_on_delivery",
      name: "Cash on Delivery",
      image: AppImages.cod),
];
