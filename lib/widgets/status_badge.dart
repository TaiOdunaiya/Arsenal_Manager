import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gear_item.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final StockStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      StockStatus.inStock => ('IN STOCK', AppTheme.inStock),
      StockStatus.lowStock => ('LOW STOCK', AppTheme.lowStock),
      StockStatus.critical => ('CRITICAL', AppTheme.critical),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
