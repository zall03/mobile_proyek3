import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateMeUsecase {
  final AuthRepository repository;
  UpdateMeUsecase(this.repository);
  Future<Either<Failure, User>> call({required String name}) => repository.updateMe(name: name);
}