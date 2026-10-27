import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/cooking_log.dart';
import '../../domain/repositories/cooking_log_repository.dart';

class LogCookingUsecase {
  final CookingLogRepository repository;

  LogCookingUsecase(this.repository);

  Future<Either<Failure, CookingLog>> call({
    required int recipeId,
    required int servings,
    int? durationMinutes,
  }) {
    return repository.logCooking(
      recipeId: recipeId,
      servings: servings,
      durationMinutes: durationMinutes,
    );
  }
}

class GetCookingHistoryUsecase {
  final CookingLogRepository repository;

  GetCookingHistoryUsecase(this.repository);

  Future<Either<Failure, List<CookingLog>>> call({int days = 30}) {
    return repository.getHistory(days: days);
  }
}
