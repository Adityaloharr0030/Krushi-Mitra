import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      uvIndex: 0, // Requires separate UV API call
      hourlyForecasts: hourly,
      dailyForecasts: daily,
      farmingAdvice: _getFarmingAdvice(json['weather'][0]['main']),
    );
  }

  static String _getFarmingAdvice(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
        return 'Avoid spraying pesticides today. Good for germination.';
      case 'clear':
        return 'Good day for pesticide or fertilizer application.';
      case 'clouds':
        return 'Suitable for field work. Monitor for disease pressure.';
      case 'thunderstorm':
        return 'Avoid field operations. Secure equipment and protect crops.';
      case 'snow':
        return 'Protect sensitive crops from frost damage.';
      default:
        return 'Check weather before major field operations.';
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

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.weatherBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  String get _apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  Future<WeatherData> getWeatherByLocation(double lat, double lon) async {
    // If no API key, return mock data
    if (_apiKey.isEmpty || _apiKey == 'your_openweather_api_key_here') {
      return _getMockWeatherData();
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
          'cnt': 40, // 5 days, 8 readings/day
        },
      );

      final hourly = _parseHourlyForecasts(forecastResponse.data['list']);
      final daily = _parseDailyForecasts(forecastResponse.data['list']);

      return WeatherData.fromOpenWeatherJson(
        currentResponse.data,
        hourly,
        daily,
      );
    } catch (e) {
      return _getMockWeatherData();
    }
  }

  Future<WeatherData> getWeatherByCity(String cityName) async {
    if (_apiKey.isEmpty || _apiKey == 'your_openweather_api_key_here') {
      return _getMockWeatherData(cityName: cityName);
    }
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
      return _getMockWeatherData(cityName: cityName);
    }
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

  WeatherData _getMockWeatherData({String? cityName}) {
    return WeatherData(
      temperature: 28.5,
      feelsLike: 31.0,
      condition: 'Clear',
      description: 'sunny skies',
      humidity: 65,
      windSpeed: 12.0,
      rainChance: 10.0,
      cityName: cityName ?? 'Pune, Maharashtra',
      uvIndex: 7,
      farmingAdvice: 'Good day for pesticide application. Apply in evening for best results.',
      hourlyForecasts: List.generate(8, (i) => HourlyForecast(
        time: DateTime.now().add(Duration(hours: i * 3)),
        temperature: 26 + (i % 3).toDouble(),
        condition: i < 4 ? 'Clear' : 'Clouds',
        rainChance: i > 5 ? 30 : 5,
      )),
      dailyForecasts: List.generate(7, (i) => DailyForecast(
        date: DateTime.now().add(Duration(days: i)),
        minTemp: 20 + (i % 3).toDouble(),
        maxTemp: 32 - (i % 2).toDouble(),
        condition: i == 3 ? 'Rain' : 'Clear',
        rainChance: i == 3 ? 80 : 10,
      )),
    );
  }
}
