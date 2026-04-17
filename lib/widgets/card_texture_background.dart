import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Full-bleed [web/bg-section2.jpg] with a light scrim so foreground text stays readable.
class CardTextureBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CardTextureBackground({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  static const String _assetPath = 'web/bg-section2.jpg';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Image.asset(
              _assetPath,
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
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
