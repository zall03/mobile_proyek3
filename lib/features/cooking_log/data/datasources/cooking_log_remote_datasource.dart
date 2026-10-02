import 'package:dio/dio.dart';

import '../models/cooking_log_model.dart';

class CookingLogRemoteDatasource {
  final Dio dio;

  CookingLogRemoteDatasource(this.dio);

  Future<CookingLogModel> logCooking({
    required int recipeId,
    required int servings,
  }) async {
    try {
      final response = await dio.post(
        '/cooking-logs',
        data: {
          'recipe_id': recipeId,
          'servings': servings,
        },
      );
      return CookingLogModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to log cooking: $e');
    }
  }
}
