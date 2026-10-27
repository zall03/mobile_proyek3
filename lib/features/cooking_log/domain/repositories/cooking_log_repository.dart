import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/cooking_log.dart';

abstract class CookingLogRepository {
  Future<Either<Failure, CookingLog>> logCooking({
    required int recipeId,
    required int servings,
    int? durationMinutes,
  });

  Future<Either<Failure, List<CookingLog>>> getHistory({int days = 30});
}
