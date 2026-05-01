import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final double elevation;
  final bool useGradient;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.elevation = 0,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: useGradient ? Colors.white : AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      elevation: elevation,
      automaticallyImplyLeading: false,
      leading: showBackButton ? IconButton(
        icon: Icon(Icons.chevron_left_rounded, color: useGradient ? Colors.white : AppColors.textPrimary, size: 28),
        onPressed: () => Navigator.maybePop(context),
      ) : null,
      flexibleSpace: useGradient ? Container(
        decoration: BoxDecoration(
          gradient: AppTheme.celestialGradient,
        ),
      ) : null,
      backgroundColor: useGradient ? Colors.transparent : AppColors.backgroundCloud,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}
