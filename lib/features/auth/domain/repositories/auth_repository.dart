import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, String>> register({
    required String name,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> verifyRegisterOtp({
    required String email,
    required String otpCode,
  });
  Future<Either<Failure, String>> resendOtp({required String email});
  Future<Either<Failure, User>> googleSignIn({required String idToken});
  Future<void> logout();
}
