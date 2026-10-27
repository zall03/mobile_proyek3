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
    int? durationMinutes,
  }) async {
    try {
      final log = await remoteDatasource.logCooking(
        recipeId: recipeId,
        servings: servings,
        durationMinutes: durationMinutes,
      );
      return Right(log);
    } catch (e) {
      return Left(ServerFailure(_readable(e)));
    }
  }

  @override
  Future<Either<Failure, List<CookingLog>>> getHistory({int days = 30}) async {
    try {
      final logs = await remoteDatasource.fetchHistory(days: days);
      return Right(logs);
    } catch (e) {
      return Left(ServerFailure(_readable(e)));
    }
  }

  /// Buang pembungkus Exception supaya pesan yang tampil ke pengguna tetap rapi.
  String _readable(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}
