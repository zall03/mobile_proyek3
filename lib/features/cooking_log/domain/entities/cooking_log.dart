import 'package:equatable/equatable.dart';

/// Hasil pencatatan satu sesi masak, termasuk rincian stok yang terpakai.
class CookingLog extends Equatable {
  final String id;
  final int recipeId;
  final int servings;
  final DateTime cookedAt;
  final int? durationMinutes;
  final List<StockChange> deducted;
  final List<StockChange> removed;
  final List<SkippedIngredient> skipped;

  /// Total gizi hasil masak, dihitung server dari takaran resep × porsi.
  final NutritionSummary? nutrition;

  /// Hanya diisi oleh riwayat; response pencatatan tidak membawa nama resep.
  final String? recipeName;

  const CookingLog({
    required this.id,
    required this.recipeId,
    required this.servings,
    required this.cookedAt,
    this.durationMinutes,
    this.deducted = const [],
    this.removed = const [],
    this.skipped = const [],
    this.nutrition,
    this.recipeName,
  });

  bool get touchedStock => deducted.isNotEmpty || removed.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    recipeId,
    servings,
    cookedAt,
    durationMinutes,
    deducted,
    removed,
    skipped,
    nutrition,
    recipeName,
  ];
}

/// Perubahan jumlah pada satu baris stok.
class StockChange extends Equatable {
  final String ingredient;
  final double used;
  final double from;
  final double to;
  final String unit;

  const StockChange({
    required this.ingredient,
    required this.used,
    required this.from,
    required this.to,
    required this.unit,
  });

  @override
  List<Object?> get props => [ingredient, used, from, to, unit];
}

/// Bahan yang tidak bisa dipotong dari stok.
class SkippedIngredient extends Equatable {
  final String ingredient;
  final String reason;

  const SkippedIngredient({required this.ingredient, required this.reason});

  @override
  List<Object?> get props => [ingredient, reason];
}

/// Total gizi satu sesi masak beserta pecahan per porsi.
class NutritionSummary extends Equatable {
  final NutritionFacts total;
  final NutritionFacts perServing;
  final double servings;

  /// Bahan yang tidak ikut dihitung (tidak ada di stok atau satuan
  /// seperti butir yang tidak punya bobot tetap).
  final List<SkippedIngredient> excluded;

  const NutritionSummary({
    required this.total,
    required this.perServing,
    required this.servings,
    this.excluded = const [],
  });

  @override
  List<Object?> get props => [total, perServing, servings, excluded];
}

/// Angka gizi; satuan mengikuti kolom backend (kkal, g, mg, mcg).
class NutritionFacts extends Equatable {
  final double calories;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final double ironMg;
  final double zincMg;
  final double vitaminAMcg;
  final double vitaminCMg;

  const NutritionFacts({
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.ironMg,
    required this.zincMg,
    required this.vitaminAMcg,
    required this.vitaminCMg,
  });

  @override
  List<Object?> get props => [
    calories,
    proteinG,
    fatG,
    carbsG,
    ironMg,
    zincMg,
    vitaminAMcg,
    vitaminCMg,
  ];
}
