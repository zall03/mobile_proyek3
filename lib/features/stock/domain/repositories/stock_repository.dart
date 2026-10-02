import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ingredient.dart';
import '../entities/ingredient_category.dart';
import '../entities/stock.dart';

abstract class StockRepository {
  Future<Either<Failure, List<IngredientCategory>>> getCategories();
  Future<Either<Failure, List<Ingredient>>> getIngredients({
    String? query,
    int? categoryId,
  });
  Future<Either<Failure, List<Stock>>> getStocks({
    int? categoryId,
    String? status,
  });
  Future<Either<Failure, Stock>> addStock({
    required int ingredientId,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  });
  Future<Either<Failure, Stock>> updateStock({
    required int id,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  });
  Future<Either<Failure, void>> deleteStock({required int id});
}