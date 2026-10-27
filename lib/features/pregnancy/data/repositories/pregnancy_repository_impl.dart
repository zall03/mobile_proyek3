import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/pregnancy.dart';
import '../../domain/repositories/pregnancy_repository.dart';
import '../datasources/pregnancy_remote_datasource.dart';

class PregnancyRepositoryImpl implements PregnancyRepository {
  final PregnancyRemoteDatasource remoteDatasource;

  PregnancyRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, Pregnancy?>> getActive() async {
    try {
      return Right(await remoteDatasource.getActive());
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, List<Pregnancy>>> getAll() async {
    try {
      return Right(await remoteDatasource.getAll());
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, Pregnancy>> save({
    required String motherName,
    required DateTime hphtDate,
    String? id,
  }) async {
    try {
      final saved = id == null
          ? await remoteDatasource.create(
              motherName: motherName,
              hphtDate: hphtDate,
            )
          : await remoteDatasource.update(
              id: id,
              motherName: motherName,
              hphtDate: hphtDate,
            );
      return Right(saved);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, Pregnancy>> markDelivered(String id) async {
    try {
      return Right(await remoteDatasource.markDelivered(id));
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await remoteDatasource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  static String _clean(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
