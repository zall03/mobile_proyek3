import '../../domain/entities/child.dart';

class ChildMeasurementModel extends ChildMeasurement {
  const ChildMeasurementModel({
    required super.id,
    required super.childId,
    required super.weight,
    required super.height,
    required super.measuredAt,
  });

  factory ChildMeasurementModel.fromJson(Map<String, dynamic> json) {
    return ChildMeasurementModel(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      measuredAt: DateTime.parse(json['measured_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'height': height,
        'measured_at': measuredAt.toIso8601String().split('T').first,
      };
}