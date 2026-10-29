import '../../../../core/utils/hpk.dart';
import '../../domain/entities/child.dart';

class ChildMeasurementModel extends ChildMeasurement {
  const ChildMeasurementModel({
    required super.id,
    required super.childId,
    required super.measuredAt,
    super.weight,
    super.height,
    super.headCircumference,
    super.notes,
  });

  factory ChildMeasurementModel.fromJson(Map<String, dynamic> json) {
    return ChildMeasurementModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      weight: _number(json['weight']),
      height: _number(json['height']),
      headCircumference: _number(json['head_circumference_cm']),
      notes: _text(json['notes']),
      measuredAt: DateTime.parse(json['measured_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (headCircumference != null) 'head_circumference_cm': headCircumference,
      if (notes != null) 'notes': notes,
      'measured_at': isoDate(measuredAt),
    };
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
