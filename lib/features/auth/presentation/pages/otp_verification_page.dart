import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() => setState(() {}));
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining <= 1) {
          timer.cancel();
          _secondsRemaining = 0;
        } else {
          _secondsRemaining--;
        }
      });
    });
  }

  void _handleVerify(BuildContext ctx) {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kode OTP 6 digit'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    FocusScope.of(ctx).unfocus();
    setState(() => _isVerifying = true);
    ctx.read<AuthCubit>().verifyOtp(email: widget.email, otpCode: code);
  }

  void _handleResend(BuildContext ctx) {
    FocusScope.of(ctx).unfocus();
    ctx.read<AuthCubit>().resendOtp(email: widget.email);
  }

  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return email;
    final name = email.substring(0, at);
    final domain = email.substring(at);
    final visible = name.length > 2 ? name.substring(0, 2) : name[0];
    return '$visible***$domain';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            _timer?.cancel();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (state is OtpResent) {
            _startTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kode OTP baru telah dikirim ke email Anda'),
                backgroundColor: AppColors.primaryMedium,
              ),
            );
          } else if (state is AuthFailure) {
            setState(() => _isVerifying = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final isVerifying = isLoading && _isVerifying;
          final canResend = _secondsRemaining == 0;

          return Scaffold(
            backgroundColor: AppColors.bgGradientStart,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.bgGradientStart, AppColors.bgGradientEnd],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Dapur Cerdas',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryDark.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_outlined,
                            size: 44,
                            color: AppColors.primaryMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Verifikasi Email',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kode verifikasi telah dikirim ke\n${_maskEmail(widget.email)}.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: AppColors.textGrey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      PinCodeTextField(
                        appContext: context,
                        controller: _otpController,
                        length: 6,
                        hapticFeedbackTypes: HapticFeedbackTypes.vibrate,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autoFocus: true,
                        enablePinAutofill: true,
                        enabled: !isLoading,
                        onCompleted: (_) => _handleVerify(context),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(14),
                          fieldHeight: 52,
                          fieldWidth: 46,
                          activeColor: AppColors.primaryMedium,
                          activeFillColor: Colors.white,
                          selectedColor: AppColors.primaryMedium,
                          selectedFillColor: Colors.white,
                          inactiveColor: AppColors.primaryLight.withValues(
                            alpha: 0.4,
                          ),
                          inactiveFillColor: Colors.white,
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                        errorAnimationController: null,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: canResend
                            ? TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _handleResend(context),
                                child: Text(
                                  'Kirim Ulang Kode',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              )
                            : Text(
                                'Kirim ulang kode dalam $_secondsRemaining detik',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (isLoading || codeLengthNotSix())
                              ? null
                              : () => _handleVerify(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isVerifying
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Verifikasi & Daftar',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          '🔒 Jangan bagikan kode verifikasi ini kepada siapa pun',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool codeLengthNotSix() => _otpController.text.trim().length != 6;
}