import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pregnancy.dart';
import '../../domain/usecases/pregnancy_usecases.dart';
import 'pregnancy_state.dart';

class PregnancyCubit extends Cubit<PregnancyState> {
  final GetActivePregnancyUsecase getActive;
  final GetAllPregnanciesUsecase getAll;
  final SavePregnancyUsecase save;
  final MarkPregnancyDeliveredUsecase markDelivered;
  final DeletePregnancyUsecase deletePregnancy;

  PregnancyCubit({
    required this.getActive,
    required this.getAll,
    required this.save,
    required this.markDelivered,
    required this.deletePregnancy,
  }) : super(PregnancyInitial());

  Future<void> load() async {
    emit(PregnancyLoading());
    final result = await getActive();
    await result.fold(
      (failure) async => emit(PregnancyFailure(failure.message)),
      (pregnancy) async {
        final history = await getAll();
        emit(
          PregnancyLoaded(
            pregnancy,
            history: history.getOrElse(() => const <Pregnancy>[]),
          ),
        );
      },
    );
  }

  Future<bool> saveProfile({
    required String motherName,
    required DateTime hphtDate,
    String? id,
  }) async {
    emit(PregnancySaving(await _current()));
    final result = await save(
      motherName: motherName,
      hphtDate: hphtDate,
      id: id,
    );

    return await result.fold(
      (failure) async {
        emit(PregnancyFailure(failure.message));
        return false;
      },
      (_) async {
        await load();
        return true;
      },
    );
  }

  /// Mengembalikan pesan error, atau null bila berhasil. Kegagalan di sini
  /// tidak mengubah state agar data yang sedang tampil tidak hilang.
  Future<String?> markAsDelivered(String id) async {
    final result = await markDelivered(id);
    return result.fold((failure) => failure.message, (_) async {
      await load();
      return null;
    });
  }

  Future<String?> remove(String id) async {
    final result = await deletePregnancy(id);
    return result.fold((failure) => failure.message, (_) async {
      await load();
      return null;
    });
  }

  Future<Pregnancy?> _current() async {
    final state = this.state;
    return state is PregnancyLoaded ? state.pregnancy : null;
  }
}
