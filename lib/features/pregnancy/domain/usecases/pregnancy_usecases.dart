import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/pregnancy.dart';
import '../repositories/pregnancy_repository.dart';

class GetActivePregnancyUsecase {
  final PregnancyRepository repository;

  GetActivePregnancyUsecase(this.repository);

  Future<Either<Failure, Pregnancy?>> call() => repository.getActive();
}

class GetAllPregnanciesUsecase {
  final PregnancyRepository repository;

  GetAllPregnanciesUsecase(this.repository);

  Future<Either<Failure, List<Pregnancy>>> call() => repository.getAll();
}

class SavePregnancyUsecase {
  final PregnancyRepository repository;

  SavePregnancyUsecase(this.repository);

  Future<Either<Failure, Pregnancy>> call({
    required String motherName,
    required DateTime hphtDate,
    DateTime? hplDate,
    String? notes,
    String? id,
  }) {
    return repository.save(
      motherName: motherName,
      hphtDate: hphtDate,
      hplDate: hplDate,
      notes: notes,
      id: id,
    );
  }
}

class MarkPregnancyDeliveredUsecase {
  final PregnancyRepository repository;

  MarkPregnancyDeliveredUsecase(this.repository);

  Future<Either<Failure, Pregnancy>> call(String id) =>
      repository.markDelivered(id);
}

class RegisterBirthUsecase {
  final PregnancyRepository repository;

  RegisterBirthUsecase(this.repository);

  Future<Either<Failure, void>> call({
    required String id,
    required DateTime deliveryDate,
    required String babyName,
    required String gender,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
    String? notes,
  }) {
    return repository.registerBirth(
      id: id,
      deliveryDate: deliveryDate,
      babyName: babyName,
      gender: gender,
      birthWeightKg: birthWeightKg,
      birthLengthCm: birthLengthCm,
      birthHeadCircumferenceCm: birthHeadCircumferenceCm,
      notes: notes,
    );
  }
}

class DeletePregnancyUsecase {
  final PregnancyRepository repository;

  DeletePregnancyUsecase(this.repository);

  Future<Either<Failure, void>> call(String id) => repository.delete(id);
}
