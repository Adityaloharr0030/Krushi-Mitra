import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/weather_service.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData? weather;
  final bool isLoading;

  const WeatherCard({
    super.key,
    this.weather,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (weather == null) {
      return const Card(
        child: SizedBox(
          height: 120,
          child: Center(child: Text('Weather data unavailable')),
        ),
      );
    }

    return Card(
      color: AppColors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      weather!.cityName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      weather!.description,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.orange, size: 40),
                    const SizedBox(width: 8),
                    Text(
                      '${weather!.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WeatherInfoIcon(icon: Icons.water_drop, label: '${weather!.humidity}%', tooltip: 'Humidity'),
                _WeatherInfoIcon(icon: Icons.air, label: '${weather!.windSpeed} m/s', tooltip: 'Wind Speed'),
                _WeatherInfoIcon(icon: Icons.umbrella, label: '${weather!.rainChance}%', tooltip: 'Rain Chance'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherInfoIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;

  const _WeatherInfoIcon({
    required this.icon,
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
