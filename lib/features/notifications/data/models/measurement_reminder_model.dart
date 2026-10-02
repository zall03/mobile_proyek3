import '../../domain/entities/notification_overview.dart';

class MeasurementReminderModel extends MeasurementReminder {
  const MeasurementReminderModel({
    required super.childId,
    required super.name,
    required super.gender,
    required super.birthDate,
    super.lastMeasuredAt,
    super.daysSinceLast,
    super.lastWeight,
    super.lastHeight,
  });

  factory MeasurementReminderModel.fromJson(Map<String, dynamic> json) {
    return MeasurementReminderModel(
      childId: json['child_id'] as int,
      name: json['name'] as String,
      gender: (json['gender'] as String?) ?? 'male',
      birthDate: DateTime.parse(json['birth_date'] as String),
      lastMeasuredAt: json['last_measured_at'] != null
          ? DateTime.parse(json['last_measured_at'] as String)
          : null,
      daysSinceLast: json['days_since_last'] as int?,
      lastWeight: (json['last_weight'] as num?)?.toDouble(),
      lastHeight: (json['last_height'] as num?)?.toDouble(),
    );
  }
}