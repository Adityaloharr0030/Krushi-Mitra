import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../data/models/weather_model.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Mock Data
  final WeatherData _currentWeather = WeatherData(
    temperature: 32,
    humidity: 65,
    windSpeed: 12,
    rainfall: 0,
    condition: 'Sunny',
    date: DateTime.now(),
  );

  final List<WeatherData> _forecast = List.generate(7, (index) => WeatherData(
    temperature: 30.0 + (index % 4),
    humidity: 60.0 + (index * 2),
    windSpeed: 10.0 + index,
    rainfall: index > 4 ? 15.0 : 0.0,
    condition: index > 4 ? 'Rainy' : 'Sunny',
    date: DateTime.now().add(Duration(days: index + 1)),
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather & Alerts'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentWeatherCard(),
            const SizedBox(height: 24),
            _buildAIAdviceSection(),
            const SizedBox(height: 24),
            Text('7-Day Forecast', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildForecastList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nashik, MH', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(DateFormat('EEEE, MMM d').format(_currentWeather.date), style: const TextStyle(color: Colors.white70)),
                ],
              ),
              const Icon(Icons.wb_sunny, size: 48, color: AppColors.secondaryLight),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_currentWeather.temperature.toInt()}°', style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildWeatherDetailRow(Icons.water_drop, 'Humidity', '${_currentWeather.humidity.toInt()}%'),
                  const SizedBox(height: 8),
                  _buildWeatherDetailRow(Icons.air, 'Wind', '${_currentWeather.windSpeed.toInt()} km/h'),
                  const SizedBox(height: 8),
                  _buildWeatherDetailRow(Icons.umbrella, 'Rain', '${_currentWeather.rainfall.toInt()} mm'),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAIAdviceSection() {
    return Card(
      color: AppColors.surfaceGreenLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text('Krushi Mitra Advice', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryGreen)),
              ],
            ),
            const Divider(height: 24),
            _buildAdviceRow(Icons.check_circle, Colors.green, 'Good time to spray pesticides today. Low wind speed prevents drift.'),
            const SizedBox(height: 12),
            _buildAdviceRow(Icons.warning, AppColors.warning, 'Irrigation not needed today. Soil moisture is sufficient.'),
            const SizedBox(height: 12),
            _buildAdviceRow(Icons.error, AppColors.error, 'Heavy rain expected on Sunday. Delay harvesting if planned.'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildForecastList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _forecast.length,
      itemBuilder: (context, index) {
        final weather = _forecast[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  DateFormat('EEEE').format(weather.date),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Row(
                children: [
                  Icon(weather.condition == 'Rainy' ? Icons.water_drop : Icons.wb_sunny, 
                    color: weather.condition == 'Rainy' ? Colors.blue : AppColors.secondaryAmber, size: 20),
                  const SizedBox(width: 8),
                  Text('${weather.rainfall > 0 ? weather.rainfall.toInt() : 0}%', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              Row(
                children: [
                  Text('${weather.temperature.toInt()}°', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('${(weather.temperature - 6).toInt()}°', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
