import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
// Auth screens

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../onboarding/screens/language_selection_screen.dart';
import '../../onboarding/screens/profile_setup_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _weatherAlerts = true;
  bool _schemeAlerts = true;
  bool _priceAlerts = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Settings'),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) => SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(profile),
              const SizedBox(height: 16),
              _buildSettingsSection(profile),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: Text('Logout Account', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    final name = profile?.name ?? 'Guest User';
    final location = profile != null ? '${profile.district}, ${profile.state}' : 'Location not set';
    final farmInfo = profile != null ? 'Farm: ${profile.landSize} Acres • ${profile.cropsGrown.join(", ")}' : 'Complete profile for full access';

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppTheme.celestialGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 44,
              backgroundColor: Colors.white,
              backgroundImage: profile?.photoUrl != null ? NetworkImage(profile!.photoUrl!) : null,
              child: profile?.photoUrl == null ? const Text('👨‍🌾', style: TextStyle(fontSize: 40)) : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 26, 
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        farmInfo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
                        );
                      },
                      icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                      tooltip: 'Edit Profile',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(dynamic profile) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Preferences',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(Icons.language_rounded, 'Language (भाषा)', profile?.preferredLanguage?.toUpperCase() ?? 'English', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()));
          }),
          _buildSwitchTile(
            Icons.dark_mode_rounded, 
            'Dark Mode', 
            isDark, 
            (val) => ref.read(themeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light)
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Text(
            'Push Notifications',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            Icons.wb_sunny_rounded, 
            'Weather & AI Alerts', 
            _weatherAlerts, 
            (val) => setState(() => _weatherAlerts = val),
            subtitle: 'Spraying limits, extreme rain',
          ),
          _buildSwitchTile(
            Icons.account_balance_rounded, 
            'Government Schemes', 
            _schemeAlerts, 
            (val) => setState(() => _schemeAlerts = val),
            subtitle: 'New schemes & deadlines',
          ),
          _buildSwitchTile(
            Icons.storefront_rounded, 
            'Mandi Price Alerts', 
            _priceAlerts, 
            (val) => setState(() => _priceAlerts = val),
            subtitle: 'When prices cross thresholds',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String value, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryEmerald.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryEmerald, size: 22),
      ),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Function(bool) onChanged, {String? subtitle}) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryEmerald.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryEmerald, size: 22),
      ),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)) : null,
      value: value,
      activeThumbColor: AppColors.primaryEmerald,
      onChanged: onChanged,
    );
  }
}
