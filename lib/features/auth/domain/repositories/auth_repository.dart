import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/register_outcome.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, RegisterOutcome>> register({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> verifyRegisterOtp({
    required String email,
    required String otpCode,
  });
  Future<Either<Failure, String>> resendOtp({required String email});
  Future<Either<Failure, void>> sendPasswordResetOtp({required String email});
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  });
  Future<Either<Failure, User?>> googleSignIn();
  Future<Either<Failure, User>> getMe();
  Future<Either<Failure, User>> updateMe({required String name});
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> logout();
}
