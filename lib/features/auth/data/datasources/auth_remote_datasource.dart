import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/register_outcome.dart';
import '../models/user_model.dart';

/// Autentikasi memakai Supabase Auth; profil pengguna dibaca dari backend Go.
class AuthRemoteDatasource {
  final SupabaseClient supabase;
  final Dio dio;

  AuthRemoteDatasource(this.supabase, this.dio);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw ServerException(_authMessage(e));
    }
  }

  Future<RegisterOutcome> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.session == null) {
        return RegisterOutcome(email: email);
      }
      return RegisterOutcome(user: await _me(), email: email);
    } on AuthException catch (e) {
      throw ServerException(_authMessage(e));
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      await supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: otpCode,
      );
    } on AuthException catch (e) {
      throw ServerException(_authMessage(e));
    }
  }

  Future<String> resendOtp({required String email}) async {
    try {
      await supabase.auth.resend(type: OtpType.signup, email: email);
      return 'Kode verifikasi baru telah dikirim';
    } on AuthException catch (e) {
      throw ServerException(_authMessage(e));
    }
  }

  /// Memulai OAuth Google. Di web halaman dialihkan ke Google, jadi sesi baru
  /// tersedia setelah aplikasi dimuat ulang. Di platform lain sesi menyusul
  /// lewat deep link; kembalian `null` berarti belum ada sesi.
  Future<UserModel?> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : AppConfig.oauthRedirect,
      );
      if (supabase.auth.currentSession == null) return null;
      return await _me();
    } on AuthException catch (e) {
      throw ServerException(_authMessage(e));
    }
  }

  Future<UserModel> me() => _me();

  Future<UserModel> updateMe({required String name}) async {
    try {
      final response = await dio.put('/me', data: {'name': name});
      return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_dioMessage(e));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final email = supabase.auth.currentUser?.email;
      if (email == null) {
        throw ServerException('Sesi tidak ditemukan, masuk ulang');
      }
      // Supabase tidak memverifikasi sandi lama, jadi dicek dengan masuk ulang.
      await supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw ServerException(_authMessage(e));
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(_authMessage(e));
    }
  }

  Future<UserModel> _me() async {
    try {
      final response = await dio.get('/me');
      return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_dioMessage(e));
    }
  }

  String _authMessage(AuthException e) {
    final message = e.message.trim();
    return message.isEmpty ? 'Autentikasi gagal, coba lagi' : message;
  }

  String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is Map && data['errors'] != null) {
      final errors = data['errors'] as Map;
      return errors.values.first[0].toString();
    }
    return 'Tidak bisa terhubung ke server';
  }
}
