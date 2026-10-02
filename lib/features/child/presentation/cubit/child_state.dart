import 'package:equatable/equatable.dart';

import '../../domain/entities/child.dart';

abstract class ChildState extends Equatable {
  const ChildState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Child>) loaded,
    required T Function(Child) childDetail,
    required T Function(String) failure,
  }) {
    if (this is ChildInitial) return initial();
    if (this is ChildLoading) return loading();
    if (this is ChildLoaded) return loaded((this as ChildLoaded).children);
    if (this is ChildDetail) return childDetail((this as ChildDetail).child);
    if (this is ChildFailure) return failure((this as ChildFailure).message);
    throw Exception('Unknown state');
  }
}

class ChildInitial extends ChildState {}

class ChildLoading extends ChildState {}

class ChildLoaded extends ChildState {
  final List<Child> children;

  const ChildLoaded(this.children);

  @override
  List<Object?> get props => [children];
}

class ChildDetail extends ChildState {
  final Child child;

  const ChildDetail(this.child);

  @override
  List<Object?> get props => [child];
}

class ChildFailure extends ChildState {
  final String message;

  const ChildFailure(this.message);

  @override
  List<Object?> get props => [message];
}
