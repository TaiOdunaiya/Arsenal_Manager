import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gear_item.dart';
import '../models/division.dart';
import '../models/dashboard_stats.dart';
import '../services/api_service.dart';

// ─── Sentinel for nullable copyWith fields ────────────────────────────────────
const Object _keep = Object();

// ─── State ────────────────────────────────────────────────────────────────────

class ArsenalState {
  final List<GearItem> gear;
  final List<Division> divisions;
  final DashboardStats stats;
  final bool loading;
  final String? error;
  final String searchQuery;
  final int? selectedDivisionId;

  const ArsenalState({
    required this.gear,
    required this.divisions,
    required this.stats,
    required this.loading,
    this.error,
    this.searchQuery = '',
    this.selectedDivisionId,
  });

  factory ArsenalState.initial() => ArsenalState(
        gear: const [],
        divisions: const [],
        stats: DashboardStats.empty(),
        loading: false,
      );

  ArsenalState copyWith({
    List<GearItem>? gear,
    List<Division>? divisions,
    DashboardStats? stats,
    bool? loading,
    Object? error = _keep,
    String? searchQuery,
    Object? selectedDivisionId = _keep,
  }) {
    return ArsenalState(
      gear: gear ?? this.gear,
      divisions: divisions ?? this.divisions,
      stats: stats ?? this.stats,
      loading: loading ?? this.loading,
      error: identical(error, _keep) ? this.error : error as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDivisionId: identical(selectedDivisionId, _keep)
          ? this.selectedDivisionId
          : selectedDivisionId as int?,
    );
  }

  List<GearItem> get filteredGear {
    var result = gear;
    if (selectedDivisionId != null) {
      result = result.where((g) => g.divisionId == selectedDivisionId).toList();
    }
    if (searchQuery.isNotEmpty) {
      result = result
          .where(
              (g) => g.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return List<GearItem>.from(result)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final apiServiceProvider = Provider<ApiServiceBase>((ref) => ApiService());

final arsenalProvider =
    NotifierProvider<ArsenalNotifier, ArsenalState>(ArsenalNotifier.new);

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ArsenalNotifier extends Notifier<ArsenalState> {
  @override
  ArsenalState build() {
    Future.microtask(loadAll);
    return ArsenalState.initial();
  }

  ApiServiceBase get _api => ref.read(apiServiceProvider);

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDivisionFilter(int? divisionId) {
    state = state.copyWith(selectedDivisionId: divisionId);
  }

  Future<void> loadAll() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final results = await Future.wait([
        _api.fetchGear(),
        _api.fetchDivisions(),
        _api.fetchStats(),
      ]);
      state = state.copyWith(
        gear: results[0] as List<GearItem>,
        divisions: results[1] as List<Division>,
        stats: results[2] as DashboardStats,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> _refreshGear() async {
    final gear = await _api.fetchGear();
    final stats = await _api.fetchStats();
    state = state.copyWith(gear: gear, stats: stats);
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
      final updatedGear = [...state.gear, newItem];
      final stats = await _api.fetchStats();
      state = state.copyWith(gear: updatedGear, stats: stats);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
      await _refreshGear();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteGear(int id) async {
    try {
      await _api.deleteGear(id);
      final updatedGear = state.gear.where((g) => g.id != id).toList();
      final stats = await _api.fetchStats();
      state = state.copyWith(gear: updatedGear, stats: stats);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> batchRestockCritical(Map<int, int> restockQuantities) async {
    try {
      await Future.wait(
        restockQuantities.entries.map((e) {
          final item = state.gear.firstWhere((g) => g.id == e.key);
          return _api.updateGear(
            id: item.id,
            name: item.name,
            divisionId: item.divisionId,
            quantity: e.value,
            notes: item.notes,
          );
        }),
      );
      await _refreshGear();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}
