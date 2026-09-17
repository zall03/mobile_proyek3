import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';

class AuthRemoteDatasource {
  final Dio dio;
  AuthRemoteDatasource(this.dio);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return response.data['data']['email'] as String;
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await dio.post(
        '/verify-otp',
        data: {'email': email, 'otp_code': otpCode},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  Future<String> resendOtp({required String email}) async {
    try {
      final response = await dio.post(
        '/resend-otp',
        data: {'email': email},
      );
      return response.data['message'].toString();
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> googleSignIn({required String idToken}) async {
    try {
      final response = await dio.post(
        '/auth/google',
        data: {'id_token': idToken},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null)
      return data['message'].toString();
    if (data is Map && data['errors'] != null) {
      final errors = data['errors'] as Map;
      return errors.values.first[0].toString();
    }
    return 'Tidak bisa terhubung ke server';
  }
}
