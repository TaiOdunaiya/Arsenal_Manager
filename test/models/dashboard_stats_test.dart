import 'package:flutter_test/flutter_test.dart';
import 'package:arsenal_manager/models/dashboard_stats.dart';

void main() {
  group('DashboardStats.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'totalGear': 18,
        'criticalCount': 3,
        'lowStockCount': 5,
        'inStockCount': 10,
      };

      final stats = DashboardStats.fromJson(json);

      expect(stats.totalGear, 18);
      expect(stats.criticalCount, 3);
      expect(stats.lowStockCount, 5);
      expect(stats.inStockCount, 10);
    });
  });

  group('DashboardStats.empty', () {
    test('returns all zeros', () {
      final stats = DashboardStats.empty();

      expect(stats.totalGear, 0);
      expect(stats.criticalCount, 0);
      expect(stats.lowStockCount, 0);
      expect(stats.inStockCount, 0);
    });
  });
}
