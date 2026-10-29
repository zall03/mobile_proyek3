import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/pregnancy.dart';

abstract class PregnancyRepository {
  Future<Either<Failure, Pregnancy?>> getActive();
  Future<Either<Failure, List<Pregnancy>>> getAll();
  Future<Either<Failure, Pregnancy>> save({
    required String motherName,
    required DateTime hphtDate,
    DateTime? hplDate,
    String? notes,
    String? id,
  });
  Future<Either<Failure, Pregnancy>> markDelivered(String id);
  Future<Either<Failure, void>> registerBirth({
    required String id,
    required DateTime deliveryDate,
    required String babyName,
    required String gender,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
    String? notes,
  });
  Future<Either<Failure, void>> delete(String id);
}
