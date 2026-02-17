import 'package:equatable/equatable.dart';

class OTPProviderModel extends Equatable {
  final int? id;
  final String type;
  final String? sendOTPText;
  final String? image;

  const OTPProviderModel({
    required this.id,
    required this.type,
    required this.sendOTPText,
    required this.image,
  });

  factory OTPProviderModel.fromJson(Map json) {
    return OTPProviderModel(
      id: int.tryParse("${json["id"]}"),
      type: "${json["type"]}",
      sendOTPText: "${json["send_otp_text"]}",
      image: "${json["image"]}",
    );
  }

  static List<OTPProviderModel> parseList(List listJson) {
    final List<OTPProviderModel> temp = [];

    for (Map j in listJson) {
      temp.add(OTPProviderModel.fromJson(j));
    }

    return temp;
  }

  @override
  List<Object?> get props => [id, type, sendOTPText, image];
}
