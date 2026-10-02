import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';

class StockRemoteDatasource {
  final Dio dio;

  StockRemoteDatasource(this.dio);

  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await dio.get('/categories');
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  Future<List<dynamic>> fetchIngredients({
    String? query,
    int? categoryId,
  }) async {
    try {
      final response = await dio.get(
        '/ingredients',
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          if (categoryId != null) 'category_id': categoryId,
        },
      );
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  Future<List<dynamic>> fetchStocks({
    int? categoryId,
    String? status,
  }) async {
    try {
      final response = await dio.get(
        '/stocks',
        queryParameters: {
          if (categoryId != null) 'category_id': categoryId,
          if (status != null) 'status': status,
        },
      );
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> createStock({
    required int ingredientId,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) async {
    try {
      final response = await dio.post(
        '/stocks',
        data: {
          'ingredient_id': ingredientId,
          'quantity': quantity,
          'unit': unit,
          'expiry_date': expiryDate != null
              ? _toDateString(expiryDate)
              : null,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  Future<Map<String, dynamic>> updateStock({
    required int id,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) async {
    try {
      final response = await dio.put(
        '/stocks/$id',
        data: {
          'quantity': quantity,
          'unit': unit,
          'expiry_date': expiryDate != null
              ? _toDateString(expiryDate)
              : null,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  Future<void> deleteStock({required int id}) async {
    try {
      await dio.delete('/stocks/$id');
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    }
  }

  String _toDateString(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is Map && data['errors'] != null) {
      final errors = data['errors'] as Map;
      return errors.values.first[0].toString();
    }
    return 'Tidak bisa terhubung ke server';
  }
}