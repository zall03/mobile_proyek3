import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyRegisterOtpUsecase {
  final AuthRepository repository;
  VerifyRegisterOtpUsecase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String otpCode,
  }) {
    return repository.verifyRegisterOtp(email: email, otpCode: otpCode);
  }
}