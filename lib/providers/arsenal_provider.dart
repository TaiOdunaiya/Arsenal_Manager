import 'package:flutter/foundation.dart';
import '../models/gear_item.dart';
import '../models/division.dart';
import '../models/dashboard_stats.dart';
import '../services/api_service.dart';

class ArsenalProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<GearItem> _gear = [];
  List<Division> _divisions = [];
  DashboardStats _stats = DashboardStats.empty();
  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  int? _selectedDivisionId;

  List<GearItem> get gear => _gear;
  List<Division> get divisions => _divisions;
  DashboardStats get stats => _stats;
  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int? get selectedDivisionId => _selectedDivisionId;

  List<GearItem> get filteredGear {
    var result = _gear;
    if (_selectedDivisionId != null) {
      result = result.where((g) => g.divisionId == _selectedDivisionId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    final sorted = List<GearItem>.from(result)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sorted;
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDivisionFilter(int? divisionId) {
    _selectedDivisionId = divisionId;
    notifyListeners();
  }

  Future<void> loadAll() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.fetchGear(),
        _api.fetchDivisions(),
        _api.fetchStats(),
      ]);
      _gear = results[0] as List<GearItem>;
      _divisions = results[1] as List<Division>;
      _stats = results[2] as DashboardStats;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadGear() async {
    try {
      _gear = await _api.fetchGear();
      _stats = await _api.fetchStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addGear({
    required String name,
    required int divisionId,
    required int quantity,
    String? notes,
  }) async {
    try {
      final newItem = await _api.createGear(
        name: name,
        divisionId: divisionId,
        quantity: quantity,
        notes: notes,
      );
      _gear.add(newItem);
      _stats = await _api.fetchStats();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGear({
    required int id,
    required String name,
    required int divisionId,
    required int quantity,
    String? notes,
  }) async {
    try {
      await _api.updateGear(
        id: id,
        name: name,
        divisionId: divisionId,
        quantity: quantity,
        notes: notes,
      );
      await loadGear();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGear(int id) async {
    try {
      await _api.deleteGear(id);
      _gear.removeWhere((g) => g.id == id);
      _stats = await _api.fetchStats();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
