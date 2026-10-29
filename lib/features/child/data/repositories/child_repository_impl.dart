import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/child.dart';
import '../../domain/repositories/child_repository.dart';
import '../datasources/child_remote_datasource.dart';

class ChildRepositoryImpl implements ChildRepository {
  final ChildRemoteDatasource remoteDatasource;

  ChildRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<Child>>> getChildren() async {
    try {
      return Right(await remoteDatasource.getChildren());
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, Child>> getChildById(String id) async {
    try {
      return Right(await remoteDatasource.getChildById(id));
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, Child>> createChild({
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) async {
    try {
      final child = await remoteDatasource.createChild(
        name: name,
        gender: gender,
        birthDate: birthDate,
        hpht: hpht,
        hpl: hpl,
        birthWeightKg: birthWeightKg,
        birthLengthCm: birthLengthCm,
        birthHeadCircumferenceCm: birthHeadCircumferenceCm,
      );
      return Right(child);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, Child>> updateChild({
    required String id,
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) async {
    try {
      final child = await remoteDatasource.updateChild(
        id: id,
        name: name,
        gender: gender,
        birthDate: birthDate,
        hpht: hpht,
        hpl: hpl,
        birthWeightKg: birthWeightKg,
        birthLengthCm: birthLengthCm,
        birthHeadCircumferenceCm: birthHeadCircumferenceCm,
      );
      return Right(child);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChild(String id) async {
    try {
      await remoteDatasource.deleteChild(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, List<ChildMeasurement>>> getMeasurements(
    String childId,
  ) async {
    try {
      return Right(await remoteDatasource.getMeasurements(childId));
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, ChildMeasurement>> addMeasurement({
    required String childId,
    required DateTime measuredAt,
    double? weight,
    double? height,
    double? headCircumference,
    String? notes,
  }) async {
    try {
      final measurement = await remoteDatasource.addMeasurement(
        childId: childId,
        measuredAt: measuredAt,
        weight: weight,
        height: height,
        headCircumference: headCircumference,
        notes: notes,
      );
      return Right(measurement);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  static String _clean(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
