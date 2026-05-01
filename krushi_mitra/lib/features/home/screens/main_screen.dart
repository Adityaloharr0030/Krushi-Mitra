import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/home_screen.dart';
import '../../govt_schemes/screens/schemes_list_screen.dart';
import '../../market_prices/screens/market_prices_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../ai_doctor/screens/ai_doctor_screen.dart';
import '../../weather/screens/weather_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../onboarding/screens/profile_setup_screen.dart';
import '../../../shared/widgets/loading_widget.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  bool _forceStarted = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AIDoctorScreen(),
    const WeatherScreen(),
    const MarketPricesScreen(),
    const SchemesListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProvider);

    if (_forceStarted) {
      return _buildMainScaffold(null);
    }

    return userProfileAsync.when(
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LoadingWidget(message: 'Syncing your farm data...'),
              const SizedBox(height: 32),
              Text(
                'Taking longer than usual?',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _forceStarted = true),
                child: const Text('Enter as Guest'),
              ),
            ],
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.error),
                const SizedBox(height: 24),
                Text('Connection Issue', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  'We couldn\'t sync your profile. You can continue as a guest or try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => ref.refresh(currentUserProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _forceStarted = true),
                  child: const Text('Continue as Guest'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (profile) {
        final user = ref.read(authServiceProvider).currentUser;
        if (profile == null && user != null && !user.isAnonymous) {
          return const ProfileSetupScreen();
        }
        return _buildMainScaffold(profile);
      },
    );
  }

  Widget _buildMainScaffold(dynamic profile) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
        ),
        child: NavigationBar(
          height: 75,
          backgroundColor: AppColors.background,
          elevation: 0,
          indicatorColor: AppColors.primaryEmerald.withValues(alpha: 0.15),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            _buildNavDestination(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Home'),
            _buildNavDestination(Icons.local_hospital_outlined, Icons.local_hospital_rounded, 'Doctor'),
            _buildNavDestination(Icons.cloud_outlined, Icons.cloud_rounded, 'Weather'),
            _buildNavDestination(Icons.analytics_outlined, Icons.analytics_rounded, 'Market'),
            _buildNavDestination(Icons.account_balance_outlined, Icons.account_balance_rounded, 'Schemes'),
            _buildNavDestination(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination(IconData icon, IconData selectedIcon, String label) {
    return NavigationDestination(
      icon: Icon(icon, color: AppColors.textSecondary, size: 24),
      selectedIcon: Icon(selectedIcon, color: AppColors.primaryEmerald, size: 24),
      label: label,
    );
  }
}
