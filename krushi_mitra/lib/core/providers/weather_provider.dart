import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/weather_service.dart';
import 'auth_provider.dart';
import 'package:geolocator/geolocator.dart';

final weatherServiceProvider = Provider((ref) => WeatherService());

final weatherProvider = FutureProvider<WeatherData>((ref) async {
  ref.keepAlive(); // Keeps the data cached to prevent slow re-fetches
  final service = ref.watch(weatherServiceProvider);
  
  // Try to get real location first
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        return await service.getWeatherByLocation(position.latitude, position.longitude, forceRefresh: true);
      }
    }
  } catch (e) {
    // Fallback if location fails
  }

  // Fallback to farmer's district or Mumbai
  final profileAsync = ref.watch(currentUserProvider);
  return profileAsync.maybeWhen(
    data: (profile) async {
      if (profile != null && profile.district.isNotEmpty) {
        return await service.getWeatherByCity('${profile.district}, ${profile.state}', forceRefresh: true);
      }
      return await service.getWeatherByLocation(18.5204, 73.8567, forceRefresh: true); // Pune
    },
    orElse: () => service.getWeatherByLocation(18.5204, 73.8567, forceRefresh: true),
  );
});
