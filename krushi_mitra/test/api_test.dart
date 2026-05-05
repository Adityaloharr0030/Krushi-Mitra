import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:krushi_mitra/core/services/ai_service.dart';
import 'package:krushi_mitra/core/services/market_service.dart';
import 'package:krushi_mitra/core/services/weather_service.dart';

import 'package:krushi_mitra/data/models/smart_context_model.dart';
import 'package:krushi_mitra/data/models/farmer_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    HttpOverrides.global = null;
  });

  test('Test all APIs', () async {
    await dotenv.load(fileName: ".env");

    AIService().initialize();
    MarketService().initialize();
    WeatherService().initialize();

    final testFarmer = Farmer(
      id: 'test-id',
      name: 'Test Farmer',
      state: 'Maharashtra',
      district: 'Pune',
      cropsGrown: ['Wheat'],
      landSize: 2.0,
      preferredLanguage: 'en',
    );

    final context = FarmerContext(profile: testFarmer);

    print("Testing Market API...");
    final markets = await MarketService().getMarketPrices(state: 'Maharashtra', commodity: 'Wheat');
    print("Market items: \${markets.length}");
    expect(markets, isNotNull);

    print("Testing Weather API...");
    final weather = await WeatherService().getWeatherByLocation(19.0760, 72.8777);
    print("Weather Temp: \${weather.temperature}");
    expect(weather, isNotNull);

    print("Testing Gemini API...");
    try {
      final aiResponse = await AIService().checkSchemeEligibility(
        context,
        {'name': 'PM-KISAN', 'benefit': '6000', 'eligibility': 'Small farmers'},
      );
      print("Gemini Response: \$aiResponse");
      expect(aiResponse, isNotEmpty);
    } catch(e) {
      print("Gemini Failed: \$e");
      fail("Gemini API failed");
    }
  });
}
