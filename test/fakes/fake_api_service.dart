import 'package:arsenal_manager/models/dashboard_stats.dart';
import 'package:arsenal_manager/models/division.dart';
import 'package:arsenal_manager/models/gear_item.dart';
import 'package:arsenal_manager/services/api_service.dart';

/// In-memory implementation of [ApiServiceBase] for use in tests.
///
/// Starts with two divisions (Gadgets, Vehicles) and three gear items.
/// Set [shouldThrow] to true to simulate API failures.
class FakeApiService implements ApiServiceBase {
  bool shouldThrow;
  int _nextId = 10;

  final List<GearItem> _gear;
  final List<Division> _divisions;

  FakeApiService({this.shouldThrow = false})
      : _gear = [
          _g(id: 1, name: 'Batarang', divisionId: 1, divisionName: 'Gadgets', quantity: 20, targetQuantity: 30),
          _g(id: 2, name: 'Grapple Hook', divisionId: 1, divisionName: 'Gadgets', quantity: 5, targetQuantity: 10),
          _g(id: 3, name: 'Batmobile', divisionId: 2, divisionName: 'Vehicles', quantity: 1, targetQuantity: 3),
        ],
        _divisions = [
          Division(id: 1, name: 'Gadgets'),
          Division(id: 2, name: 'Vehicles'),
        ];

  static GearItem _g({
    required int id,
    required String name,
    required int divisionId,
    required String divisionName,
    required int quantity,
    required int targetQuantity,
    String? notes,
  }) =>
      GearItem(
        id: id,
        name: name,
        divisionId: divisionId,
        divisionName: divisionName,
        quantity: quantity,
        targetQuantity: targetQuantity,
        notes: notes,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

  void _maybeThrow() {
    if (shouldThrow) throw Exception('Network error');
  }

  @override
  Future<List<GearItem>> fetchGear({String? search}) async {
    _maybeThrow();
    if (search != null && search.isNotEmpty) {
      return _gear
          .where((g) => g.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    return List.from(_gear);
  }

  @override
  Future<GearItem> fetchGearById(int id) async {
    _maybeThrow();
    return _gear.firstWhere(
      (g) => g.id == id,
      orElse: () => throw Exception('Not found: $id'),
    );
  }

  @override
  Future<List<Division>> fetchDivisions() async {
    _maybeThrow();
    return List.from(_divisions);
  }

  @override
  Future<DashboardStats> fetchStats() async {
    _maybeThrow();
    return DashboardStats(
      totalGear: _gear.length,
      criticalCount: _gear.where((g) => g.status == StockStatus.critical).length,
      lowStockCount: _gear.where((g) => g.status == StockStatus.lowStock).length,
      inStockCount: _gear.where((g) => g.status == StockStatus.inStock).length,
    );
  }

  @override
  Future<GearItem> createGear({
    required String name,
    required int divisionId,
    required int quantity,
    required int targetQuantity,
    String? notes,
  }) async {
    _maybeThrow();
    final divisionName =
        _divisions.firstWhere((d) => d.id == divisionId).name;
    final newItem = _g(
      id: _nextId++,
      name: name,
      divisionId: divisionId,
      divisionName: divisionName,
      quantity: quantity,
      targetQuantity: targetQuantity,
      notes: notes,
    );
    _gear.add(newItem);
    return newItem;
  }

  @override
  Future<void> updateGear({
    required int id,
    required String name,
    required int divisionId,
    required int quantity,
    required int targetQuantity,
    String? notes,
  }) async {
    _maybeThrow();
    final index = _gear.indexWhere((g) => g.id == id);
    if (index == -1) throw Exception('Not found: $id');
    final divisionName =
        _divisions.firstWhere((d) => d.id == divisionId).name;
    _gear[index] = _g(
      id: id,
      name: name,
      divisionId: divisionId,
      divisionName: divisionName,
      quantity: quantity,
      targetQuantity: targetQuantity,
      notes: notes,
    );
  }

  @override
  Future<void> deleteGear(int id) async {
    _maybeThrow();
    _gear.removeWhere((g) => g.id == id);
  }
}
