import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../../recipe/domain/entities/recipe.dart';
import '../../../recipe/presentation/pages/cook_mode_page.dart';
import '../cubit/cooking_log_cubit.dart';

/// Membuka Mode Masak dengan cubit pencatatan yang sudah siap.
///
/// Dipisahkan supaya halaman resep tidak perlu tahu detail penyediaan
/// CookingLogCubit.
class CookingSessionLauncher {
  const CookingSessionLauncher._();

  static Future<void> start(
    BuildContext context, {
    required Recipe recipe,
    required int servings,
  }) {
    final cubit = sl<CookingLogCubit>();

    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: CookModePage(recipe: recipe, servings: servings),
        ),
      ),
    );
  }
}
