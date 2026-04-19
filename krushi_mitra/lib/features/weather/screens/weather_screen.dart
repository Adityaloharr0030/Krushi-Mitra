import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/weather_provider.dart';

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

  Widget _buildHeroWeatherCard(dynamic weather) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getWeatherGradient(weather.condition),
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(_getWeatherIcon(weather.condition), size: 160, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperature.round()}°C',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          weather.condition,
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    Icon(_getWeatherIcon(weather.condition), size: 60, color: const Color(0xFFFFD54F)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  weather.location,
                  style: GoogleFonts.manrope(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWeatherStat('Feels like', '${weather.feelsLike.round()}°C'),
                    _buildWeatherStat('Humidity', '${weather.humidity}%'),
                    _buildWeatherStat('Wind Speed', '${weather.windSpeed} km/h'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getWeatherGradient(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('rain')) return [const Color(0xFF1976D2), const Color(0xFF0D47A1)];
    if (condition.contains('cloud')) return [const Color(0xFF607D8B), const Color(0xFF37474F)];
    return [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('sun') || condition.contains('clear')) return Icons.wb_sunny_rounded;
    if (condition.contains('rain')) return Icons.umbrella_rounded;
    if (condition.contains('cloud')) return Icons.cloud_rounded;
    return Icons.wb_cloudy_rounded;
  }

  Widget _buildWeatherStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(fontSize: 12, color: Colors.white60),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
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

  Widget _buildHourlyForecast(dynamic weather) {
    final daily = weather.dailyForecast as List;
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daily.length,
        itemBuilder: (context, index) {
          final day = daily[index];
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day['day'], style: GoogleFonts.manrope(fontSize: 12, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Icon(_getWeatherIcon(day['condition']), size: 24, color: AppColors.primary),
                const SizedBox(height: 4),
                Text('${day['temp']}°', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyForecast(dynamic weather) {
    final daily = weather.dailyForecast as List;
    return Column(
      children: daily.map((day) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(day['day'], style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              ),
              Expanded(
                child: Icon(_getWeatherIcon(day['condition']), size: 24, color: AppColors.primary),
              ),
              Expanded(
                flex: 2,
                child: Text('${day['temp']}° / ${day['temp'] - 8}°', textAlign: TextAlign.center, style: GoogleFonts.manrope(fontSize: 14, color: AppColors.onSurface)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFarmingAdvisories(dynamic weather) {
    final tips = weather.farmingTips as List;
    final colors = [const Color(0xFF2E7D32), const Color(0xFFF57F17), const Color(0xFF1565C0)];
    
    return Column(
      children: List.generate(tips.length, (i) {
        final color = colors[i % colors.length];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tips[i],
                  style: GoogleFonts.manrope(fontSize: 13, color: AppColors.onSurface),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWeatherAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF5350), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thunderstorm Warning',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEF5350),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      weather.location,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Expected in 3 days. Secure your equipment and livestock.',
                  style: GoogleFonts.manrope(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
