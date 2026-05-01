import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:krushi_mitra/core/services/ai_service.dart';
import 'package:krushi_mitra/core/services/market_service.dart';
import 'package:krushi_mitra/core/services/weather_service.dart';

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
        {'name': 'Test', 'state': 'Maharashtra', 'district': 'Pune', 'landAcres': 2, 'cropsGrown': ['Wheat']},
        {'name': 'PM-KISAN', 'benefit': '6000', 'eligibility': 'Small farmers'},
        'English'
      );
      print("Gemini Response: \$aiResponse");
      expect(aiResponse, isNotEmpty);
    } catch(e) {
      print("Gemini Failed: \$e");
      fail("Gemini API failed");
    }
  });
}
