import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/arsenal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bat_app_bar.dart';
import '../widgets/card_texture_background.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arsenal = ref.watch(arsenalProvider);
    final stats = arsenal.stats;
    final total = stats.totalGear;

    final sections = total == 0
        ? <PieChartSectionData>[
            PieChartSectionData(
                value: 1, color: AppTheme.cardElevated, title: ''),
          ]
        : [
            if (stats.inStockCount > 0)
              PieChartSectionData(
                value: stats.inStockCount.toDouble(),
                color: AppTheme.inStock,
                title: '${(stats.inStockCount / total * 100).round()}%',
                titleStyle: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                radius: 80,
              ),
            if (stats.lowStockCount > 0)
              PieChartSectionData(
                value: stats.lowStockCount.toDouble(),
                color: AppTheme.lowStock,
                title: '${(stats.lowStockCount / total * 100).round()}%',
                titleStyle: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                radius: 80,
              ),
            if (stats.criticalCount > 0)
              PieChartSectionData(
                value: stats.criticalCount.toDouble(),
                color: AppTheme.critical,
                title: '${(stats.criticalCount / total * 100).round()}%',
                titleStyle: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                radius: 80,
              ),
          ];

    return Scaffold(
      appBar: const BatAppBar(title: 'STATS'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Donut chart — square box so the pie is not clipped
          LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.maxWidth;
              return SizedBox(
                width: side,
                height: side,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'web/bg-section2.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface.withOpacity(0.78),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: PieChart(
                            PieChartData(
                              sections: sections,
                              centerSpaceRadius: 60,
                              sectionsSpace: 3,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(
                  color: AppTheme.inStock,
                  label: 'In Stock',
                  count: stats.inStockCount),
              _LegendItem(
                  color: AppTheme.lowStock,
                  label: 'Low Stock',
                  count: stats.lowStockCount),
              _LegendItem(
                  color: AppTheme.critical,
                  label: 'Critical',
                  count: stats.criticalCount),
            ],
          ),

          const SizedBox(height: 32),

          // Summary cards
          _SummaryRow(
            label: 'TOTAL GEAR ITEMS',
            value: '$total',
            color: AppTheme.wayneBlue,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'FULLY STOCKED',
            value: '${stats.inStockCount}',
            color: AppTheme.inStock,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'NEED RESUPPLY',
            value: '${stats.lowStockCount}',
            color: AppTheme.lowStock,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'CRITICAL ALERT',
            value: '${stats.criticalCount}',
            color: AppTheme.critical,
          ),

          const SizedBox(height: 32),

          // Division breakdown
          Text(
            'BY DIVISION',
            style: GoogleFonts.orbitron(
              color: AppTheme.textSecondary,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          ...arsenal.divisions.map((division) {
            final items = arsenal.gear
                .where((g) => g.divisionId == division.id)
                .toList();
            final divTotal =
                items.fold<int>(0, (sum, g) => sum + g.quantity);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CardTextureBackground(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(division.name,
                        style:
                            const TextStyle(color: AppTheme.wayneBlue)),
                    Text(
                      '$divTotal units · ${items.length} items',
                      style: const TextStyle(
                          color: AppTheme.wayneBlue, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text('$count',
            style: GoogleFonts.orbitron(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: CardTextureBackground(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.orbitron(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.5),
            ),
            Text(
              value,
              style: GoogleFonts.orbitron(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
