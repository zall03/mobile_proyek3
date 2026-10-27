import 'package:equatable/equatable.dart';

import '../../domain/entities/pregnancy.dart';

abstract class PregnancyState extends Equatable {
  const PregnancyState();

  @override
  List<Object?> get props => [];
}

class PregnancyInitial extends PregnancyState {}

class PregnancyLoading extends PregnancyState {}

/// `pregnancy` null berarti belum ada profil kehamilan aktif.
class PregnancyLoaded extends PregnancyState {
  final Pregnancy? pregnancy;
  final List<Pregnancy> history;

  const PregnancyLoaded(this.pregnancy, {this.history = const []});

  @override
  List<Object?> get props => [pregnancy, history];
}

class PregnancySaving extends PregnancyState {
  final Pregnancy? pregnancy;

  const PregnancySaving(this.pregnancy);

  @override
  List<Object?> get props => [pregnancy];
}

class PregnancyFailure extends PregnancyState {
  final String message;

  const PregnancyFailure(this.message);

  @override
  List<Object?> get props => [message];
}
