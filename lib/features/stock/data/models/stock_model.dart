import '../../domain/entities/stock.dart';
import 'ingredient_model.dart';

class StockModel extends Stock {
  const StockModel({
    required super.id,
    required super.ingredient,
    required super.quantity,
    required super.unit,
    required super.status,
    super.expiryDate,
    super.daysLeft,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['id'] as int,
      ingredient: IngredientModel.fromJson(
        json['ingredient'] as Map<String, dynamic>,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'] as String)
          : null,
      status: StockStatus.fromValue(json['status'] as String?),
      daysLeft: json['days_left'] as int?,
    );
  }
}