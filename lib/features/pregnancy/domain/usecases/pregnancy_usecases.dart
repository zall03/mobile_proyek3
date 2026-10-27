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
    String? id,
  }) {
    return repository.save(motherName: motherName, hphtDate: hphtDate, id: id);
  }
}

class MarkPregnancyDeliveredUsecase {
  final PregnancyRepository repository;

  MarkPregnancyDeliveredUsecase(this.repository);

  Future<Either<Failure, Pregnancy>> call(String id) =>
      repository.markDelivered(id);
}

class DeletePregnancyUsecase {
  final PregnancyRepository repository;

  DeletePregnancyUsecase(this.repository);

  Future<Either<Failure, void>> call(String id) => repository.delete(id);
}
