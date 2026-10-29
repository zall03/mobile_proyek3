import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../cooking_log/presentation/widgets/cooking_session_launcher.dart';
import '../../domain/entities/recipe_audience.dart';
import '../cubit/recipe_cubit.dart';
import '../cubit/recipe_state.dart';
import '../widgets/recipe_body.dart';

class AiRecipeResultPage extends StatelessWidget {
  final List<int> ingredientIds;
  final RecipeAudience audience;
  final int servings;

  const AiRecipeResultPage({
    super.key,
    required this.ingredientIds,
    this.audience = RecipeAudience.family,
    this.servings = 2,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RecipeCubit>()
        ..generateRecipe(
          ingredientIds,
          forWhom: audience.apiValue,
          restrictions: audience.restrictions,
          servings: servings,
        ),
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
            'Racikan AI',
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
              loading: () => const SizedBox.shrink(),
              generating: () => const _GeneratingView(),
              loaded: (_) => const SizedBox.shrink(),
              recipeDetail: (recipe) => RecipeBody(
                recipe: recipe,
                audience: audience,
                onCook: (servings) => CookingSessionLauncher.start(
                  context,
                  recipe: recipe,
                  servings: servings,
                ),
              ),
              failure: (message) => _FailureView(
                message: message,
                onRetry: () => context.read<RecipeCubit>().generateRecipe(
                  ingredientIds,
                  forWhom: audience.apiValue,
                  restrictions: audience.restrictions,
                  servings: servings,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GeneratingView extends StatelessWidget {
  const _GeneratingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.primaryDark,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Menyusun resep dari bahan di kulkasmu',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Google butuh sekitar 15 sampai 30 detik. Jangan tutup aplikasi ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailureView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isBusy = message.toLowerCase().contains('sibuk');

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBusy ? Icons.cloud_off : Icons.error_outline,
              color: isBusy ? AppColors.textGrey : const Color(0xFFB3261E),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              isBusy ? 'AI sedang sibuk' : 'Gagal membuat resep',
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
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Coba lagi',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
