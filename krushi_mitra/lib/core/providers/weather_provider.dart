import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';

final weatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherData>>((ref) {
  return WeatherNotifier();
});

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherData>> {
  WeatherNotifier() : super(const AsyncValue.loading()) {
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    state = const AsyncValue.loading();
    try {
      // Get current location
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      
      final data = await WeatherService().getWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      
      state = AsyncValue.data(data);
    } catch (e, stack) {
      // Fallback to mock data if location fails (to keep premium experience smooth)
      final mockData = WeatherService().getWeatherByLocation(18.5204, 73.8567); // Pune coords
      state = AsyncValue.data(await mockData);
    }
  }
}
