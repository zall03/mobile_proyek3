import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/register_outcome.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;
  RegisterUsecase(this.repository);

  Future<Either<Failure, RegisterOutcome>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.register(name: name, email: email, password: password);
  }
}
