import 'package:flutter_test/flutter_test.dart';

import 'package:project3/core/utils/hpk.dart';
import 'package:project3/features/child/data/models/child_model.dart';
import 'package:project3/features/child/domain/entities/child.dart';
import 'package:project3/features/pregnancy/domain/entities/pregnancy.dart';

void main() {
  group('1000 HPK helpers', () {
    final hpht = DateTime(2026, 1, 1);

    test('day 1 starts on the HPHT date', () {
      expect(hpkDayOf(hpht, now: hpht), 1);
      expect(hpkDayOf(hpht, now: DateTime(2026, 1, 10)), 10);
    });

    test('day is clamped before HPHT and after 1000 days', () {
      expect(hpkDayOf(hpht, now: DateTime(2025, 12, 20)), 1);
      expect(hpkDayOf(hpht, now: DateTime(2029, 1, 1)), hpkTotalDays);
    });

    test('progress and completion follow calendar days', () {
      expect(hpkProgressOf(hpht, now: hpht), closeTo(0.001, 0.0001));
      expect(hpkIsComplete(hpht, now: DateTime(2028, 9, 26)), isFalse);
      expect(hpkIsComplete(hpht, now: DateTime(2028, 9, 27)), isTrue);
    });

    test('end date is HPHT plus 999 days', () {
      expect(hpkEndDate(hpht), DateTime(2028, 9, 26));
      expect(hplFromHpht(hpht), DateTime(2026, 10, 8));
    });

    test('trimester boundaries are 13 and 27 weeks', () {
      expect(trimesterOf(hpht, now: hpht.add(const Duration(days: 90))), 1);
      expect(trimesterOf(hpht, now: hpht.add(const Duration(days: 91))), 2);
      expect(trimesterOf(hpht, now: hpht.add(const Duration(days: 189))), 3);
    });

    test('manual child without HPHT uses 280 days before birth', () {
      final birth = DateTime(2026, 3, 1);
      expect(estimatedHphtFromBirth(birth), DateTime(2025, 5, 25));
      expect(
        daysUntilDueOf(DateTime(2026, 1, 1), now: DateTime(2026, 1, 2)),
        279,
      );
    });

    test('isoDate writes the backend date format', () {
      expect(isoDate(DateTime(2026, 2, 7, 23, 59)), '2026-02-07');
    });
  });

  group('Child HPK fields', () {
    test('fromJson reads HPHT, HPL, and birth measurements', () {
      final child = ChildModel.fromJson({
        'id': 'child-1',
        'name': 'Rayyan',
        'gender': 'male',
        'birth_date': '2026-03-01',
        'hpht': '2025-05-25',
        'hpl': '2026-03-01',
        'pregnancy_id': 'preg-1',
        'birth_weight_kg': 3.1,
        'birth_length_cm': 49,
        'birth_head_circumference_cm': 34,
      });

      expect(child.hpht, DateTime(2025, 5, 25));
      expect(child.hpl, DateTime(2026, 3, 1));
      expect(child.pregnancyId, 'preg-1');
      expect(child.birthWeightKg, 3.1);
      expect(child.birthLengthCm, 49);
      expect(child.birthHeadCircumferenceCm, 34);
      expect(child.isEstimatedHpht, isFalse);
    });

    test('manual child falls back to an estimated HPHT', () {
      final child = ChildModel(
        id: 'child-2',
        name: 'Tanpa HPHT',
        gender: 'female',
        birthDate: DateTime(2026, 3, 1),
      );

      expect(child.isEstimatedHpht, isTrue);
      expect(child.effectiveHpht, DateTime(2025, 5, 25));
    });

    test('measurement can carry only one metric', () {
      final measurement = ChildMeasurement(
        id: 'm-1',
        childId: 'child-1',
        measuredAt: DateTime(2026, 4, 1),
        headCircumference: 38,
      );

      expect(measurement.weight, isNull);
      expect(measurement.height, isNull);
      expect(measurement.hasAnyValue, isTrue);
    });
  });

  group('Pregnancy status', () {
    test('accepts backend and legacy status labels', () {
      final active = Pregnancy(
        id: 'p-1',
        motherName: 'Ibu',
        hphtDate: DateTime(2026, 1, 1),
        dueDate: DateTime(2026, 10, 8),
        status: 'hamil',
      );
      final delivered = Pregnancy(
        id: 'p-2',
        motherName: 'Ibu',
        hphtDate: DateTime(2025, 1, 1),
        dueDate: DateTime(2025, 10, 8),
        status: 'delivered',
      );

      expect(active.isActive, isTrue);
      expect(delivered.isDelivered, isTrue);
    });
  });
}
