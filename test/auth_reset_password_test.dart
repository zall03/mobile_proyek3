import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:project3/core/errors/failures.dart';
import 'package:project3/features/auth/domain/repositories/auth_repository.dart';
import 'package:project3/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:project3/features/auth/domain/usecases/send_password_reset_otp_usecase.dart';
import 'package:project3/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:project3/features/auth/presentation/cubit/auth_state.dart';
import 'package:project3/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:project3/features/auth/domain/usecases/login_usecase.dart';
import 'package:project3/features/auth/domain/usecases/register_usecase.dart';
import 'package:project3/features/auth/domain/usecases/resend_otp_usecase.dart';
import 'package:project3/features/auth/domain/usecases/verify_register_otp_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  group('SendPasswordResetOtpUsecase', () {
    test('returns Right when the repository sends the OTP', () async {
      when(() => repository.sendPasswordResetOtp(email: any(named: 'email')))
          .thenAnswer((_) async => const Right(null));

      final result = await SendPasswordResetOtpUsecase(repository)(
        email: 'bunda@email.com',
      );

      expect(result.isRight(), isTrue);
      verify(() => repository.sendPasswordResetOtp(email: 'bunda@email.com'))
          .called(1);
    });

    test('returns Left when the repository fails', () async {
      when(() => repository.sendPasswordResetOtp(email: any(named: 'email')))
          .thenAnswer(
            (_) async => const Left(ServerFailure('Email tidak dikenal')),
          );

      final result = await SendPasswordResetOtpUsecase(repository)(
        email: 'bunda@email.com',
      );

      expect(result, const Left(ServerFailure('Email tidak dikenal')));
    });
  });

  group('ResetPasswordUsecase', () {
    test('passes email, OTP, and new password to the repository', () async {
      when(
        () => repository.resetPassword(
          email: any(named: 'email'),
          otpCode: any(named: 'otpCode'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await ResetPasswordUsecase(repository)(
        email: 'bunda@email.com',
        otpCode: '123456',
        newPassword: 'rahasia123',
      );

      expect(result.isRight(), isTrue);
      verify(
        () => repository.resetPassword(
          email: 'bunda@email.com',
          otpCode: '123456',
          newPassword: 'rahasia123',
        ),
      ).called(1);
    });

    test('returns Left when the OTP is rejected', () async {
      when(
        () => repository.resetPassword(
          email: any(named: 'email'),
          otpCode: any(named: 'otpCode'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Kode OTP salah')));

      final result = await ResetPasswordUsecase(repository)(
        email: 'bunda@email.com',
        otpCode: '000000',
        newPassword: 'rahasia123',
      );

      expect(result, const Left(ServerFailure('Kode OTP salah')));
    });
  });

  group('AuthCubit password reset flow', () {
    late AuthCubit cubit;

    setUp(() {
      cubit = AuthCubit(
        loginUsecase: LoginUsecase(repository),
        registerUsecase: RegisterUsecase(repository),
        verifyOtpUsecase: VerifyRegisterOtpUsecase(repository),
        resendOtpUsecase: ResendOtpUsecase(repository),
        googleSignInUsecase: GoogleSignInUsecase(repository),
        sendPasswordResetOtpUsecase: SendPasswordResetOtpUsecase(repository),
        resetPasswordUsecase: ResetPasswordUsecase(repository),
      );
    });

    tearDown(() => cubit.close());

    test('emits loading then PasswordResetOtpSent', () async {
      when(() => repository.sendPasswordResetOtp(email: any(named: 'email')))
          .thenAnswer((_) async => const Right(null));

      final states = <AuthState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.sendPasswordResetOtp(email: 'bunda@email.com');
      await Future.delayed(Duration.zero);

      expect(states.first, isA<AuthLoading>());
      expect(states.last, isA<PasswordResetOtpSent>());
      expect((states.last as PasswordResetOtpSent).email, 'bunda@email.com');

      await subscription.cancel();
    });

    test('emits loading then PasswordResetSuccess', () async {
      when(
        () => repository.resetPassword(
          email: any(named: 'email'),
          otpCode: any(named: 'otpCode'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final states = <AuthState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.resetPassword(
        email: 'bunda@email.com',
        otpCode: '123456',
        newPassword: 'rahasia123',
      );
      await Future.delayed(Duration.zero);

      expect(states.first, isA<AuthLoading>());
      expect(states.last, isA<PasswordResetSuccess>());

      await subscription.cancel();
    });

    test('emits AuthFailure when resetting fails', () async {
      when(
        () => repository.resetPassword(
          email: any(named: 'email'),
          otpCode: any(named: 'otpCode'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Kode OTP kadaluarsa')),
      );

      final states = <AuthState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.resetPassword(
        email: 'bunda@email.com',
        otpCode: '123456',
        newPassword: 'rahasia123',
      );
      await Future.delayed(Duration.zero);

      expect(states.last, isA<AuthFailure>());
      expect((states.last as AuthFailure).message, 'Kode OTP kadaluarsa');

      await subscription.cancel();
    });
  });
}
