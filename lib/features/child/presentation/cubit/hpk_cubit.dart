import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../pregnancy/domain/entities/pregnancy.dart';
import '../../../pregnancy/domain/usecases/pregnancy_usecases.dart';
import '../../domain/entities/child.dart';
import '../../domain/usecases/child_usecases.dart';
import 'hpk_state.dart';

class HpkCubit extends Cubit<HpkState> {
  final GetChildrenUsecase getChildrenUsecase;
  final CreateChildUsecase createChildUsecase;
  final UpdateChildUsecase updateChildUsecase;
  final DeleteChildUsecase deleteChildUsecase;
  final GetActivePregnancyUsecase getActivePregnancyUsecase;
  final GetAllPregnanciesUsecase getAllPregnanciesUsecase;

  HpkCubit({
    required this.getChildrenUsecase,
    required this.createChildUsecase,
    required this.updateChildUsecase,
    required this.deleteChildUsecase,
    required this.getActivePregnancyUsecase,
    required this.getAllPregnanciesUsecase,
  }) : super(HpkInitial());

  Future<void> load() async {
    emit(HpkLoading());
    final childrenResult = await getChildrenUsecase();
    final activeResult = await getActivePregnancyUsecase();
    final historyResult = await getAllPregnanciesUsecase();

    late List<Child> children;
    final failure = childrenResult.fold<String?>((value) => value.message, (
      list,
    ) {
      children = list;
      return null;
    });
    if (failure != null) {
      emit(HpkFailure(failure));
      return;
    }

    final pregnancy = activeResult.getOrElse(() => null);
    final history = historyResult.getOrElse(() => const <Pregnancy>[]);

    emit(
      HpkLoadedState(
        pregnancy: pregnancy,
        children: children,
        history: history,
      ),
    );
  }

  Future<String?> createChild({
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) async {
    final result = await createChildUsecase(
      name: name,
      gender: gender,
      birthDate: birthDate,
      hpht: hpht,
      hpl: hpl,
      birthWeightKg: birthWeightKg,
      birthLengthCm: birthLengthCm,
      birthHeadCircumferenceCm: birthHeadCircumferenceCm,
    );
    return result.fold((failure) => failure.message, (_) async {
      await load();
      return null;
    });
  }

  Future<String?> updateChild({
    required String id,
    required String name,
    required String gender,
    required DateTime birthDate,
    DateTime? hpht,
    DateTime? hpl,
    double? birthWeightKg,
    double? birthLengthCm,
    double? birthHeadCircumferenceCm,
  }) async {
    final result = await updateChildUsecase(
      id: id,
      name: name,
      gender: gender,
      birthDate: birthDate,
      hpht: hpht,
      hpl: hpl,
      birthWeightKg: birthWeightKg,
      birthLengthCm: birthLengthCm,
      birthHeadCircumferenceCm: birthHeadCircumferenceCm,
    );
    return result.fold((failure) => failure.message, (_) async {
      await load();
      return null;
    });
  }

  Future<String?> deleteChild(String id) async {
    final result = await deleteChildUsecase(id);
    return result.fold((failure) => failure.message, (_) async {
      await load();
      return null;
    });
  }
}
