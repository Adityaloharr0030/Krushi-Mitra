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
    if (hour < 12) return 'सुप्रभात';
    if (hour < 17) return 'नमस्कार';
    return 'शुभ संध्या';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final weatherAsync = ref.watch(weatherProvider);

    final userName = user?.displayName?.split(' ').first ??
        (user?.isAnonymous == true ? 'Kisan' : user?.email?.split('@').first ?? 'Kisan');

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
                        'Quick Actions',
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
                _buildSchemeDeadlines(context),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
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
                colors: [Color(0xFF1B5E20), Color(0xFF00695C)],
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
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.onSurface),
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
            'आपका खेत, आपकी उन्नति',
            style: GoogleFonts.manrope(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
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
                'Local Weather',
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
                  'View Full',
                  style: GoogleFonts.manrope(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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

  Widget _buildSchemeDeadlines(BuildContext context) {
    final schemes = [
      {'icon': '📋', 'title': 'PM-Kisan Update', 'subtitle': '3 days left to verify', 'urgent': true},
      {'icon': '🌱', 'title': 'PMFBY Registration', 'subtitle': 'Last date: 30 Apr 2026', 'urgent': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⏰ Scheme Deadlines',
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
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUrgent
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.outlineVariant.withValues(alpha: 0.2),
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
