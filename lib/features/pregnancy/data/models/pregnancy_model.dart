import '../../domain/entities/pregnancy.dart';

class PregnancyModel extends Pregnancy {
  const PregnancyModel({
    required super.id,
    required super.motherName,
    required super.hphtDate,
    required super.dueDate,
    super.status,
  });

  factory PregnancyModel.fromJson(Map<String, dynamic> json) {
    return PregnancyModel(
      id: json['id'] as String,
      motherName: json['mother_name'] as String? ?? 'Bunda',
      hphtDate: DateTime.parse(json['hpht_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String? ?? 'active',
    );
  }
}
