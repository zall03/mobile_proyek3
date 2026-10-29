import '../../domain/entities/notification_overview.dart';

class MeasurementReminderModel extends MeasurementReminder {
  const MeasurementReminderModel({
    required super.childId,
    required super.name,
    required super.gender,
    super.birthDate,
    super.lastMeasuredAt,
    super.daysSinceLast,
    super.lastWeight,
    super.lastHeight,
  });

  factory MeasurementReminderModel.fromJson(Map<String, dynamic> json) {
    return MeasurementReminderModel(
      childId: json['child_id'] as String,
      name: json['name'] as String,
      gender: (json['gender'] as String?) ?? 'male',
      birthDate: _date(json['birth_date']),
      lastMeasuredAt: _date(json['last_measured_at']),
      daysSinceLast: (json['days_since_last'] as num?)?.toInt(),
      lastWeight: (json['last_weight'] as num?)?.toDouble(),
      lastHeight: (json['last_height'] as num?)?.toDouble(),
    );
  }

  static DateTime? _date(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
