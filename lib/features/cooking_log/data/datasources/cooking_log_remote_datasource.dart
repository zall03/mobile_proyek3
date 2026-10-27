import 'package:dio/dio.dart';

import '../models/cooking_log_model.dart';

class CookingLogRemoteDatasource {
  final Dio dio;

  CookingLogRemoteDatasource(this.dio);

  Future<CookingLogModel> logCooking({
    required int recipeId,
    required int servings,
    int? durationMinutes,
  }) async {
    try {
      final response = await dio.post(
        '/cooking-logs',
        data: {
          'recipe_id': recipeId,
          'servings': servings,
          if (durationMinutes != null) 'duration_minutes': durationMinutes,
        },
      );
      final data = response.data;
      final payload =
          data is Map ? (data['data'] as Map<String, dynamic>?) : null;
      if (payload == null) {
        throw Exception('Response server tidak valid');
      }
      return CookingLogModel.fromJson(payload);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map &&
          data['message'] is String &&
          (data['message'] as String).isNotEmpty) {
        throw Exception(data['message'] as String);
      }
      throw Exception('Gagal menyimpan sesi masak: ${e.message}');
    } catch (e) {
      throw Exception('Gagal menyimpan sesi masak: $e');
    }
  }

  Future<List<CookingLogModel>> fetchHistory({int days = 30}) async {
    try {
      final response = await dio.get(
        '/cooking-logs',
        queryParameters: {'days': days},
      );
      final data = response.data;
      final list = data is Map ? (data['data'] as List<dynamic>?) : null;
      return (list ?? const [])
          .map((item) => CookingLogModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map &&
          data['message'] is String &&
          (data['message'] as String).isNotEmpty) {
        throw Exception(data['message'] as String);
      }
      throw Exception('Gagal memuat riwayat: ${e.message}');
    } catch (e) {
      throw Exception('Gagal memuat riwayat: $e');
    }
  }
}
