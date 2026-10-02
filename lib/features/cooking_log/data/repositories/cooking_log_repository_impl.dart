import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/cooking_log.dart';
import '../../domain/repositories/cooking_log_repository.dart';
import '../datasources/cooking_log_remote_datasource.dart';

class CookingLogRepositoryImpl implements CookingLogRepository {
  final CookingLogRemoteDatasource remoteDatasource;

  CookingLogRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, CookingLog>> logCooking({
    required int recipeId,
    required int servings,
  }) async {
    try {
      final log = await remoteDatasource.logCooking(
        recipeId: recipeId,
        servings: servings,
      );
      return Right(log);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
