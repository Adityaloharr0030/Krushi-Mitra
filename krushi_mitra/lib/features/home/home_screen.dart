import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'screens/dashboard_view.dart';
import '../ai_doctor/screens/ai_doctor_screen.dart'; // Point to the refactored one
import '../govt_schemes/screens/schemes_list_screen.dart';
import '../market_prices/screens/mandi_prices_screen.dart';
import '../community/screens/community_screen.dart';
import '../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardView(),
    const AIDoctorScreen(), // Using the refactored AIDoctorScreen
    const SchemesListScreen(),
    const MandiPricesScreen(),
    const CommunityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStone,
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _buildBottomNav(),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? Padding(
        padding: const EdgeInsets.only(bottom: 100), // Adjust for floating nav
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primaryGreen,
          elevation: 4,
          child: const Icon(Icons.mic_none_rounded, size: 32, color: Colors.white),
        ),
      ) : null,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.auto_awesome_rounded, 'Doctor'),
          _buildNavItem(2, Icons.account_balance_rounded, 'Schemes'),
          _buildNavItem(3, Icons.storefront_rounded, 'Market'),
          _buildNavItem(4, Icons.people_rounded, 'Community'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryGreen : AppColors.textHint,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryGreen : AppColors.textHint,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
