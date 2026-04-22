import 'package:flutter_test/flutter_test.dart';
import 'package:arsenal_manager/models/gear_item.dart';

void main() {
  GearItem itemWith({required int qty, required int target}) => GearItem(
        id: 1,
        name: 'Test',
        divisionId: 1,
        divisionName: 'Gadgets',
        quantity: qty,
        targetQuantity: target,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

  group('StockStatus — ratio thresholds (critical <40%, low 40–79%, in ≥80%)', () {
    test('0% of target is critical', () {
      expect(itemWith(qty: 0, target: 10).status, StockStatus.critical);
    });

    test('30% of target is critical (qty=3, target=10)', () {
      expect(itemWith(qty: 3, target: 10).status, StockStatus.critical);
    });

    test('40% of target is lowStock (lower boundary, qty=4, target=10)', () {
      expect(itemWith(qty: 4, target: 10).status, StockStatus.lowStock);
    });

    test('70% of target is lowStock (qty=7, target=10)', () {
      expect(itemWith(qty: 7, target: 10).status, StockStatus.lowStock);
    });

    test('80% of target is inStock (lower boundary, qty=8, target=10)', () {
      expect(itemWith(qty: 8, target: 10).status, StockStatus.inStock);
    });

    test('100% of target is inStock (qty=10, target=10)', () {
      expect(itemWith(qty: 10, target: 10).status, StockStatus.inStock);
    });

    test('over target is inStock (qty=15, target=10)', () {
      expect(itemWith(qty: 15, target: 10).status, StockStatus.inStock);
    });

    test('2 Batmobiles out of 3 target is lowStock (67%)', () {
      expect(itemWith(qty: 2, target: 3).status, StockStatus.lowStock);
    });

    test('3 Batmobiles out of 3 target is inStock (100%)', () {
      expect(itemWith(qty: 3, target: 3).status, StockStatus.inStock);
    });

    test('1 Batmobile out of 3 target is critical (33%)', () {
      expect(itemWith(qty: 1, target: 3).status, StockStatus.critical);
    });
  });

  group('wasJustAdded', () {
    test('returns true when createdAt and updatedAt are identical', () {
      final t = DateTime(2024, 6, 1, 12, 0, 0);
      final item = GearItem(
        id: 1, name: 'Cape', divisionId: 1, divisionName: 'Tactical',
        quantity: 5, targetQuantity: 10, createdAt: t, updatedAt: t,
      );
      expect(item.wasJustAdded, true);
    });

    test('returns true when updatedAt is within 1 second of createdAt', () {
      final created = DateTime(2024, 6, 1, 12, 0, 0);
      final updated = created.add(const Duration(milliseconds: 500));
      final item = GearItem(
        id: 1, name: 'Cape', divisionId: 1, divisionName: 'Tactical',
        quantity: 5, targetQuantity: 10, createdAt: created, updatedAt: updated,
      );
      expect(item.wasJustAdded, true);
    });

    test('returns false when updatedAt is more than 1 second after createdAt', () {
      final created = DateTime(2024, 6, 1, 12, 0, 0);
      final updated = created.add(const Duration(seconds: 5));
      final item = GearItem(
        id: 1, name: 'Cape', divisionId: 1, divisionName: 'Tactical',
        quantity: 5, targetQuantity: 10, createdAt: created, updatedAt: updated,
      );
      expect(item.wasJustAdded, false);
    });
  });

  group('GearItem.fromJson', () {
    test('parses all fields including targetQuantity', () {
      final json = {
        'id': 7,
        'name': 'Batarang',
        'divisionId': 1,
        'divisionName': 'Gadgets',
        'quantity': 20,
        'targetQuantity': 50,
        'notes': 'Standard issue',
        'createdAt': '2024-01-15T10:00:00.000Z',
        'updatedAt': '2024-06-01T08:30:00.000Z',
      };

      final item = GearItem.fromJson(json);

      expect(item.id, 7);
      expect(item.name, 'Batarang');
      expect(item.quantity, 20);
      expect(item.targetQuantity, 50);
      expect(item.notes, 'Standard issue');
    });

    test('falls back to quantity when targetQuantity is missing from JSON', () {
      final json = {
        'id': 1,
        'name': 'Cape',
        'divisionId': 3,
        'divisionName': 'Tactical',
        'quantity': 5,
        'notes': null,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final item = GearItem.fromJson(json);

      expect(item.targetQuantity, 5);
      expect(item.status, StockStatus.inStock);
    });

    test('handles null notes', () {
      final json = {
        'id': 1,
        'name': 'Cape',
        'divisionId': 3,
        'divisionName': 'Tactical',
        'quantity': 3,
        'targetQuantity': 10,
        'notes': null,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      expect(GearItem.fromJson(json).notes, isNull);
    });
  });
}
