import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cooking_log.dart';

abstract class CookingLogRepository {
  Future<Either<Failure, CookingLog>> logCooking({
    required int recipeId,
    required int servings,
  });
}
