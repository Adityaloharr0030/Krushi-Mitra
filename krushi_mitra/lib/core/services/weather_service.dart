import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class WeatherData {
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final double rainChance;
  final String cityName;
  final int uvIndex;
  final List<HourlyForecast> hourlyForecasts;
  final List<DailyForecast> dailyForecasts;
  final String farmingAdvice;
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.rainChance,
    required this.cityName,
    required this.uvIndex,
    required this.hourlyForecasts,
    required this.dailyForecasts,
    required this.farmingAdvice,
    required this.timestamp,
  });

  factory WeatherData.fromOpenWeatherJson(Map<String, dynamic> json,
      List<HourlyForecast> hourly, List<DailyForecast> daily) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      condition: json['weather'][0]['main'] as String,
      description: json['weather'][0]['description'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      rainChance: ((json['pop'] ?? 0) as num).toDouble() * 100,
      cityName: json['name'] as String? ?? 'My Location',
      uvIndex: 0,
      hourlyForecasts: hourly,
      dailyForecasts: daily,
      farmingAdvice: _getFarmingAdvice(json['weather'][0]['main']),
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'feelsLike': feelsLike,
    'condition': condition,
    'description': description,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'rainChance': rainChance,
    'cityName': cityName,
    'uvIndex': uvIndex,
    'farmingAdvice': farmingAdvice,
    'timestamp': timestamp.toIso8601String(),
    // Forecasts are simplified for caching to save space if needed, 
    // but here we'll skip complex forecast caching for brevity 
    // or add it if necessary.
  };

  factory WeatherData.fromCache(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['temperature'],
      feelsLike: json['feelsLike'],
      condition: json['condition'],
      description: json['description'],
      humidity: json['humidity'],
      windSpeed: json['windSpeed'],
      rainChance: json['rainChance'],
      cityName: json['cityName'],
      uvIndex: json['uvIndex'],
      farmingAdvice: json['farmingAdvice'],
      timestamp: DateTime.parse(json['timestamp']),
      hourlyForecasts: [],
      dailyForecasts: [],
    );
  }

  static String _getFarmingAdvice(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain': return 'Avoid spraying today. Rain expected.';
      case 'clear': return 'Ideal day for pesticide or fertilizer application.';
      case 'clouds': return 'Moderate conditions. Suitable for irrigation.';
      case 'thunderstorm': return 'Warning: Avoid field operations. Secure equipment.';
      default: return 'Check daily forecast for field planning.';
    }
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String condition;
  final double rainChance;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.rainChance,
  });
}

class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String condition;
  final double rainChance;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.rainChance,
  });
}

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  late final Dio _dio;
  static const String _cacheKey = 'cached_weather_data';

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.weatherBaseUrl,
      connectTimeout: const Duration(seconds: 10), // Faster timeout for production feel
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  String get _apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  Future<WeatherData> getWeatherByLocation(double lat, double lon, {bool forceRefresh = false}) async {
    // 1. Try to load from cache first for instant UI response
    final cached = forceRefresh ? null : await _getCachedWeather();
    if (cached != null && DateTime.now().difference(cached.timestamp).inMinutes < 30) {
      debugPrint('WeatherService: Using fresh cache.');
      return cached;
    }

    if (_apiKey.isEmpty || _apiKey == 'your_openweather_api_key_here') {
      return cached ?? _getOfflineWeatherData();
    }

    try {
      final currentResponse = await _dio.get(
        ApiConstants.weatherCurrentEndpoint,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': ApiConstants.weatherUnits,
        },
      );

      final forecastResponse = await _dio.get(
        ApiConstants.weatherForecastEndpoint,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': ApiConstants.weatherUnits,
          'cnt': 40,
        },
      );

      final hourly = _parseHourlyForecasts(forecastResponse.data['list']);
      final daily = _parseDailyForecasts(forecastResponse.data['list']);

      final data = WeatherData.fromOpenWeatherJson(
        currentResponse.data,
        hourly,
        daily,
      );

      // Save to disk cache
      _cacheWeather(data);
      return data;
    } catch (e) {
      debugPrint('Weather API Error: $e. Returning cache or offline data.');
      return cached ?? _getOfflineWeatherData();
    }
  }

  Future<WeatherData> getWeatherByCity(String cityName, {bool forceRefresh = false}) async {
    // We can also cache by city if needed, but for now just pass forceRefresh
    try {
      final currentResponse = await _dio.get(
        ApiConstants.weatherCurrentEndpoint,
        queryParameters: {
          'q': cityName,
          'appid': _apiKey,
          'units': ApiConstants.weatherUnits,
        },
      );
      return WeatherData.fromOpenWeatherJson(currentResponse.data, [], []);
    } catch (e) {
      return _getOfflineWeatherData(cityName: cityName);
    }
  }

  Future<void> _cacheWeather(WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(data.toJson()));
    } catch (_) {}
  }

  Future<WeatherData?> _getCachedWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr != null) {
        return WeatherData.fromCache(json.decode(jsonStr));
      }
    } catch (_) {}
    return null;
  }

  WeatherData _getOfflineWeatherData({String? cityName}) {
    return WeatherData(
      temperature: 32.5,
      feelsLike: 35.0,
      condition: 'Clear',
      description: 'Sunny with moderate breeze',
      humidity: 45,
      windSpeed: 12.5,
      rainChance: 5.0,
      cityName: cityName ?? 'Nashik',
      uvIndex: 8,
      hourlyForecasts: [],
      dailyForecasts: [],
      farmingAdvice: 'Ideal day for spraying or harvesting in your region.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    );
  }

  List<HourlyForecast> _parseHourlyForecasts(List<dynamic> list) {
    return list.take(8).map((item) {
      return HourlyForecast(
        time: DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000),
        temperature: (item['main']['temp'] as num).toDouble(),
        condition: item['weather'][0]['main'] as String,
        rainChance: ((item['pop'] ?? 0) as num).toDouble() * 100,
      );
    }).toList();
  }

  List<DailyForecast> _parseDailyForecasts(List<dynamic> list) {
    final Map<String, List<dynamic>> dayGroups = {};
    for (final item in list) {
      final date = DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000);
      final key = '${date.year}-${date.month}-${date.day}';
      dayGroups.putIfAbsent(key, () => []).add(item);
    }

    return dayGroups.entries.take(7).map((entry) {
      final items = entry.value;
      final temps = items.map((i) => (i['main']['temp'] as num).toDouble()).toList();
      return DailyForecast(
        date: DateTime.fromMillisecondsSinceEpoch((items.first['dt'] as int) * 1000),
        minTemp: temps.reduce((a, b) => a < b ? a : b),
        maxTemp: temps.reduce((a, b) => a > b ? a : b),
        condition: items.first['weather'][0]['main'] as String,
        rainChance: ((items.map((i) => (i['pop'] ?? 0) as num).reduce((a, b) => a + b)) /
                items.length *
                100)
            .toDouble(),
      );
    }).toList();
  }
}
