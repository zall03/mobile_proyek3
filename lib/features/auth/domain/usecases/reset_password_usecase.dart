import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository repository;
  ResetPasswordUsecase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String otpCode,
    required String newPassword,
  }) {
    return repository.resetPassword(
      email: email,
      otpCode: otpCode,
      newPassword: newPassword,
    );
  }
}
