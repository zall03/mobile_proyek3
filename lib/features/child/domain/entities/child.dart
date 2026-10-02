import 'package:equatable/equatable.dart';

class Child extends Equatable {
  final int id;
  final String name;
  final String gender;
  final DateTime birthDate;

  const Child({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
  });

  int get ageInMonths {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
  }

  int get ageInYears => ageInMonths ~/ 12;

  @override
  List<Object?> get props => [id, name, gender, birthDate];
}

class ChildMeasurement extends Equatable {
  final int id;
  final int childId;
  final double weight;
  final double height;
  final DateTime measuredAt;

  const ChildMeasurement({
    required this.id,
    required this.childId,
    required this.weight,
    required this.height,
    required this.measuredAt,
  });

  @override
  List<Object?> get props => [id, childId, weight, height, measuredAt];
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
