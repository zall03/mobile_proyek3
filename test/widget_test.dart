import 'package:flutter_test/flutter_test.dart';

import 'package:project3/features/stock/data/models/ingredient_model.dart';
import 'package:project3/features/stock/data/models/stock_model.dart';

void main() {
  group('IngredientModel.fromJson', () {
    test('parses full ingredient payload', () {
      final json = {
        'id': 1,
        'category_id': 1,
        'name': 'Bayam',
        'default_unit': 'gram',
        'calories_per_100g': 23,
        'protein_g': 2.9,
        'fat_g': 0.4,
        'carbs_g': 3.6,
        'iron_mg': 3.5,
        'zinc_mg': 0.5,
        'vitamin_a_mcg': 469,
        'vitamin_c_mg': 28,
        'category': {'id': 1, 'name': 'Sayur'},
      };

      final model = IngredientModel.fromJson(json);

      expect(model.id, 1);
      expect(model.name, 'Bayam');
      expect(model.categoryName, 'Sayur');
      expect(model.caloriesPer100g, 23.0);
      expect(model.proteinG, 2.9);
    });

    test('treats numeric strings as doubles', () {
      final json = {
        'id': 2,
        'category_id': 2,
        'name': 'Telur Ayam',
        'default_unit': 'butir',
        'calories_per_100g': '155',
        'protein_g': '13',
        'iron_mg': '1.8',
        'zinc_mg': '1.3',
        'vitamin_a_mcg': '160',
        'vitamin_c_mg': '0',
      };

      final model = IngredientModel.fromJson(json);

      expect(model.caloriesPer100g, 155.0);
      expect(model.proteinG, 13.0);
      expect(model.vitaminCMg, 0.0);
    });
  });

  group('StockModel.fromJson', () {
    test('maps status and days_left', () {
      final json = {
        'id': 7,
        'ingredient': {
          'id': 1,
          'category_id': 1,
          'name': 'Wortel',
          'default_unit': 'gram',
          'calories_per_100g': 41,
          'protein_g': 0.9,
          'fat_g': 0.2,
          'carbs_g': 9.6,
          'iron_mg': 0.3,
          'zinc_mg': 0.2,
          'vitamin_a_mcg': 835,
          'vitamin_c_mg': 5.9,
          'category': {'id': 1, 'name': 'Sayur'},
        },
        'quantity': 250,
        'unit': 'gram',
        'expiry_date': '2026-09-18T00:00:00.000000Z',
        'status': 'expiring',
        'days_left': 1,
      };

      final model = StockModel.fromJson(json);

      expect(model.id, 7);
      expect(model.status.value, 'expiring');
      expect(model.daysLeft, 1);
      expect(model.quantity, 250.0);
      expect(model.ingredient.name, 'Wortel');
      expect(model.expiryDate, isNotNull);
    });

    test('handles missing expiry as fresh', () {
      final json = {
        'id': 8,
        'ingredient': {
          'id': 2,
          'category_id': 2,
          'name': 'Tahu Putih',
          'default_unit': 'gram',
          'calories_per_100g': 80,
          'protein_g': 9.7,
          'fat_g': 4.9,
          'carbs_g': 1.5,
          'iron_mg': 1.9,
          'zinc_mg': 0.9,
          'vitamin_a_mcg': 0,
          'vitamin_c_mg': 0,
        },
        'quantity': 1,
        'unit': 'bungkus',
        'expiry_date': null,
        'status': 'fresh',
        'days_left': null,
      };

      final model = StockModel.fromJson(json);

      expect(model.status, isNotNull);
      expect(model.expiryDate, isNull);
      expect(model.daysLeft, isNull);
    });
  });
}