import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GoogleSignInUsecase {
  final AuthRepository repository;
  GoogleSignInUsecase(this.repository);

  Future<Either<Failure, User?>> call() {
    return repository.googleSignIn();
  }
}
