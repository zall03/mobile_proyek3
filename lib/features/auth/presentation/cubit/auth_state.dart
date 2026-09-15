import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class OtpSent extends AuthState {
  final String email;
  const OtpSent(this.email);
  @override
  List<Object?> get props => [email];
}

class OtpVerified extends AuthState {
  final User user;
  const OtpVerified(this.user);
  @override
  List<Object?> get props => [user];
}

class OtpResent extends AuthState {
  const OtpResent();
}