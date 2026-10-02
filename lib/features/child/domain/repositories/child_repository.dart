import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/child.dart';

abstract class ChildRepository {
  Future<Either<Failure, List<Child>>> getChildren();
  Future<Either<Failure, Child>> getChildById(int id);
  Future<Either<Failure, Child>> createChild({
    required String name,
    required String gender,
    required DateTime birthDate,
  });
  Future<Either<Failure, Child>> updateChild({
    required int id,
    required String name,
    required String gender,
    required DateTime birthDate,
  });
  Future<Either<Failure, void>> deleteChild(int id);
  Future<Either<Failure, List<ChildMeasurement>>> getMeasurements(int childId);
  Future<Either<Failure, ChildMeasurement>> addMeasurement({
    required int childId,
    required double weight,
    required double height,
    required DateTime measuredAt,
  });
}
