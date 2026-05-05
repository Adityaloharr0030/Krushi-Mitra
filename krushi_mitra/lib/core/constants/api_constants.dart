class ApiConstants {
  ApiConstants._();

  // Google Gemini AI (FREE Tier)
  static const String geminiModel = 'gemini-2.0-flash-lite';
  static const String geminiVisionModel = 'gemini-2.0-flash-lite';
  static const int geminiMaxTokens = 2048;

  // OpenWeatherMap API
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String weatherCurrentEndpoint = '/weather';
  static const String weatherForecastEndpoint = '/forecast';
  static const String weatherUnits = 'metric';
  static const String weatherLang = 'en';

  // Agmarknet (India Mandi Prices)
  static const String agmarknetBaseUrl = 'https://api.data.gov.in/resource';
  static const String agmarknetResource = '9ef84268-d588-465a-a308-a864a43d0070';

  // Cache TTL (in minutes)
  static const int weatherCacheTtl = 30;
  static const int marketCacheTtl = 60;
  static const int schemesCacheTtl = 1440; // 24 hours

  // Timeouts (in seconds)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 60;

  // Image compression
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;
}
