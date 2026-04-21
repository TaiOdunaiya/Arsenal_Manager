import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
    test('populates gear, divisions, and stats', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      final state = container.read(arsenalProvider);

      expect(state.gear.length, 3);
      expect(state.divisions.length, 2);
      expect(state.stats.totalGear, 3);
      expect(state.loading, false);
      expect(state.error, isNull);
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
          );

      expect(success, true);
      final gear = container.read(arsenalProvider).gear;
      expect(gear.length, 4);
      expect(gear.any((g) => g.name == 'Smoke Pellets'), true);
    });

    test('updates stats after adding a new item', () async {
      final fake = FakeApiService();
      final container = await makeContainer(fake);
      addTearDown(container.dispose);

      await container.read(arsenalProvider.notifier).addGear(
            name: 'Smoke Pellets',
            divisionId: 1,
            quantity: 50,
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

    test('updates stats after deletion', () async {
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
}
