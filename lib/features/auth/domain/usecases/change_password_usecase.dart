import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUsecase {
  final AuthRepository repository;
  ChangePasswordUsecase(this.repository);
  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) =>
      repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
}