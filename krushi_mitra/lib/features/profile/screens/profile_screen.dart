import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../auth/screens/auth_screens.dart'; // Mocking auth out

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _weatherAlerts = true;
  bool _schemeAlerts = true;
  bool _priceAlerts = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton.icon(
                onPressed: () {
                  // Mock Logout Implementation
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => const SplashScreen()),
                    (route) => false
                  );
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Logout', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.surfaceGreenLight,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
            child: const Icon(Icons.person, size: 48, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ramesh Patil', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Nashik, Maharashtra', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Farm: 2.5 Acres | Crops: Onion, Wheat', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('App Preferences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primaryGreen),
            title: const Text('Language (भाषा)'),
            trailing: const Text('English', style: TextStyle(color: Colors.grey, fontSize: 16)),
            onTap: () {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: AppColors.primaryGreen),
            title: const Text('Dark Mode'),
            value: _darkMode,
            activeColor: AppColors.secondaryAmber,
            onChanged: (val) => setState(() => _darkMode = val),
          ),
          
          const Divider(height: 32),
          Text('Push Notifications', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          
          SwitchListTile(
            secondary: const Icon(Icons.wb_sunny, color: AppColors.primaryGreen),
            title: const Text('Weather & AI Alerts'),
            subtitle: const Text('Spraying limits, extreme rain'),
            value: _weatherAlerts,
            activeColor: AppColors.secondaryAmber,
            onChanged: (val) => setState(() => _weatherAlerts = val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.account_balance, color: AppColors.primaryGreen),
            title: const Text('Government Schemes'),
            subtitle: const Text('New schemes & impending deadlines'),
            value: _schemeAlerts,
            activeColor: AppColors.secondaryAmber,
            onChanged: (val) => setState(() => _schemeAlerts = val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.storefront, color: AppColors.primaryGreen),
            title: const Text('Mandi Price Alerts'),
            subtitle: const Text('When targeted crops cross thresholds'),
            value: _priceAlerts,
            activeColor: AppColors.secondaryAmber,
            onChanged: (val) => setState(() => _priceAlerts = val),
          ),
        ],
      ),
    );
  }
}
