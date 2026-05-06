import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/weather_provider.dart';
import '../../../core/services/weather_service.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/providers/smart_context_provider.dart';

enum WeatherInfoTab { temperature, precipitation, wind }

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  WeatherInfoTab _selectedTab = WeatherInfoTab.temperature;
  bool _isDarkMode = true; // Default to Dark as per previous request

  // Theme Constants
  Color get _bg => _isDarkMode ? const Color(0xFF080C14) : const Color(0xFFF8FAFC);
  Color get _surface => _isDarkMode ? const Color(0xFF121A26) : Colors.white;
  Color get _border => _isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  Color get _textPrimary => _isDarkMode ? Colors.white : const Color(0xFF0F172A);
  Color get _textSecondary => _isDarkMode ? Colors.white60 : const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: weatherAsync.when(
        data: (weather) => CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroHeader(weather),
                    const SizedBox(height: 24),
                    _buildTabToggle(),
                    const SizedBox(height: 16),
                    _buildModernChart(weather),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Weekly Forecast'),
                    const SizedBox(height: 12),
                    _buildDailyForecastScroll(weather),
                    const SizedBox(height: 24),
                    _buildSectionTitle('🌾 AI Farming Advisories'),
                    const SizedBox(height: 12),
                    _buildFarmingAdvisories(weather, ref),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.primaryEmerald)),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: _textPrimary))),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: false,
      pinned: true,
      backgroundColor: _bg,
      elevation: 0,
      iconTheme: IconThemeData(color: _textPrimary),
      title: Text(
        'Weather Analytics',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: _textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          icon: Icon(
            _isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            color: _isDarkMode ? Colors.amber : AppColors.primaryEmerald,
          ),
          tooltip: 'Toggle Light/Dark Mode',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroHeader(WeatherData weather) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.celestialGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryEmerald.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                '${weather.temperature.round()}°',
                style: GoogleFonts.outfit(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                weather.condition.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    weather.cityName,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSmallStat(Icons.water_drop_rounded, '${weather.humidity}%'),
              const SizedBox(height: 10),
              _buildSmallStat(Icons.air_rounded, '${weather.windSpeed.round()} km/h'),
              const SizedBox(height: 10),
              _buildSmallStat(Icons.umbrella_rounded, '${weather.rainChance.round()}% Rain'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: _isDarkMode ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem('Temperature', WeatherInfoTab.temperature),
          _buildTabItem('Precipitation', WeatherInfoTab.precipitation),
          _buildTabItem('Wind', WeatherInfoTab.wind),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, WeatherInfoTab tab) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.celestialGradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: isSelected ? Colors.white : _textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernChart(WeatherData weather) {
    final List<HourlyForecast> hourly = weather.hourlyForecasts;
    if (hourly.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: _isDarkMode ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= hourly.length) return const SizedBox.shrink();
                  double val = 0;
                  String unit = '';
                  if (_selectedTab == WeatherInfoTab.temperature) { val = hourly[index].temperature; unit = '°'; }
                  else if (_selectedTab == WeatherInfoTab.precipitation) { val = hourly[index].rainChance; unit = '%'; }
                  else { val = hourly[index].windSpeed; unit = ''; }

                  return Text(
                    '${val.round()}$unit',
                    style: GoogleFonts.outfit(fontSize: 11, color: _textPrimary, fontWeight: FontWeight.w800),
                  );
                },
                reservedSize: 24,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= hourly.length || index % 3 != 0) return const SizedBox.shrink();
                  final hour = hourly[index].time.hour;
                  final ampm = hour >= 12 ? 'pm' : 'am';
                  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      '$displayHour$ampm',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _textSecondary.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: _selectedTab == WeatherInfoTab.precipitation ? 100 : null,
          lineBarsData: [
            LineChartBarData(
              spots: hourly.asMap().entries.map((e) {
                double val = 0;
                if (_selectedTab == WeatherInfoTab.temperature) val = e.value.temperature;
                else if (_selectedTab == WeatherInfoTab.precipitation) val = e.value.rainChance;
                else val = e.value.windSpeed;
                return FlSpot(e.key.toDouble(), val);
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(colors: [_isDarkMode ? Colors.amber : AppColors.primaryEmerald, _isDarkMode ? Colors.orangeAccent : AppColors.neonCyan]),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [(_isDarkMode ? Colors.amber : AppColors.primaryEmerald).withValues(alpha: 0.1), (_isDarkMode ? Colors.amber : AppColors.primaryEmerald).withValues(alpha: 0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyForecastScroll(WeatherData weather) {
    final List<DailyForecast> daily = weather.dailyForecasts;
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daily.length,
        itemBuilder: (context, index) {
          final day = daily[index];
          final isToday = index == 0;
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primaryEmerald.withValues(alpha: 0.1) : _surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isToday ? AppColors.primaryEmerald.withValues(alpha: 0.3) : _border,
              ),
              boxShadow: _isDarkMode ? [] : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('EEE').format(day.date),
                  style: GoogleFonts.plusJakartaSans(
                    color: isToday ? AppColors.primaryEmerald : _textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                _getWeatherIcon(day.condition),
                const SizedBox(height: 12),
                Text(
                  '${day.maxTemp.round()}° ${day.minTemp.round()}°',
                  style: GoogleFonts.outfit(color: _textSecondary, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('sun') || condition.contains('clear')) {
      return const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 24);
    }
    if (condition.contains('rain')) {
      return const Icon(Icons.umbrella_rounded, color: Colors.blueAccent, size: 24);
    }
    return Icon(Icons.wb_cloudy_rounded, color: _isDarkMode ? Colors.white60 : AppColors.primaryEmerald, size: 24);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
    );
  }

  Widget _buildFarmingAdvisories(WeatherData weather, WidgetRef ref) {
    final contextData = ref.watch(ubiquitousContextProvider);
    return FutureBuilder<String>(
      future: AIService().getWeatherAnalysis(contextData),
      builder: (context, snapshot) {
        final advice = snapshot.data ?? weather.farmingAdvice;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
            boxShadow: _isDarkMode ? [] : [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _textPrimary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Text('✨', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  advice,
                  style: GoogleFonts.plusJakartaSans(color: _textPrimary, fontSize: 14, height: 1.6, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
