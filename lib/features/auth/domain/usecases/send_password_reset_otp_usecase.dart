import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetOtpUsecase {
  final AuthRepository repository;
  SendPasswordResetOtpUsecase(this.repository);

  Future<Either<Failure, void>> call({required String email}) {
    return repository.sendPasswordResetOtp(email: email);
  }
}
