import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/weather_provider.dart';
import '../../../core/services/weather_service.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: weatherAsync.when(
        data: (weather) => CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroWeatherCard(weather),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Today\'s Detailed Forecast'),
                    const SizedBox(height: 12),
                    _buildHourlyForecast(weather),
                    const SizedBox(height: 24),
                    _buildSectionTitle('5-Day Forecast'),
                    const SizedBox(height: 12),
                    _buildWeeklyForecast(weather),
                    const SizedBox(height: 24),
                    _buildSectionTitle('🌾 AI Farming Advisories'),
                    const SizedBox(height: 12),
                    _buildFarmingAdvisories(weather),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text(
        'Weather Forecast',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildHeroWeatherCard(WeatherData weather) {
    return Center(
      child: Container(
        height: 300,
        width: 300,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.celestialGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryEmerald.withValues(alpha: 0.3),
              blurRadius: 50,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${weather.temperature.round()}°',
                  style: GoogleFonts.outfit(
                    fontSize: 84,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -4.0,
                  ),
                ),
                Text(
                  weather.condition.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    weather.cityName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 25,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${weather.humidity}% Humidity',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('sun') || condition.contains('clear')) return Icons.wb_sunny_rounded;
    if (condition.contains('rain')) return Icons.umbrella_rounded;
    if (condition.contains('cloud')) return Icons.cloud_rounded;
    return Icons.wb_cloudy_rounded;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildHourlyForecast(WeatherData weather) {
    final List<HourlyForecast> hourly = weather.hourlyForecasts;
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        itemBuilder: (context, index) {
          final hour = hourly[index];
          final timeStr = "${hour.time.hour}:00";
          return Container(
            width: 85,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeStr,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Icon(_getWeatherIcon(hour.condition), size: 28, color: AppColors.primaryEmerald),
                const SizedBox(height: 12),
                Text(
                  '${hour.temperature.round()}°',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyForecast(WeatherData weather) {
    final List<DailyForecast> daily = weather.dailyForecasts;
    return Column(
      children: daily.map((day) {
        final dayName = _getDayName(day.date.weekday);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  dayName.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 1.5),
                ),
              ),
              Icon(_getWeatherIcon(day.condition), size: 24, color: AppColors.primaryEmerald),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Text(
                  '${day.maxTemp.round()}° / ${day.minTemp.round()}°',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFarmingAdvisories(WeatherData weather) {
    final String advice = weather.farmingAdvice;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryEmerald.withValues(alpha: 0.08), AppColors.primaryEmerald.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Text('✨', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              advice,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, 
                color: AppColors.textPrimary,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
