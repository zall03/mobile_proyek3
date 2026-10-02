import 'package:dio/dio.dart';

import '../models/child_measurement_model.dart';
import '../models/child_model.dart';

class ChildRemoteDatasource {
  final Dio dio;

  ChildRemoteDatasource(this.dio);

  Future<List<ChildModel>> getChildren() async {
    try {
      final response = await dio.get('/children');
      final list = response.data['data'] as List<dynamic>;
      return list.map((c) => ChildModel.fromJson(c as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch children: $e');
    }
  }

  Future<ChildModel> getChildById(int id) async {
    try {
      final response = await dio.get('/children/$id');
      return ChildModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch child: $e');
    }
  }

  Future<ChildModel> createChild({
    required String name,
    required String gender,
    required DateTime birthDate,
  }) async {
    try {
      final response = await dio.post(
        '/children',
        data: {
          'name': name,
          'gender': gender,
          'birth_date': birthDate.toIso8601String(),
        },
      );
      return ChildModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create child: $e');
    }
  }

  Future<ChildModel> updateChild({
    required int id,
    required String name,
    required String gender,
    required DateTime birthDate,
  }) async {
    try {
      final response = await dio.put(
        '/children/$id',
        data: {
          'name': name,
          'gender': gender,
          'birth_date': birthDate.toIso8601String(),
        },
      );
      return ChildModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update child: $e');
    }
  }

  Future<void> deleteChild(int id) async {
    try {
      await dio.delete('/children/$id');
    } catch (e) {
      throw Exception('Failed to delete child: $e');
    }
  }

  Future<List<ChildMeasurementModel>> getMeasurements(int childId) async {
    try {
      final response = await dio.get('/children/$childId/measurements');
      final list = response.data['data'] as List<dynamic>;
      return list.map((m) => ChildMeasurementModel.fromJson(m as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to fetch measurements: $e');
    }
  }

  Future<ChildMeasurementModel> addMeasurement({
    required int childId,
    required double weight,
    required double height,
    required DateTime measuredAt,
  }) async {
    try {
      final response = await dio.post(
        '/children/$childId/measurements',
        data: {
          'weight': weight,
          'height': height,
          'measured_at': measuredAt.toIso8601String().split('T').first,
        },
      );
      return ChildMeasurementModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to add measurement: $e');
    }
  }
}
