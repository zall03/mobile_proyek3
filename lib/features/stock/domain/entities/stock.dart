import 'package:equatable/equatable.dart';

import 'ingredient.dart';

enum StockStatus {
  fresh('fresh', 'Aman'),
  expiring('expiring', 'Segera Habis'),
  expired('expired', 'Kedaluwarsa');

  const StockStatus(this.value, this.label);

  final String value;
  final String label;

  static StockStatus fromValue(String? value) {
    return StockStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => StockStatus.fresh,
    );
  }
}

class Stock extends Equatable {
  final int id;
  final Ingredient ingredient;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final StockStatus status;
  final int? daysLeft;

  const Stock({
    required this.id,
    required this.ingredient,
    required this.quantity,
    required this.unit,
    required this.status,
    this.expiryDate,
    this.daysLeft,
  });

  @override
  List<Object?> get props => [
    id,
    ingredient,
    quantity,
    unit,
    expiryDate,
    status,
    daysLeft,
  ];
}