import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/register_outcome.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDatasource.signIn(email: email, password: password);
      final user = await remoteDatasource.me();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, RegisterOutcome>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final outcome = await remoteDatasource.register(
        name: name,
        email: email,
        password: password,
      );
      return Right(outcome);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> verifyRegisterOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      await remoteDatasource.verifyOtp(email: email, otpCode: otpCode);
      final user = await remoteDatasource.me();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> resendOtp({required String email}) async {
    try {
      final message = await remoteDatasource.resendOtp(email: email);
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetOtp({
    required String email,
  }) async {
    try {
      await remoteDatasource.sendPasswordResetOtp(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      await remoteDatasource.resetPassword(
        email: email,
        otpCode: otpCode,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User?>> googleSignIn() async {
    try {
      final user = await remoteDatasource.signInWithGoogle();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      return Right(await remoteDatasource.me());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateMe({required String name}) async {
    try {
      return Right(await remoteDatasource.updateMe(name: name));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDatasource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDatasource.signOut();
    } catch (_) {}
  }
}
