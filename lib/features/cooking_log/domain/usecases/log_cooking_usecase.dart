import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cooking_log.dart';
import '../repositories/cooking_log_repository.dart';

class LogCookingUsecase {
  final CookingLogRepository repository;

  LogCookingUsecase(this.repository);

  Future<Either<Failure, CookingLog>> call({
    required int recipeId,
    required int servings,
  }) {
    return repository.logCooking(recipeId: recipeId, servings: servings);
  }
}
