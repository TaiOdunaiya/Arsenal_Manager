import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gear_item.dart';
import '../theme/app_theme.dart';
import 'card_texture_background.dart';
import 'status_badge.dart';

class GearCard extends StatelessWidget {
  final GearItem item;
  final VoidCallback? onTap;

  const GearCard({super.key, required this.item, this.onTap});

  Color get _statusColor => switch (item.status) {
    StockStatus.inStock => AppTheme.inStock,
    StockStatus.lowStock => AppTheme.lowStock,
    StockStatus.critical => AppTheme.critical,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
        ),
        child: CardTextureBackground(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.orbitron(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.divisionName,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.quantity}',
                    style: GoogleFonts.orbitron(
                      color: _statusColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(status: item.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
