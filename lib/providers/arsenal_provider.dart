import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gear_item.dart';
import '../models/division.dart';
import '../models/dashboard_stats.dart';
import '../services/api_service.dart';

// ─── Sentinel for nullable copyWith fields ────────────────────────────────────
const Object _keep = Object();

// ─── Activity log types ───────────────────────────────────────────────────────

enum ActivityAction { added, updated, deleted }

class ActivityEntry {
  final GearItem item;
  final ActivityAction action;
  final DateTime timestamp;

  const ActivityEntry({
    required this.item,
    required this.action,
    required this.timestamp,
  });
}

// ─── State ────────────────────────────────────────────────────────────────────

class ArsenalState {
  final List<GearItem> gear;
  final List<Division> divisions;
  final bool loading;
  final String? error;
  final String searchQuery;
  final int? selectedDivisionId;
  final List<ActivityEntry> deletedItems;

  const ArsenalState({
    required this.gear,
    required this.divisions,
    required this.loading,
    this.error,
    this.searchQuery = '',
    this.selectedDivisionId,
    this.deletedItems = const [],
  });

  factory ArsenalState.initial() => const ArsenalState(
        gear: [],
        divisions: [],
        loading: false,
      );

  DashboardStats get stats => DashboardStats(
        totalGear: gear.length,
        criticalCount:
            gear.where((g) => g.status == StockStatus.critical).length,
        lowStockCount:
            gear.where((g) => g.status == StockStatus.lowStock).length,
        inStockCount:
            gear.where((g) => g.status == StockStatus.inStock).length,
      );

  ArsenalState copyWith({
    List<GearItem>? gear,
    List<Division>? divisions,
    bool? loading,
    Object? error = _keep,
    String? searchQuery,
    Object? selectedDivisionId = _keep,
    List<ActivityEntry>? deletedItems,
  }) {
    return ArsenalState(
      gear: gear ?? this.gear,
      divisions: divisions ?? this.divisions,
      loading: loading ?? this.loading,
      error: identical(error, _keep) ? this.error : error as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDivisionId: identical(selectedDivisionId, _keep)
          ? this.selectedDivisionId
          : selectedDivisionId as int?,
      deletedItems: deletedItems ?? this.deletedItems,
    );
  }

  List<ActivityEntry> get recentActivity {
    final entries = [
      ...gear.map((item) => ActivityEntry(
            item: item,
            action: item.wasJustAdded ? ActivityAction.added : ActivityAction.updated,
            timestamp: item.updatedAt,
          )),
      ...deletedItems,
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
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
      ]);
      state = state.copyWith(
        gear: results[0] as List<GearItem>,
        divisions: results[1] as List<Division>,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> _refreshGear() async {
    final gear = await _api.fetchGear();
    state = state.copyWith(gear: gear);
  }

  Future<bool> addGear({
    required String name,
    required int divisionId,
    required int quantity,
    required int targetQuantity,
    String? notes,
  }) async {
    try {
      final newItem = await _api.createGear(
        name: name,
        divisionId: divisionId,
        quantity: quantity,
        targetQuantity: targetQuantity,
        notes: notes,
      );
      state = state.copyWith(gear: [...state.gear, newItem]);
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
    required int targetQuantity,
    String? notes,
  }) async {
    try {
      await _api.updateGear(
        id: id,
        name: name,
        divisionId: divisionId,
        quantity: quantity,
        targetQuantity: targetQuantity,
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
      final item = state.gear.firstWhere((g) => g.id == id);
      await _api.deleteGear(id);
      state = state.copyWith(
        gear: state.gear.where((g) => g.id != id).toList(),
        deletedItems: [
          ...state.deletedItems,
          ActivityEntry(
            item: item,
            action: ActivityAction.deleted,
            timestamp: DateTime.now(),
          ),
        ],
      );
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
            targetQuantity: item.targetQuantity,
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
