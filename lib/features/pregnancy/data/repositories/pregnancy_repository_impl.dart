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
    DateTime? hplDate,
    String? notes,
    String? id,
  }) async {
    try {
      final saved = id == null
          ? await remoteDatasource.create(
              motherName: motherName,
              hphtDate: hphtDate,
              hplDate: hplDate,
              notes: notes,
            )
          : await remoteDatasource.update(
              id: id,
              motherName: motherName,
              hphtDate: hphtDate,
              hplDate: hplDate,
              notes: notes,
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
  Future<Either<Failure, void>> registerBirth({
    required String id,
    required DateTime deliveryDate,
    required String babyName,
    required String gender,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
    String? notes,
  }) async {
    try {
      await remoteDatasource.registerBirth(
        id: id,
        deliveryDate: deliveryDate,
        babyName: babyName,
        gender: gender,
        birthWeightKg: birthWeightKg,
        birthLengthCm: birthLengthCm,
        birthHeadCircumferenceCm: birthHeadCircumferenceCm,
        notes: notes,
      );
      return const Right(null);
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
