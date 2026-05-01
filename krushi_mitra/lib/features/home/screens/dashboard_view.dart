import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/weather_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../weather/screens/weather_screen.dart';
import '../widgets/market_price_slider.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/weather_card.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Suprabhat';
    if (hour < 17) return 'Namaste';
    return 'Shubh Sandhya';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (user) {
        final userName = user?.name.split(' ').first ?? 'Farmer';

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, ref),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGreetingSection(userName),
                    const SizedBox(height: 28),
                    const MarketPriceSlider(),
                    const SizedBox(height: 28),
                    _buildWeatherSection(context, weatherAsync),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Smart Services',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: QuickActionGrid(),
                    ),
                    const SizedBox(height: 28),
                    _buildSchemeReminders(context),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF0891B2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🌿', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Text(
            'Krushi Mitra',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.onSurface,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none_rounded, color: AppColors.onSurface),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGreetingSection(String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()}, $userName! 🙏',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your Digital Farm Partner',
            style: GoogleFonts.manrope(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection(BuildContext context, AsyncValue weatherAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Regional Weather',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeatherScreen()),
                ),
                child: Text(
                  'Full Forecast',
                  style: GoogleFonts.manrope(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          weatherAsync.when(
            data: (weather) => WeatherCard(weather: weather),
            loading: () => const WeatherCard(isLoading: true),
            error: (_, __) => const WeatherCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeReminders(BuildContext context) {
    // Official upcoming deadlines for real Indian schemes
    final schemes = [
      {'icon': '📜', 'title': 'PM-Kisan KYC', 'subtitle': 'Mandatory verification', 'urgent': true},
      {'icon': '☁️', 'title': 'Kharif Insurance', 'subtitle': 'Enrollment starts soon', 'urgent': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⏰ Important Reminders',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                final s = schemes[index];
                final isUrgent = s['urgent'] as bool;
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceObsidian,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUrgent
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? AppColors.errorContainer.withValues(alpha: 0.3)
                              : AppColors.primaryContainer.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(s['icon'] as String, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s['title'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s['subtitle'] as String,
                              style: GoogleFonts.manrope(
                                color: isUrgent ? AppColors.error : AppColors.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
