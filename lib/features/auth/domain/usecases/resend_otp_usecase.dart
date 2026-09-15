import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUsecase {
  final AuthRepository repository;
  ResendOtpUsecase(this.repository);

  Future<Either<Failure, String>> call({required String email}) {
    return repository.resendOtp(email: email);
  }
}