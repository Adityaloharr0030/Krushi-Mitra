import 'package:flutter/material.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/weather_card.dart';
import '../../../core/services/weather_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('नमस्ते, Farmer! 🙏'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Card(
              color: Colors.amber.shade100,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(child: Text('Heavy rain expected tomorrow. Avoid spraying.')),
                  ],
                ),
              ),
            ),
             const SizedBox(height: 16),
             WeatherCard(weather: WeatherData(
                 temperature: 28.5, feelsLike: 31, condition: 'Clear', description: 'Sunny Skies',
                 humidity: 45, windSpeed: 12, rainChance: 0, cityName: 'Pune', uvIndex: 7, 
                 hourlyForecasts: [], dailyForecasts: [], farmingAdvice: 'Good day for spraying'
             )),
             const SizedBox(height: 24),
             const Text(
               'Quick Actions',
               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 16),
             const SizedBox(height: 16),
             const QuickActionGrid(),
          ],
        ),
      ),
    );
  }
}

