import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../weather/screens/weather_screen.dart';
import '../../farm_diary/screens/farm_diary_screen.dart';
import '../widgets/market_price_slider.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/weather_card.dart';
import '../../../../core/services/weather_service.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGreetingSection(context),
                const SizedBox(height: 32),
                MarketPriceSlider(),
                const SizedBox(height: 32),
                _buildWeatherSection(context),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: QuickActionGrid(),
                ),
                const SizedBox(height: 40),
                _buildSchemeDeadlines(context),
                const SizedBox(height: 120), // Padding for floating nav
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            child: const Icon(Icons.spa_rounded, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Text(
            'Krushi Mitra',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'नमस्ते, आदित्य! 🙏',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
          ),
          SizedBox(height: 8),
          Text(
            'आपका खेत, आपकी उन्नति',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Local Weather', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherScreen()));
                },
                child: const Text('View Full'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          WeatherCard(weather: WeatherData(
            temperature: 28.5, feelsLike: 31, condition: 'Clear', description: 'Sunny Skies',
            humidity: 45, windSpeed: 12, rainChance: 0, cityName: 'Nashik', uvIndex: 7, 
            hourlyForecasts: [], dailyForecasts: [], farmingAdvice: 'Ideal day for pest control spraying.'
          )),
        ],
      ),
    );
  }

  Widget _buildSchemeDeadlines(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Scheme Deadlines', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.error)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        child: const Icon(Icons.timer_outlined, color: AppColors.error),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('PM-Kisan Update', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('3 days left to verify', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
