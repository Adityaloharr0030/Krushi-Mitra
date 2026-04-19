import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/screens/auth_screens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _weatherAlerts = true;
  bool _schemeAlerts = true;
  bool _priceAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStone,
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHero(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 32),
            _buildPreferencesSection(),
            const SizedBox(height: 40),
            _buildLogoutButton(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHero() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person_outline, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ramesh Patil',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Nashik, Maharashtra',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  '2.5 Acres | Onion, Wheat',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildActionButton('Edit Farm', Icons.landscape_outlined)),
          const SizedBox(width: 16),
          Expanded(child: _buildActionButton('History', Icons.history_outlined)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          _buildSettingsTile('Language', 'English', Icons.language_outlined),
          _buildSwitchTile('AI Advisories', 'Spraying & crop care alerts', _weatherAlerts, (v) => setState(() => _weatherAlerts = v), Icons.wb_sunny_outlined),
          _buildSwitchTile('Govt Schemes', 'New benefits & deadlines', _schemeAlerts, (v) => setState(() => _schemeAlerts = v), Icons.account_balance_outlined),
          _buildSwitchTile('Mandi Alerts', 'Target price notifications', _priceAlerts, (v) => setState(() => _priceAlerts = v), Icons.storefront_outlined),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: AppColors.textHint)),
          const Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged, IconData icon) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primaryGreen),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryGreen,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Sign Out of Account', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
