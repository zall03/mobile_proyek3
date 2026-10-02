import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ingredient_category.dart';
import '../repositories/stock_repository.dart';

class GetCategoriesUsecase {
  final StockRepository repository;

  GetCategoriesUsecase(this.repository);

  Future<Either<Failure, List<IngredientCategory>>> call() {
    return repository.getCategories();
  }
}