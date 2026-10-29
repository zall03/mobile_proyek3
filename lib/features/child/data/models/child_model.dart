import '../../../../core/utils/hpk.dart';
import '../../domain/entities/child.dart';

class ChildModel extends Child {
  const ChildModel({
    required super.id,
    required super.name,
    required super.gender,
    required super.birthDate,
    super.hpht,
    super.hpl,
    super.pregnancyId,
    super.birthWeightKg,
    super.birthLengthCm,
    super.birthHeadCircumferenceCm,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as String,
      name: json['name'] as String,
      gender: (json['gender'] as String?) ?? 'male',
      birthDate: DateTime.parse(json['birth_date'] as String),
      hpht: _date(json['hpht']),
      hpl: _date(json['hpl']),
      pregnancyId: _text(json['pregnancy_id']),
      birthWeightKg: _number(json['birth_weight_kg']),
      birthLengthCm: _number(json['birth_length_cm']),
      birthHeadCircumferenceCm: _number(json['birth_head_circumference_cm']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'birth_date': isoDate(birthDate),
      if (hpht != null) 'hpht': isoDate(hpht!),
      if (hpl != null) 'hpl': isoDate(hpl!),
      if (birthWeightKg != null) 'birth_weight_kg': birthWeightKg,
      if (birthLengthCm != null) 'birth_length_cm': birthLengthCm,
      if (birthHeadCircumferenceCm != null)
        'birth_head_circumference_cm': birthHeadCircumferenceCm,
    };
  }

  static DateTime? _date(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(
      value.length >= 10 ? value.substring(0, 10) : value,
    );
  }

  static double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.'));
    return null;
  }

  static String? _text(dynamic value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
