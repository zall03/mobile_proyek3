import 'package:dio/dio.dart';

import '../models/recipe_model.dart';

class RecipeRemoteDatasource {
  final Dio dio;

  RecipeRemoteDatasource(this.dio);

  Future<List<RecipeModel>> getRecipes() async {
    try {
      final response = await dio.get('/recipes');
      final list = response.data['data'] as List<dynamic>;
      return list.map((r) => RecipeModel.fromJson(r as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_messageFrom(e));
    } catch (e) {
      throw Exception('Failed to fetch recipes: $e');
    }
  }

  Future<RecipeModel> getRecipeById(int id) async {
    try {
      final response = await dio.get('/recipes/$id');
      return RecipeModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_messageFrom(e));
    } catch (e) {
      throw Exception('Failed to fetch recipe: $e');
    }
  }

  Future<RecipeModel> generateRecipe(List<int> ingredientIds) async {
    try {
      final response = await dio.post('/recipes/generate', data: {
        'ingredient_ids': ingredientIds,
      });
      return RecipeModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_messageFrom(e));
    } catch (e) {
      throw Exception('Failed to generate recipe: $e');
    }
  }

  String _messageFrom(DioException e) {
    if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionTimeout) {
      return 'Proses terlalu lama. Google Gemini sedang sibuk. Silakan coba lagi.';
    }
    final data = e.response?.data;
    if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    return 'Terjadi kesalahan jaringan. Periksa koneksi ke server.';
  }
}
