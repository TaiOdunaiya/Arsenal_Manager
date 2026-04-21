import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/arsenal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bat_app_bar.dart';
import '../widgets/gear_card.dart';
import 'add_gear_screen.dart';
import 'edit_gear_screen.dart';

class ArsenalScreen extends ConsumerWidget {
  const ArsenalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arsenal = ref.watch(arsenalProvider);
    final notifier = ref.read(arsenalProvider.notifier);

    return Scaffold(
      appBar: const BatAppBar(title: 'ARSENAL'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: notifier.setSearch,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search gear...',
                prefixIcon:
                    Icon(Icons.search, color: AppTheme.textSecondary),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          if (arsenal.divisions.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _DivisionChip(
                    label: 'All',
                    selected: arsenal.selectedDivisionId == null,
                    onTap: () => notifier.setDivisionFilter(null),
                  ),
                  ...arsenal.divisions.map((d) => _DivisionChip(
                        label: d.name,
                        selected: arsenal.selectedDivisionId == d.id,
                        onTap: () => notifier.setDivisionFilter(d.id),
                      )),
                ],
              ),
            ),
          const SizedBox(height: 8),
          if (arsenal.loading)
            const LinearProgressIndicator(
              color: AppTheme.wayneBlue,
              backgroundColor: AppTheme.cardSurface,
            ),
          Expanded(
            child: arsenal.filteredGear.isEmpty
                ? Center(
                    child: Text(
                      arsenal.searchQuery.isNotEmpty
                          ? 'No gear found'
                          : 'Arsenal is empty',
                      style:
                          const TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: arsenal.filteredGear.length,
                    itemBuilder: (context, index) {
                      final item = arsenal.filteredGear[index];
                      return GearCard(
                        item: item,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditGearScreen(item: item),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddGearScreen()),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.wayneBlue.withOpacity(0.12),
                  border: Border.all(color: AppTheme.wayneBlue, width: 1.5),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppTheme.wayneBlue,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DivisionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DivisionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppTheme.wayneBlue : AppTheme.cardElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppTheme.wayneBlue
                  : AppTheme.wayneBlue.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppTheme.wayneBlue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
