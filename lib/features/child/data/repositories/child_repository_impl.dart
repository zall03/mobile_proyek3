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
      final children = await remoteDatasource.getChildren();
      return Right(children);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Child>> getChildById(int id) async {
    try {
      final child = await remoteDatasource.getChildById(id);
      return Right(child);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Child>> createChild({
    required String name,
    required String gender,
    required DateTime birthDate,
  }) async {
    try {
      final child = await remoteDatasource.createChild(
        name: name,
        gender: gender,
        birthDate: birthDate,
      );
      return Right(child);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Child>> updateChild({
    required int id,
    required String name,
    required String gender,
    required DateTime birthDate,
  }) async {
    try {
      final child = await remoteDatasource.updateChild(
        id: id,
        name: name,
        gender: gender,
        birthDate: birthDate,
      );
      return Right(child);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChild(int id) async {
    try {
      await remoteDatasource.deleteChild(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChildMeasurement>>> getMeasurements(int childId) async {
    try {
      final data = await remoteDatasource.getMeasurements(childId);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChildMeasurement>> addMeasurement({
    required int childId,
    required double weight,
    required double height,
    required DateTime measuredAt,
  }) async {
    try {
      final m = await remoteDatasource.addMeasurement(
        childId: childId,
        weight: weight,
        height: height,
        measuredAt: measuredAt,
      );
      return Right(m);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
