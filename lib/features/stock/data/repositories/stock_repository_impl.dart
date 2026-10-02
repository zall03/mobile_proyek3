import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/ingredient_category.dart';
import '../../domain/entities/stock.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_remote_datasource.dart';
import '../models/ingredient_category_model.dart';
import '../models/ingredient_model.dart';
import '../models/stock_model.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDatasource remoteDatasource;

  StockRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<IngredientCategory>>> getCategories() async {
    try {
      final categoryModels = await remoteDatasource.fetchCategories();
      final categories = categoryModels
          .map(
            (json) =>
                IngredientCategoryModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Ingredient>>> getIngredients({
    String? query,
    int? categoryId,
  }) async {
    try {
      final ingredientModels = await remoteDatasource.fetchIngredients(
        query: query,
        categoryId: categoryId,
      );
      final ingredients = ingredientModels
          .map(
            (json) =>
                IngredientModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return Right(ingredients);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Stock>>> getStocks({
    int? categoryId,
    String? status,
  }) async {
    try {
      final stockModels = await remoteDatasource.fetchStocks(
        categoryId: categoryId,
        status: status,
      );
      final stocks = stockModels
          .map((json) => StockModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(stocks);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Stock>> addStock({
    required int ingredientId,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) async {
    try {
      final stockJson = await remoteDatasource.createStock(
        ingredientId: ingredientId,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
      );
      return Right(StockModel.fromJson(stockJson));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Stock>> updateStock({
    required int id,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) async {
    try {
      final stockJson = await remoteDatasource.updateStock(
        id: id,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
      );
      return Right(StockModel.fromJson(stockJson));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStock({required int id}) async {
    try {
      await remoteDatasource.deleteStock(id: id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}