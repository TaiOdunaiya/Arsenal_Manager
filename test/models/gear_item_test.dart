import 'package:flutter_test/flutter_test.dart';
import 'package:arsenal_manager/models/gear_item.dart';

void main() {
  group('StockStatus boundaries', () {
    GearItem itemWithQty(int qty) => GearItem(
          id: 1,
          name: 'Test',
          divisionId: 1,
          divisionName: 'Gadgets',
          quantity: qty,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

    test('quantity 1 is critical', () {
      expect(itemWithQty(1).status, StockStatus.critical);
    });

    test('quantity 5 is critical (upper boundary)', () {
      expect(itemWithQty(5).status, StockStatus.critical);
    });

    test('quantity 6 is lowStock (lower boundary)', () {
      expect(itemWithQty(6).status, StockStatus.lowStock);
    });

    test('quantity 15 is lowStock (upper boundary)', () {
      expect(itemWithQty(15).status, StockStatus.lowStock);
    });

    test('quantity 16 is inStock (lower boundary)', () {
      expect(itemWithQty(16).status, StockStatus.inStock);
    });

    test('quantity 100 is inStock', () {
      expect(itemWithQty(100).status, StockStatus.inStock);
    });
  });

  group('GearItem.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 7,
        'name': 'Batarang',
        'divisionId': 1,
        'divisionName': 'Gadgets',
        'quantity': 20,
        'notes': 'Standard issue',
        'createdAt': '2024-01-15T10:00:00.000Z',
        'updatedAt': '2024-06-01T08:30:00.000Z',
      };

      final item = GearItem.fromJson(json);

      expect(item.id, 7);
      expect(item.name, 'Batarang');
      expect(item.divisionId, 1);
      expect(item.divisionName, 'Gadgets');
      expect(item.quantity, 20);
      expect(item.notes, 'Standard issue');
      expect(item.createdAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
      expect(item.updatedAt, DateTime.parse('2024-06-01T08:30:00.000Z'));
    });

    test('handles null notes', () {
      final json = {
        'id': 1,
        'name': 'Cape',
        'divisionId': 3,
        'divisionName': 'Tactical',
        'quantity': 3,
        'notes': null,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final item = GearItem.fromJson(json);

      expect(item.notes, isNull);
    });
  });
}
