import 'package:equatable/equatable.dart';

import '../../../../core/utils/hpk.dart';

class Child extends Equatable {
  final String id;
  final String name;
  final String gender;
  final DateTime birthDate;
  final DateTime? hpht;
  final DateTime? hpl;
  final String? pregnancyId;
  final double? birthWeightKg;
  final double? birthLengthCm;
  final double? birthHeadCircumferenceCm;

  const Child({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    this.hpht,
    this.hpl,
    this.pregnancyId,
    this.birthWeightKg,
    this.birthLengthCm,
    this.birthHeadCircumferenceCm,
  });

  int get ageInDays {
    final days = daysSince(birthDate);
    return days < 0 ? 0 : days;
  }

  int get ageInMonths {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
  }

  int get ageInYears => ageInMonths ~/ 12;

  /// Bila HPHT tidak diisi, pakai perkiraan 280 hari sebelum lahir.
  DateTime get effectiveHpht => hpht ?? estimatedHphtFromBirth(birthDate);

  bool get isEstimatedHpht => hpht == null;

  int get hpkDay => hpkDayOf(effectiveHpht);

  double get hpkProgress => hpkProgressOf(effectiveHpht);

  bool get isHpkComplete => hpkIsComplete(effectiveHpht);

  @override
  List<Object?> get props => [
    id,
    name,
    gender,
    birthDate,
    hpht,
    hpl,
    pregnancyId,
    birthWeightKg,
    birthLengthCm,
    birthHeadCircumferenceCm,
  ];
}

class ChildMeasurement extends Equatable {
  final String id;
  final String childId;
  final double? weight;
  final double? height;
  final double? headCircumference;
  final String? notes;
  final DateTime measuredAt;

  const ChildMeasurement({
    required this.id,
    required this.childId,
    required this.measuredAt,
    this.weight,
    this.height,
    this.headCircumference,
    this.notes,
  });

  bool get hasAnyValue =>
      weight != null || height != null || headCircumference != null;

  @override
  List<Object?> get props => [
    id,
    childId,
    weight,
    height,
    headCircumference,
    notes,
    measuredAt,
  ];
}

class NutritionTarget extends Equatable {
  final int id;
  final int childId;
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final double ironMg;
  final double zincMg;
  final double vitaminAMcg;
  final double vitaminCMg;

  const NutritionTarget({
    required this.id,
    required this.childId,
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.ironMg,
    required this.zincMg,
    required this.vitaminAMcg,
    required this.vitaminCMg,
  });

  @override
  List<Object?> get props => [
    id,
    childId,
    calories,
    proteinG,
    fatG,
    carbsG,
    ironMg,
    zincMg,
    vitaminAMcg,
    vitaminCMg,
  ];
}
