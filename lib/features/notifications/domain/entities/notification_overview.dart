import 'package:equatable/equatable.dart';

import '../../../stock/domain/entities/stock.dart';

class MeasurementReminder extends Equatable {
  final int childId;
  final String name;
  final String gender;
  final DateTime birthDate;
  final DateTime? lastMeasuredAt;
  final int? daysSinceLast;
  final double? lastWeight;
  final double? lastHeight;

  const MeasurementReminder({
    required this.childId,
    required this.name,
    required this.gender,
    required this.birthDate,
    this.lastMeasuredAt,
    this.daysSinceLast,
    this.lastWeight,
    this.lastHeight,
  });

  @override
  List<Object?> get props => [
    childId,
    name,
    gender,
    birthDate,
    lastMeasuredAt,
    daysSinceLast,
    lastWeight,
    lastHeight,
  ];
}

class NotificationOverview extends Equatable {
  final List<Stock> expiring;
  final List<Stock> lowStock;
  final List<MeasurementReminder> measurementDue;

  const NotificationOverview({
    required this.expiring,
    required this.lowStock,
    required this.measurementDue,
  });

  bool get isEmpty =>
      expiring.isEmpty && lowStock.isEmpty && measurementDue.isEmpty;

  @override
  List<Object?> get props => [expiring, lowStock, measurementDue];
}