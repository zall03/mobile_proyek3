import '../../domain/entities/pregnancy.dart';

class PregnancyModel extends Pregnancy {
  const PregnancyModel({
    required super.id,
    required super.motherName,
    required super.hphtDate,
    required super.dueDate,
    super.status,
    super.deliveryDate,
    super.notes,
  });

  factory PregnancyModel.fromJson(Map<String, dynamic> json) {
    return PregnancyModel(
      id: json['id'] as String,
      motherName: json['mother_name'] as String? ?? 'Bunda',
      hphtDate: DateTime.parse(json['hpht_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String? ?? 'active',
      deliveryDate: _date(json['delivery_date']),
      notes: _text(json['notes']),
    );
  }

  static DateTime? _date(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(
      value.length >= 10 ? value.substring(0, 10) : value,
    );
  }

  static String? _text(dynamic value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
