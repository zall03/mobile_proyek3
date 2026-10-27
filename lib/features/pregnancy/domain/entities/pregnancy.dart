import 'package:equatable/equatable.dart';

/// Usia, trimester, dan HPL dihitung dari HPHT (Naegele, 280 hari) supaya
/// tampilannya tidak bergantung pada jam server.
class Pregnancy extends Equatable {
  final String id;
  final String motherName;
  final DateTime hphtDate;
  final DateTime dueDate;
  final String status;

  const Pregnancy({
    required this.id,
    required this.motherName,
    required this.hphtDate,
    required this.dueDate,
    this.status = 'active',
  });

  static const gestationDays = 280;

  int get ageInDays {
    final days = DateTime.now()
        .difference(DateTime(hphtDate.year, hphtDate.month, hphtDate.day))
        .inDays;
    return days < 0 ? 0 : days;
  }

  int get ageInWeeks => ageInDays ~/ 7;

  int get trimester {
    if (ageInWeeks <= 13) return 1;
    if (ageInWeeks <= 27) return 2;
    return 3;
  }

  int get daysRemaining {
    final remaining = gestationDays - ageInDays;
    return remaining < 0 ? 0 : remaining;
  }

  double get progressPercent {
    final percent = ageInDays / gestationDays * 100;
    return percent > 100 ? 100 : percent;
  }

  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [id, motherName, hphtDate, dueDate, status];
}
