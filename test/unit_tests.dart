import 'package:flutter_test/flutter_test.dart';

import 'package:project3/features/child/data/models/child_model.dart';
import 'package:project3/features/cooking_log/data/models/cooking_log_model.dart';

void main() {
  group('ChildModel', () {
    test('fromJson creates Child with correct data', () {
      final json = {
        'id': 'a1b2c3d4-0000-0000-0000-000000000001',
        'name': 'Rayyan',
        'gender': 'male',
        'birth_date': '2024-03-15',
      };

      final model = ChildModel.fromJson(json);

      expect(model.id, 'a1b2c3d4-0000-0000-0000-000000000001');
      expect(model.name, 'Rayyan');
      expect(model.gender, 'male');
      expect(model.birthDate, DateTime(2024, 3, 15));
    });

    test('ageInYears calculates correctly', () {
      final birthDate = DateTime(2024, 1, 1);
      final model = ChildModel(
        id: 'a1b2c3d4-0000-0000-0000-000000000002',
        name: 'Test',
        gender: 'male',
        birthDate: birthDate,
      );

      final age = model.ageInYears;
      expect(age, greaterThanOrEqualTo(1));
      expect(age, lessThanOrEqualTo(3));
    });

    test('toJson serializes correctly', () {
      final model = ChildModel(
        id: 'a1b2c3d4-0000-0000-0000-000000000003',
        name: 'Rayyan',
        gender: 'male',
        birthDate: DateTime(2024, 3, 15),
      );

      final json = model.toJson();

      expect(json['name'], 'Rayyan');
      expect(json['gender'], 'male');
      expect(json['birth_date'], '2024-03-15T00:00:00.000');
    });
  });

  group('CookingLogModel', () {
    test('fromJson creates CookingLog with correct data', () {
      final json = {
        'id': 'da599c86-84a8-42c1-ae80-1a64854be999',
        'recipe_id': 5,
        'servings': 2,
        'cooked_at': '2026-09-18T10:30:00.000Z',
      };

      final model = CookingLogModel.fromJson(json);

      expect(model.id, 'da599c86-84a8-42c1-ae80-1a64854be999');
      expect(model.recipeId, 5);
      expect(model.servings, 2);
      expect(model.cookedAt.year, 2026);
    });

    test('handles numeric id and missing servings field', () {
      final json = {
        'id': 2,
        'recipe_id': 10,
        'cooked_at': '2026-09-18T10:30:00.000Z',
      };

      final model = CookingLogModel.fromJson(json);

      expect(model.id, '2');
      expect(model.servings, 1);
    });
  });
}
