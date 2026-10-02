import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ingredient.dart';
import '../repositories/stock_repository.dart';

class GetIngredientsUsecase {
  final StockRepository repository;

  GetIngredientsUsecase(this.repository);

  Future<Either<Failure, List<Ingredient>>> call({
    String? query,
    int? categoryId,
  }) {
    return repository.getIngredients(query: query, categoryId: categoryId);
  }
}