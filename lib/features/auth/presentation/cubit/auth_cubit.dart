import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/verify_register_otp_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final VerifyRegisterOtpUsecase verifyOtpUsecase;
  final ResendOtpUsecase resendOtpUsecase;

  AuthCubit({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.verifyOtpUsecase,
    required this.resendOtpUsecase,
  }) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    final result = await loginUsecase(email: email, password: password);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await registerUsecase(
      name: name,
      email: email,
      password: password,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (sentEmail) => emit(OtpSent(sentEmail)),
    );
  }

  Future<void> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    emit(AuthLoading());
    final result = await verifyOtpUsecase(email: email, otpCode: otpCode);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(OtpVerified(user)),
    );
  }

  Future<void> resendOtp({required String email}) async {
    emit(AuthLoading());
    final result = await resendOtpUsecase(email: email);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const OtpResent()),
    );
  }
}