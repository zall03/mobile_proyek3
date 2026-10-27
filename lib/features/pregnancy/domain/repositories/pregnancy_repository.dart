import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/pregnancy.dart';

abstract class PregnancyRepository {
  Future<Either<Failure, Pregnancy?>> getActive();
  Future<Either<Failure, List<Pregnancy>>> getAll();
  Future<Either<Failure, Pregnancy>> save({
    required String motherName,
    required DateTime hphtDate,
    String? id,
  });
  Future<Either<Failure, Pregnancy>> markDelivered(String id);
  Future<Either<Failure, void>> delete(String id);
}
