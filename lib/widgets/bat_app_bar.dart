import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const BatAppBar({super.key, required this.title, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 0,
      titleSpacing: 0,
      centerTitle: false,
      backgroundColor: AppTheme.background,
      elevation: 0,
      title: SizedBox(
        height: kToolbarHeight,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: Center(child: _WayneBatLogo()),
            ),
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: Center(child: _WayneBatLogo()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.orbitron(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppTheme.wayneBlue,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WayneBatLogo extends StatelessWidget {
  const _WayneBatLogo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: ColorFiltered(
        colorFilter:
            const ColorFilter.mode(AppTheme.wayneBlue, BlendMode.srcIn),
        child: Image.asset(
          'web/logo.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
