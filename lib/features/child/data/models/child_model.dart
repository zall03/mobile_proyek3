import '../../domain/entities/child.dart';

class ChildModel extends Child {
  const ChildModel({
    required super.id,
    required super.name,
    required super.gender,
    required super.birthDate,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as int,
      name: json['name'] as String,
      gender: json['gender'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'birth_date': birthDate.toIso8601String(),
    };
  }
}
