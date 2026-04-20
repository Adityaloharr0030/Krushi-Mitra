import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../weather/screens/weather_screen.dart';
import '../../farm_diary/screens/diary_home_screen.dart';
import '../../../shared/widgets/offline_banner.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mock Offline Banner for demonstration
          OfflineBanner(lastUpdated: DateTime.now().subtract(const Duration(hours: 2))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Greeting & Weather Card
                _buildWeatherGreetingCard(context),
          const SizedBox(height: 24),
          
          // Action Grid
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildActionGrid(context),
          const SizedBox(height: 24),

          // Upcoming Schemes Horizontal Scroll
          Text(
            'Scheme Deadlines',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.error,
            ),
          ),
                const SizedBox(height: 16),
                _buildSchemesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherGreetingCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ram Ram, Ramesh!', // Mock data
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.surfaceWhite,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.surfaceWhite, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Nashik, MH',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.surfaceWhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.wb_sunny, color: AppColors.secondaryAmber, size: 40),
              const SizedBox(height: 4),
              Text(
                '32°C',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.surfaceWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      {'icon': Icons.document_scanner, 'title': 'Crop Doctor', 'color': Colors.teal},
      {'icon': Icons.account_balance, 'title': 'Schemes', 'color': Colors.blue},
      {'icon': Icons.storefront, 'title': 'Mandi Prices', 'color': Colors.orange},
      {'icon': Icons.cloud, 'title': 'Weather', 'color': Colors.lightBlue},
      {'icon': Icons.people, 'title': 'Community', 'color': Colors.purple},
      {'icon': Icons.book, 'title': 'Farm Diary', 'color': Colors.brown},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (action['title'] == 'Farm Diary') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DiaryHomeScreen()));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action['icon'] as IconData, size: 40, color: action['color'] as Color),
                  const SizedBox(height: 12),
                  Text(
                    action['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSchemesList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border.all(color: AppColors.error.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('PM-Kisan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                      child: const Text('3 Days left', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('₹6,000 / year • Apply Now', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
