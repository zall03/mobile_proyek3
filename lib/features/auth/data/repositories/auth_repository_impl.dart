import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl(this.remoteDatasource, this.secureStorage);

  Future<void> _cacheUser(User user) async {
    await secureStorage.write(key: 'cached_user', value: jsonEncode({'id': user.id, 'name': user.name, 'email': user.email}));
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDatasource.login(
        email: email,
        password: password,
      );
      final user = UserModel.fromJson(result['user']);
      await secureStorage.write(key: 'auth_token', value: result['token']);
      await _cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final sentEmail = await remoteDatasource.register(
        name: name,
        email: email,
        password: password,
      );
      return Right(sentEmail);
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
      final result = await remoteDatasource.verifyOtp(
        email: email,
        otpCode: otpCode,
      );
      final user = UserModel.fromJson(result['user']);
      await secureStorage.write(key: 'auth_token', value: result['token']);
      await _cacheUser(user);
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
  Future<Either<Failure, User>> googleSignIn({required String idToken}) async {
    try {
      final result = await remoteDatasource.googleSignIn(idToken: idToken);
      final user = UserModel.fromJson(result['user']);
      await secureStorage.write(key: 'auth_token', value: result['token']);
      await _cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      final json = await remoteDatasource.me();
      final user = UserModel.fromJson(json);
      await _cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateMe({required String name}) async {
    try {
      final json = await remoteDatasource.updateMe(name: name);
      final user = UserModel.fromJson(json);
      await _cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await remoteDatasource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDatasource.logout();
    } catch (_) {}
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'cached_user');
  }
}
