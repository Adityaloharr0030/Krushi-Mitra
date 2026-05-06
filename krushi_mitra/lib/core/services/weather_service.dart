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
  final List<DailyForecast> historicalForecasts;
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
    required this.historicalForecasts,
    required this.farmingAdvice,
    required this.timestamp,
  });

  factory WeatherData.fromOpenWeatherJson(
    Map<String, dynamic> current,
    List<HourlyForecast> hourly,
    List<DailyForecast> daily,
    List<DailyForecast> historical,
  ) {
    final weather = current['weather'][0];
    final main = current['main'];
    final wind = current['wind'];
    final condition = weather['main'] as String;

    return WeatherData(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      condition: condition,
      description: weather['description'] as String,
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      rainChance: hourly.isNotEmpty ? hourly.first.rainChance : 0.0,
      cityName: current['name'] as String,
      uvIndex: 5, // OpenWeather basic API doesn't provide UV in current weather
      hourlyForecasts: hourly,
      dailyForecasts: daily,
      historicalForecasts: historical,
      farmingAdvice: _generateFarmingAdvice(condition.toLowerCase(), (main['temp'] as num).toDouble()),
      timestamp: DateTime.now(),
    );
  }

  static String _generateFarmingAdvice(String condition, double temp) {
    if (temp > 35) return 'Extreme heat detected. Irrigate crops in early morning to prevent moisture loss and leaf burn.';
    if (condition.contains('rain')) return 'Rain predicted. Postpone any fertilizer or pesticide spraying to avoid runoff.';
    switch (condition) {
      case 'clear': return 'Ideal day for pesticide or fertilizer application. Good sunlight for photosynthesis.';
      case 'clouds': return 'Moderate conditions. Suitable for general field maintenance and irrigation.';
      case 'thunderstorm': return 'Warning: Severe weather. Avoid field operations and secure loose equipment.';
      default: return 'Favorable conditions for farming. Monitor soil moisture regularly.';
    }
  }

  Map<String, dynamic> toJson() => {
    'temp': temperature,
    'feelsLike': feelsLike,
    'condition': condition,
    'desc': description,
    'humidity': humidity,
    'wind': windSpeed,
    'rain': rainChance,
    'city': cityName,
    'uv': uvIndex,
    'hourly': hourlyForecasts.map((e) => e.toJson()).toList(),
    'daily': dailyForecasts.map((e) => e.toJson()).toList(),
    'historical': historicalForecasts.map((e) => e.toJson()).toList(),
    'advice': farmingAdvice,
    'time': timestamp.toIso8601String(),
  };

  factory WeatherData.fromCache(Map<String, dynamic> j) {
    return WeatherData(
      temperature: j['temp'],
      feelsLike: j['feelsLike'],
      condition: j['condition'],
      description: j['desc'],
      humidity: j['humidity'],
      windSpeed: j['wind'],
      rainChance: j['rain'],
      cityName: j['city'],
      uvIndex: j['uv'],
      hourlyForecasts: (j['hourly'] as List).map((e) => HourlyForecast.fromJson(e)).toList(),
      dailyForecasts: (j['daily'] as List).map((e) => DailyForecast.fromJson(e)).toList(),
      historicalForecasts: (j['historical'] as List).map((e) => DailyForecast.fromJson(e)).toList(),
      farmingAdvice: j['advice'],
      timestamp: DateTime.parse(j['time']),
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String condition;
  final double rainChance;
  final double windSpeed;
  final int humidity;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.rainChance,
    required this.windSpeed,
    required this.humidity,
  });

  Map<String, dynamic> toJson() => {
    'dt': time.millisecondsSinceEpoch ~/ 1000,
    'temp': temperature,
    'cond': condition,
    'rain': rainChance,
    'wind': windSpeed,
    'hum': humidity,
  };

  factory HourlyForecast.fromJson(Map<String, dynamic> j) => HourlyForecast(
    time: DateTime.fromMillisecondsSinceEpoch(j['dt'] * 1000),
    temperature: j['temp'],
    condition: j['cond'],
    rainChance: j['rain'],
    windSpeed: j['wind'],
    humidity: j['hum'],
  );
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

  Map<String, dynamic> toJson() => {
    'dt': date.millisecondsSinceEpoch ~/ 1000,
    'min': minTemp,
    'max': maxTemp,
    'cond': condition,
    'rain': rainChance,
  };

  factory DailyForecast.fromJson(Map<String, dynamic> j) => DailyForecast(
    date: DateTime.fromMillisecondsSinceEpoch(j['dt'] * 1000),
    minTemp: j['min'],
    maxTemp: j['max'],
    condition: j['cond'],
    rainChance: j['rain'],
  );
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
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  String get _apiKey => dotenv.env['OPENWEATHER_KEY'] ?? '';

  Future<WeatherData> getWeatherByLocation(double lat, double lon, {bool forceRefresh = false}) async {
    final cached = forceRefresh ? null : await _getCachedWeather();
    if (cached != null && DateTime.now().difference(cached.timestamp).inMinutes < 30) {
      return cached;
    }

    if (_apiKey.isEmpty) return cached ?? _getOfflineWeatherData();

    try {
      final responses = await Future.wait([
        _dio.get(ApiConstants.weatherCurrentEndpoint, queryParameters: {'lat': lat, 'lon': lon, 'appid': _apiKey, 'units': ApiConstants.weatherUnits}),
        _dio.get(ApiConstants.weatherForecastEndpoint, queryParameters: {'lat': lat, 'lon': lon, 'appid': _apiKey, 'units': ApiConstants.weatherUnits, 'cnt': 40}),
      ]);

      final hourly = _parseHourlyForecasts(responses[1].data['list']);
      final daily = _parseDailyForecasts(responses[1].data['list']);
      final data = WeatherData.fromOpenWeatherJson(responses[0].data, hourly, daily, _generateMockHistorical());

      _cacheWeather(data);
      return data;
    } catch (e) {
      return cached ?? _getOfflineWeatherData();
    }
  }

  Future<WeatherData> getWeatherByCity(String cityName, {bool forceRefresh = false}) async {
    final cached = forceRefresh ? null : await _getCachedWeather();
    if (cached != null && cached.cityName.toLowerCase() == cityName.toLowerCase() && DateTime.now().difference(cached.timestamp).inMinutes < 30) {
      return cached;
    }

    if (_apiKey.isEmpty) return _getOfflineWeatherData(cityName: cityName);

    try {
      final responses = await Future.wait([
        _dio.get(ApiConstants.weatherCurrentEndpoint, queryParameters: {'q': cityName, 'appid': _apiKey, 'units': ApiConstants.weatherUnits}),
        _dio.get(ApiConstants.weatherForecastEndpoint, queryParameters: {'q': cityName, 'appid': _apiKey, 'units': ApiConstants.weatherUnits, 'cnt': 40}),
      ]);

      final hourly = _parseHourlyForecasts(responses[1].data['list']);
      final daily = _parseDailyForecasts(responses[1].data['list']);
      final data = WeatherData.fromOpenWeatherJson(responses[0].data, hourly, daily, _generateMockHistorical());

      _cacheWeather(data);
      return data;
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
      if (jsonStr != null) return WeatherData.fromCache(json.decode(jsonStr));
    } catch (_) {}
    return null;
  }

  WeatherData _getOfflineWeatherData({String? cityName}) {
    final now = DateTime.now();
    final mockDaily = List.generate(7, (i) => DailyForecast(
      date: now.add(Duration(days: i)),
      minTemp: 22.0 + (i % 3),
      maxTemp: 30.0 + (i % 5),
      condition: i % 2 == 0 ? 'Clear' : 'Clouds',
      rainChance: i % 3 == 0 ? 20.0 : 0.0,
    ));
    final mockHourly = List.generate(24, (i) => HourlyForecast(
      time: now.add(Duration(hours: i)),
      temperature: 25.0 + (i % 4),
      condition: 'Clear',
      rainChance: 0.0,
      windSpeed: 5.0 + (i % 3),
      humidity: 40 + (i % 10),
    ));

    return WeatherData(
      temperature: 28.0,
      feelsLike: 30.0,
      condition: 'Clear',
      description: 'Sunny skies',
      humidity: 45,
      windSpeed: 8.0,
      rainChance: 0.0,
      cityName: cityName ?? 'Nashik',
      uvIndex: 6,
      hourlyForecasts: mockHourly,
      dailyForecasts: mockDaily,
      historicalForecasts: _generateMockHistorical(),
      farmingAdvice: 'Weather data is currently offline. Showing estimated local conditions.',
      timestamp: now,
    );
  }

  List<HourlyForecast> _parseHourlyForecasts(List<dynamic> list) {
    return list.take(24).map((item) => HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000),
      temperature: (item['main']['temp'] as num).toDouble(),
      condition: item['weather'][0]['main'] as String,
      rainChance: ((item['pop'] ?? 0) as num).toDouble() * 100,
      windSpeed: (item['wind']['speed'] as num).toDouble(),
      humidity: item['main']['humidity'] as int,
    )).toList();
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
        rainChance: ((items.map((i) => (i['pop'] ?? 0) as num).reduce((a, b) => a + b)) / items.length * 100).toDouble(),
      );
    }).toList();
  }

  List<DailyForecast> _generateMockHistorical() {
    final now = DateTime.now();
    return List.generate(5, (index) => DailyForecast(
      date: now.subtract(Duration(days: index + 1)),
      minTemp: 22.0 + (index % 3),
      maxTemp: 31.0 - (index % 2),
      condition: index % 3 == 0 ? 'Rain' : 'Clear',
      rainChance: index % 3 == 0 ? 80.0 : 0.0,
    ));
  }
}
