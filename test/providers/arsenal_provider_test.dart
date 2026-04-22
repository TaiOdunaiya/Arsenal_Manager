import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arsenal_manager/models/gear_item.dart';
import 'package:arsenal_manager/providers/arsenal_provider.dart';
import '../fakes/fake_api_service.dart';

/// Creates a [ProviderContainer] wired up to [fake], then awaits
/// the initial [loadAll] so tests start with data already populated.
Future<ProviderContainer> makeContainer(FakeApiService fake) async {
  final container = ProviderContainer(
    overrides: [apiServiceProvider.overrideWithValue(fake)],
  );
  await container.read(arsenalProvider.notifier).loadAll();
  return container;
}

void main() {
  group('loadAll', () {
    test('populates gear and divisions', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      final state = container.read(arsenalProvider);

      expect(state.gear.length, 3);
      expect(state.divisions.length, 2);
      expect(state.loading, false);
      expect(state.error, isNull);
    });

    test('stats are computed client-side from gear list', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      final state = container.read(arsenalProvider);

      // Batarang qty=20/target=30 → 67% → lowStock
      // Grapple Hook qty=5/target=10 → 50% → lowStock
      // Batmobile qty=1/target=3 → 33% → critical
      expect(state.stats.totalGear, 3);
      expect(state.stats.criticalCount, 1);
      expect(state.stats.lowStockCount, 2);
      expect(state.stats.inStockCount, 0);
    });

    test('sets error when API throws, loading returns to false', () async {
      final fake = FakeApiService(shouldThrow: true);
      final container = ProviderContainer(
        overrides: [apiServiceProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      await container.read(arsenalProvider.notifier).loadAll();
      final state = container.read(arsenalProvider);

      expect(state.error, isNotNull);
      expect(state.loading, false);
      expect(state.gear, isEmpty);
    });
  });

  group('addGear (Create)', () {
    test('returns true and appends item to gear list', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      final success = await container.read(arsenalProvider.notifier).addGear(
            name: 'Smoke Pellets',
            divisionId: 1,
            quantity: 50,
            targetQuantity: 60,
          );

      expect(success, true);
      final gear = container.read(arsenalProvider).gear;
      expect(gear.length, 4);
      expect(gear.any((g) => g.name == 'Smoke Pellets'), true);
    });

    test('stats update after adding a new item', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      await container.read(arsenalProvider.notifier).addGear(
            name: 'Smoke Pellets',
            divisionId: 1,
            quantity: 50,
            targetQuantity: 60,
          );

      expect(container.read(arsenalProvider).stats.totalGear, 4);
    });

    test('returns false and sets error when API throws', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      fake.shouldThrow = true;
      final success = await container.read(arsenalProvider.notifier).addGear(
            name: 'Smoke Pellets',
            divisionId: 1,
            quantity: 50,
            targetQuantity: 60,
          );

      expect(success, false);
      expect(container.read(arsenalProvider).error, isNotNull);
      expect(container.read(arsenalProvider).gear.length, 3);
    });
  });

  group('updateGear (Update)', () {
    test('returns true and reflects updated values in gear list', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      final success =
          await container.read(arsenalProvider.notifier).updateGear(
                id: 1,
                name: 'Batarang v2',
                divisionId: 1,
                quantity: 30,
                targetQuantity: 30,
              );

      expect(success, true);
      final updated =
          container.read(arsenalProvider).gear.firstWhere((g) => g.id == 1);
      expect(updated.name, 'Batarang v2');
      expect(updated.quantity, 30);
    });

    test('returns false and sets error when API throws', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      fake.shouldThrow = true;
      final success =
          await container.read(arsenalProvider.notifier).updateGear(
                id: 1,
                name: 'Batarang v2',
                divisionId: 1,
                quantity: 30,
                targetQuantity: 30,
              );

      expect(success, false);
      expect(container.read(arsenalProvider).error, isNotNull);
    });
  });

  group('deleteGear (Delete)', () {
    test('returns true and removes item from gear list', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      final success =
          await container.read(arsenalProvider.notifier).deleteGear(1);

      expect(success, true);
      final gear = container.read(arsenalProvider).gear;
      expect(gear.length, 2);
      expect(gear.any((g) => g.id == 1), false);
    });

    test('stats update after deletion', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      await container.read(arsenalProvider.notifier).deleteGear(1);

      expect(container.read(arsenalProvider).stats.totalGear, 2);
    });

    test('returns false and sets error when API throws', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      fake.shouldThrow = true;
      final success =
          await container.read(arsenalProvider.notifier).deleteGear(1);

      expect(success, false);
      expect(container.read(arsenalProvider).error, isNotNull);
      expect(container.read(arsenalProvider).gear.length, 3);
    });
  });

  group('filtering', () {
    test('setSearch filters gear by name (case insensitive)', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      container.read(arsenalProvider.notifier).setSearch('bat');

      final filtered = container.read(arsenalProvider).filteredGear;
      expect(filtered.length, 2); // Batarang + Batmobile
      expect(filtered.every((g) => g.name.toLowerCase().contains('bat')), true);
    });

    test('setSearch with no match returns empty list', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      container.read(arsenalProvider.notifier).setSearch('zzznomatch');

      expect(container.read(arsenalProvider).filteredGear, isEmpty);
    });

    test('setDivisionFilter filters by division id', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      container.read(arsenalProvider.notifier).setDivisionFilter(2); // Vehicles

      final filtered = container.read(arsenalProvider).filteredGear;
      expect(filtered.length, 1);
      expect(filtered.first.divisionName, 'Vehicles');
    });

    test('setDivisionFilter(null) clears the filter', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      container.read(arsenalProvider.notifier).setDivisionFilter(2);
      container.read(arsenalProvider.notifier).setDivisionFilter(null);

      expect(container.read(arsenalProvider).filteredGear.length, 3);
    });

    test('filteredGear is sorted alphabetically', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      final names =
          container.read(arsenalProvider).filteredGear.map((g) => g.name).toList();
      final sorted = [...names]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      expect(names, sorted);
    });
  });

  group('recentActivity', () {
    test('returns entries sorted by timestamp descending', () {
      final oldest = GearItem(
        id: 1, name: 'Alpha', divisionId: 1, divisionName: 'Gadgets',
        quantity: 5, targetQuantity: 10,
        createdAt: DateTime(2024, 1, 1), updatedAt: DateTime(2024, 1, 1),
      );
      final newest = GearItem(
        id: 2, name: 'Beta', divisionId: 1, divisionName: 'Gadgets',
        quantity: 3, targetQuantity: 10,
        createdAt: DateTime(2024, 3, 1), updatedAt: DateTime(2024, 6, 1),
      );
      final middle = GearItem(
        id: 3, name: 'Gamma', divisionId: 1, divisionName: 'Gadgets',
        quantity: 8, targetQuantity: 10,
        createdAt: DateTime(2024, 2, 1), updatedAt: DateTime(2024, 3, 1),
      );

      final state = ArsenalState(
        gear: [oldest, newest, middle],
        divisions: [],
        loading: false,
      );
      final activity = state.recentActivity;

      expect(activity[0].item.name, 'Beta');
      expect(activity[1].item.name, 'Gamma');
      expect(activity[2].item.name, 'Alpha');
    });

    test('does not mutate the original gear list order', () {
      final a = GearItem(
        id: 1, name: 'First', divisionId: 1, divisionName: 'Gadgets',
        quantity: 5, targetQuantity: 10,
        createdAt: DateTime(2024, 1, 1), updatedAt: DateTime(2024, 1, 1),
      );
      final b = GearItem(
        id: 2, name: 'Second', divisionId: 1, divisionName: 'Gadgets',
        quantity: 3, targetQuantity: 10,
        createdAt: DateTime(2024, 6, 1), updatedAt: DateTime(2024, 6, 1),
      );

      final state = ArsenalState(gear: [a, b], divisions: [], loading: false);
      state.recentActivity;

      expect(state.gear[0].name, 'First');
      expect(state.gear[1].name, 'Second');
    });

    test('deleted item appears in recentActivity with action=deleted', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      await container.read(arsenalProvider.notifier).deleteGear(1);

      final activity = container.read(arsenalProvider).recentActivity;
      final deletedEntry = activity.firstWhere(
        (e) => e.item.id == 1,
        orElse: () => throw StateError('Deleted item not found in activity log'),
      );

      expect(deletedEntry.action, ActivityAction.deleted);
      expect(deletedEntry.item.name, 'Batarang');
    });

    test('deleted item is not in gear list but remains in activity log', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      await container.read(arsenalProvider.notifier).deleteGear(1);

      final state = container.read(arsenalProvider);
      expect(state.gear.any((g) => g.id == 1), false);
      expect(state.recentActivity.any((e) => e.item.id == 1), true);
    });

    test('live gear items have correct action labels', () {
      final added = GearItem(
        id: 1, name: 'New', divisionId: 1, divisionName: 'Gadgets',
        quantity: 5, targetQuantity: 10,
        createdAt: DateTime(2024, 1, 1), updatedAt: DateTime(2024, 1, 1),
      );
      final updated = GearItem(
        id: 2, name: 'Old', divisionId: 1, divisionName: 'Gadgets',
        quantity: 5, targetQuantity: 10,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1).add(const Duration(hours: 1)),
      );

      final state = ArsenalState(gear: [added, updated], divisions: [], loading: false);
      final activity = state.recentActivity;

      expect(activity.firstWhere((e) => e.item.id == 1).action, ActivityAction.added);
      expect(activity.firstWhere((e) => e.item.id == 2).action, ActivityAction.updated);
    });
  });

  group('batchRestockCritical', () {
    test('updates all specified items and refreshes stats', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      // Batmobile (id:3, qty:1/target:3) is critical
      final success = await container
          .read(arsenalProvider.notifier)
          .batchRestockCritical({2: 25, 3: 3});

      expect(success, true);
      final gear = container.read(arsenalProvider).gear;
      expect(gear.firstWhere((g) => g.id == 2).quantity, 25);
      expect(gear.firstWhere((g) => g.id == 3).quantity, 3);
    });

    test('stats are recalculated after restock', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      // Restock Grapple Hook to 10 (100% of target=10) and Batmobile to 3 (100% of target=3)
      await container
          .read(arsenalProvider.notifier)
          .batchRestockCritical({2: 10, 3: 3});

      expect(container.read(arsenalProvider).stats.criticalCount, 0);
      // Batarang 20/30=67% → lowStock; others now inStock
      expect(container.read(arsenalProvider).stats.lowStockCount, 1);
      expect(container.read(arsenalProvider).stats.inStockCount, 2);
    });

    test('returns false and sets error when API throws', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      fake.shouldThrow = true;
      final success = await container
          .read(arsenalProvider.notifier)
          .batchRestockCritical({2: 25});

      expect(success, false);
      expect(container.read(arsenalProvider).error, isNotNull);
    });
  });
}
