import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/child.dart';
import '../repositories/child_repository.dart';

class GetChildrenUsecase {
  final ChildRepository repository;

  GetChildrenUsecase(this.repository);

  Future<Either<Failure, List<Child>>> call() {
    return repository.getChildren();
  }
}

class GetChildByIdUsecase {
  final ChildRepository repository;

  GetChildByIdUsecase(this.repository);

  Future<Either<Failure, Child>> call(String id) {
    return repository.getChildById(id);
  }
}

class CreateChildUsecase {
  final ChildRepository repository;

  CreateChildUsecase(this.repository);

  Future<Either<Failure, Child>> call({
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) {
    return repository.createChild(
      name: name,
      gender: gender,
      birthDate: birthDate,
      hpht: hpht,
      hpl: hpl,
      birthWeightKg: birthWeightKg,
      birthLengthCm: birthLengthCm,
      birthHeadCircumferenceCm: birthHeadCircumferenceCm,
    );
  }
}

class UpdateChildUsecase {
  final ChildRepository repository;

  UpdateChildUsecase(this.repository);

  Future<Either<Failure, Child>> call({
    required String id,
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) {
    return repository.updateChild(
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
  }
}

class DeleteChildUsecase {
  final ChildRepository repository;

  DeleteChildUsecase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteChild(id);
  }
}

class GetMeasurementsUsecase {
  final ChildRepository repository;
  GetMeasurementsUsecase(this.repository);
  Future<Either<Failure, List<ChildMeasurement>>> call(String childId) =>
      repository.getMeasurements(childId);
}

class AddMeasurementUsecase {
  final ChildRepository repository;
  AddMeasurementUsecase(this.repository);
  Future<Either<Failure, ChildMeasurement>> call({
    required String childId,
    required DateTime measuredAt,
    double? weight,
    double? height,
    double? headCircumference,
    String? notes,
  }) => repository.addMeasurement(
    childId: childId,
    measuredAt: measuredAt,
    weight: weight,
    height: height,
    headCircumference: headCircumference,
    notes: notes,
  );
}
