import 'package:equatable/equatable.dart';

import '../../../child/domain/entities/child.dart';
import '../../../pregnancy/domain/entities/pregnancy.dart';

abstract class HpkState extends Equatable {
  const HpkState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(HpkLoadedState) loaded,
    required T Function(String) failure,
  }) {
    if (this is HpkInitial) return initial();
    if (this is HpkLoading) return loading();
    if (this is HpkLoadedState) return loaded(this as HpkLoadedState);
    if (this is HpkFailure) return failure((this as HpkFailure).message);
    throw Exception('Unknown state');
  }
}

class HpkInitial extends HpkState {}

class HpkLoading extends HpkState {}

class HpkLoadedState extends HpkState {
  final Pregnancy? pregnancy;
  final List<Child> children;
  final List<Pregnancy> history;

  const HpkLoadedState({
    required this.pregnancy,
    required this.children,
    required this.history,
  });

  bool get isEmpty => pregnancy == null && children.isEmpty && history.isEmpty;

  @override
  List<Object?> get props => [pregnancy, children, history];
}

class HpkFailure extends HpkState {
  final String message;

  const HpkFailure(this.message);

  @override
  List<Object?> get props => [message];
}
