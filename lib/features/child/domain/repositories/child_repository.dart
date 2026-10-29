import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/child.dart';

abstract class ChildRepository {
  Future<Either<Failure, List<Child>>> getChildren();
  Future<Either<Failure, Child>> getChildById(String id);
  Future<Either<Failure, Child>> createChild({
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  });
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
  });
  Future<Either<Failure, void>> deleteChild(String id);
  Future<Either<Failure, List<ChildMeasurement>>> getMeasurements(
    String childId,
  );
  Future<Either<Failure, ChildMeasurement>> addMeasurement({
    required String childId,
    required DateTime measuredAt,
    double? weight,
    double? height,
    double? headCircumference,
    String? notes,
  });
}
