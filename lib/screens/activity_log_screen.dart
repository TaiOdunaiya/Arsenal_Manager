import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/arsenal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bat_app_bar.dart';

class ActivityLogScreen extends ConsumerWidget {
  const ActivityLogScreen({super.key});

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(arsenalProvider);
    final activity = state.recentActivity;

    return Scaffold(
      appBar: const BatAppBar(title: 'ACTIVITY LOG'),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : activity.isEmpty
              ? Center(
                  child: Text(
                    'No activity yet.',
                    style: GoogleFonts.orbitron(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activity.length,
                  itemBuilder: (context, index) {
                    final entry = activity[index];
                    return _ActivityLogEntry(
                      entry: entry,
                      formattedDate: _formatDate(entry.timestamp),
                    );
                  },
                ),
    );
  }
}

class _ActivityLogEntry extends StatelessWidget {
  final ActivityEntry entry;
  final String formattedDate;

  const _ActivityLogEntry({required this.entry, required this.formattedDate});

  Color get _accentColor => switch (entry.action) {
        ActivityAction.added => AppTheme.inStock,
        ActivityAction.updated => AppTheme.wayneBlue,
        ActivityAction.deleted => AppTheme.critical,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: _accentColor, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.item.name,
                  style: GoogleFonts.orbitron(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.item.divisionName,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _ActionChip(action: entry.action, color: _accentColor),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final ActivityAction action;
  final Color color;

  const _ActionChip({required this.action, required this.color});

  String get _label => switch (action) {
        ActivityAction.added => 'ADDED',
        ActivityAction.updated => 'UPDATED',
        ActivityAction.deleted => 'DELETED',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        _label,
        style: GoogleFonts.orbitron(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
