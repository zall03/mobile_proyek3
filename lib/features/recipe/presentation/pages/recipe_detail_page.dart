import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../cooking_log/presentation/widgets/cooking_session_launcher.dart';
import '../../domain/entities/recipe.dart';
import '../cubit/recipe_cubit.dart';
import '../cubit/recipe_state.dart';
import '../widgets/recipe_body.dart';

class RecipeDetailPage extends StatelessWidget {
  final int recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  void _startCooking(BuildContext context, Recipe recipe, int servings) {
    CookingSessionLauncher.start(context, recipe: recipe, servings: servings);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RecipeCubit>()..getRecipeDetail(recipeId),
      child: Scaffold(
        backgroundColor: AppColors.bgGradientStart,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Resep',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              ),
              generating: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              ),
              loaded: (_) => const SizedBox.shrink(),
              recipeDetail: (recipe) => RecipeBody(
                recipe: recipe,
                onCook: (servings) => _startCooking(context, recipe, servings),
              ),
              failure: (message) => _ErrorView(
                title: 'Gagal memuat resep',
                message: message,
                onRetry: () =>
                    context.read<RecipeCubit>().getRecipeDetail(recipeId),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFB3261E), size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.primaryDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Coba lagi',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
