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

  Future<Either<Failure, Child>> call(int id) {
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
  }) {
    return repository.createChild(
      name: name,
      gender: gender,
      birthDate: birthDate,
    );
  }
}

class UpdateChildUsecase {
  final ChildRepository repository;

  UpdateChildUsecase(this.repository);

  Future<Either<Failure, Child>> call({
    required int id,
    required String name,
    required String gender,
    required DateTime birthDate,
  }) {
    return repository.updateChild(
      id: id,
      name: name,
      gender: gender,
      birthDate: birthDate,
    );
  }
}

class DeleteChildUsecase {
  final ChildRepository repository;

  DeleteChildUsecase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteChild(id);
  }
}

class GetMeasurementsUsecase {
  final ChildRepository repository;
  GetMeasurementsUsecase(this.repository);
  Future<Either<Failure, List<ChildMeasurement>>> call(int childId) => repository.getMeasurements(childId);
}

class AddMeasurementUsecase {
  final ChildRepository repository;
  AddMeasurementUsecase(this.repository);
  Future<Either<Failure, ChildMeasurement>> call({
    required int childId,
    required double weight,
    required double height,
    required DateTime measuredAt,
  }) =>
      repository.addMeasurement(childId: childId, weight: weight, height: height, measuredAt: measuredAt);
}
