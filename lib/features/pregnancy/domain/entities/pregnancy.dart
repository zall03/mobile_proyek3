import 'package:equatable/equatable.dart';

import '../../../../core/utils/hpk.dart';

/// Profil kehamilan. Usia, trimester, HPL, dan progres 1000 HPK dihitung dari
/// HPHT supaya tampilan konsisten tanpa bergantung pada jam server.
class Pregnancy extends Equatable {
  final String id;
  final String motherName;
  final DateTime hphtDate;
  final DateTime dueDate;
  final String status;
  final DateTime? deliveryDate;
  final String? notes;

  const Pregnancy({
    required this.id,
    required this.motherName,
    required this.hphtDate,
    required this.dueDate,
    this.status = 'active',
    this.deliveryDate,
    this.notes,
  });

  static const gestationDays = 280;

  int get ageInDays => gestationalDaysOf(hphtDate);

  int get ageInWeeks => gestationalWeeksOf(hphtDate);

  int get trimester => trimesterOf(hphtDate);

  int get daysRemaining => daysUntilDueOf(hphtDate);

  double get progressPercent => gestationProgressOf(hphtDate) * 100;

  int get hpkDay => hpkDayOf(hphtDate);

  double get hpkProgress => hpkProgressOf(hphtDate);

  bool get isHpkComplete => hpkIsComplete(hphtDate);

  bool get isActive => status == 'active' || status == 'hamil';

  bool get isDelivered => status == 'delivered' || status == 'lahir';

  @override
  List<Object?> get props => [
    id,
    motherName,
    hphtDate,
    dueDate,
    status,
    deliveryDate,
    notes,
  ];
}
