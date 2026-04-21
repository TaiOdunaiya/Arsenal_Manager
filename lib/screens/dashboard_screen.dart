import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/arsenal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bat_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/gear_card.dart';
import '../models/gear_item.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arsenal = ref.watch(arsenalProvider);

    if (arsenal.loading && arsenal.gear.isEmpty) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.wayneBlue)),
      );
    }

    final alertItems =
        arsenal.gear.where((g) => g.status != StockStatus.inStock).toList();
    final topGear = [...arsenal.gear]
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    final top3 = topGear.take(3).toList();

    return Scaffold(
      appBar: const BatAppBar(title: 'WAYNE ARMORY'),
      body: RefreshIndicator(
        color: AppTheme.wayneBlue,
        backgroundColor: AppTheme.cardSurface,
        onRefresh: () => ref.read(arsenalProvider.notifier).loadAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (arsenal.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.critical.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppTheme.critical.withOpacity(0.3)),
                ),
                child: const Text(
                  'Connection error — check API server',
                  style: TextStyle(color: AppTheme.critical, fontSize: 13),
                ),
              ),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Gear',
                    value: '${arsenal.stats.totalGear}',
                    accentColor: AppTheme.wayneBlue,
                    icon: Icons.inventory_2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Critical',
                    value: '${arsenal.stats.criticalCount}',
                    accentColor: AppTheme.critical,
                    icon: Icons.warning_amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Low Stock',
                    value: '${arsenal.stats.lowStockCount}',
                    accentColor: AppTheme.lowStock,
                    icon: Icons.warning_amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'In Stock',
                    value: '${arsenal.stats.inStockCount}',
                    accentColor: AppTheme.inStock,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Top Gadgets
            if (top3.isNotEmpty) ...[
              Text(
                'TOP GEAR',
                style: GoogleFonts.orbitron(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              ...top3.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GearCard(item: item),
                  )),
            ],

            const SizedBox(height: 24),

            // Alerts
            if (alertItems.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: AppTheme.critical, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'SUPPLY ALERTS',
                    style: GoogleFonts.orbitron(
                      color: AppTheme.critical,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...alertItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: GearCard(item: item),
                  )),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
