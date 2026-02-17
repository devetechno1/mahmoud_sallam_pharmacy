import 'package:equatable/equatable.dart';

class SingleBanner extends Equatable {
  final String photo;
  final String url;

  const SingleBanner({required this.photo, required this.url});

  factory SingleBanner.fromJson(Map<String, dynamic> json) {
    return SingleBanner(
      photo: json['photo'] ?? '', // Fallback to an empty string if null
      url: json['url'] ?? '', // Fallback to an empty string if null
    );
  }

  @override
  List<Object?> get props => [photo, url];
}
