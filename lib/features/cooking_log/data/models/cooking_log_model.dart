import '../../domain/entities/cooking_log.dart';

class CookingLogModel extends CookingLog {
  const CookingLogModel({
    required super.id,
    required super.recipeId,
    required super.servings,
    required super.cookedAt,
    super.durationMinutes,
    super.deducted,
    super.removed,
    super.skipped,
    super.nutrition,
    super.recipeName,
  });

  factory CookingLogModel.fromJson(Map<String, dynamic> json) {
    final recipe = json['recipe'] is Map ? json['recipe'] as Map : null;

    int parseInt(dynamic val, [int fallback = 0]) {
      if (val is num) return val.toInt();
      return int.tryParse(val?.toString() ?? '') ?? fallback;
    }

    double parseDouble(dynamic val, [double fallback = 0.0]) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? fallback;
    }

    final id = json['id']?.toString() ?? '';
    final recipeId = parseInt(json['recipe_id'], parseInt(recipe?['id']));
    final servings = parseDouble(json['servings'], 1.0).round();
    final cookedAt =
        DateTime.tryParse(json['cooked_at']?.toString() ?? '') ??
        DateTime.now();
    final durationMinutes = json['duration_minutes'] != null
        ? parseInt(json['duration_minutes'])
        : null;

    return CookingLogModel(
      id: id,
      recipeId: recipeId,
      servings: servings,
      cookedAt: cookedAt,
      durationMinutes: durationMinutes,
      deducted: _stockChanges(json['deducted']),
      removed: _stockChanges(json['removed']),
      skipped: _skipped(json['skipped']),
      nutrition: _nutrition(json['nutrition']),
      recipeName: json['recipe_name'] as String? ?? recipe?['name'] as String?,
    );
  }

  static List<SkippedIngredient> _skipped(dynamic raw) {
    return ((raw as List<dynamic>?) ?? const [])
        .map(
          (item) => SkippedIngredient(
            ingredient: item['ingredient']?.toString() ?? 'Bahan',
            reason: item['reason']?.toString() ?? 'tidak bisa dipotong',
          ),
        )
        .toList();
  }

  static NutritionSummary? _nutrition(dynamic raw) {
    if (raw is! Map) return null;
    return NutritionSummary(
      total: _facts(raw['total']),
      perServing: _facts(raw['per_serving']),
      servings: (raw['servings'] as num?)?.toDouble() ?? 1,
      excluded: _skipped(raw['excluded']),
    );
  }

  static NutritionFacts _facts(dynamic raw) {
    final map = raw is Map ? raw : const {};
    double read(String key) {
      final v = map[key];
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0.0;
    }

    return NutritionFacts(
      calories: read('calories'),
      proteinG: read('protein_g'),
      fatG: read('fat_g'),
      carbsG: read('carbs_g'),
      ironMg: read('iron_mg'),
      zincMg: read('zinc_mg'),
      vitaminAMcg: read('vitamin_a_mcg'),
      vitaminCMg: read('vitamin_c_mg'),
    );
  }

  static List<StockChange> _stockChanges(dynamic raw) {
    return ((raw as List<dynamic>?) ?? const []).map((item) {
      double parseD(dynamic v) {
        if (v is num) return v.toDouble();
        return double.tryParse(v?.toString() ?? '') ?? 0.0;
      }

      return StockChange(
        ingredient: item['ingredient']?.toString() ?? 'Bahan',
        used: parseD(item['used']),
        from: parseD(item['from']),
        to: parseD(item['to']),
        unit: item['unit']?.toString() ?? '',
      );
    }).toList();
  }
}
