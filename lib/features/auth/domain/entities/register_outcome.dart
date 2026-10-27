import 'package:equatable/equatable.dart';

import 'user.dart';

/// Hasil pendaftaran Supabase.
///
/// Bila konfirmasi email aktif, `user` masih null dan `email` perlu
/// diverifikasi lewat kode OTP. Bila konfirmasi nonaktif, sesi langsung
/// terbentuk dan `user` sudah terisi.
class RegisterOutcome extends Equatable {
  final User? user;
  final String email;

  const RegisterOutcome({this.user, required this.email});

  bool get needsVerification => user == null;

  @override
  List<Object?> get props => [user, email];
}
