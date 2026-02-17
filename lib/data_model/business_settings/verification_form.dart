import 'dart:convert';

import 'package:equatable/equatable.dart';

class VerificationForm extends Equatable {
  final String? type;
  final String? label;

  const VerificationForm({this.type, this.label});

  factory VerificationForm.fromMap(Map<String, dynamic> data) {
    return VerificationForm(
      type: data['type'] as String?,
      label: data['label'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'label': label,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [VerificationForm].
  factory VerificationForm.fromJson(String data) {
    return VerificationForm.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [VerificationForm] to a JSON string.
  String toJson() => json.encode(toMap());

  VerificationForm copyWith({
    String? type,
    String? label,
  }) {
    return VerificationForm(
      type: type ?? this.type,
      label: label ?? this.label,
    );
  }

  @override
  List<Object?> get props => [type, label];
}
