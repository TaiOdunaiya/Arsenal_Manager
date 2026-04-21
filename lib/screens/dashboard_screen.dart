import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/arsenal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bat_app_bar.dart';
import '../widgets/gear_card.dart';
import '../widgets/card_texture_background.dart';
import '../models/gear_item.dart';
import 'edit_gear_screen.dart';
import 'restock_critical_sheet.dart';

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
    final criticalItems =
        arsenal.gear.where((g) => g.status == StockStatus.critical).toList();
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

            _MissionStatusCard(
              total: arsenal.stats.totalGear,
              inStock: arsenal.stats.inStockCount,
              lowStock: arsenal.stats.lowStockCount,
              critical: arsenal.stats.criticalCount,
            ),

            const SizedBox(height: 24),

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
                    child: GearCard(
                      item: item,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditGearScreen(item: item),
                        ),
                      ),
                    ),
                  )),
              if (criticalItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => RestockCriticalSheet(
                        criticalItems: criticalItems,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.critical,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.bolt, size: 18),
                    label: Text(
                      'RESTOCK ALL CRITICAL',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _MissionStatusCard extends StatelessWidget {
  final int total;
  final int inStock;
  final int lowStock;
  final int critical;

  const _MissionStatusCard({
    required this.total,
    required this.inStock,
    required this.lowStock,
    required this.critical,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (inStock / total * 100).round();
    final Color accent = pct >= 70
        ? AppTheme.inStock
        : pct >= 40
            ? AppTheme.lowStock
            : AppTheme.critical;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
              color: accent.withOpacity(0.1), blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: CardTextureBackground(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MISSION STATUS',
                  style: GoogleFonts.orbitron(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '$pct% READY',
                  style: GoogleFonts.orbitron(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0.0 : inStock / total,
                minHeight: 8,
                backgroundColor: AppTheme.cardElevated,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$inStock in stock · $lowStock low · $critical critical',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
