class ApiConstants {
  ApiConstants._();

  // Anthropic Claude API
  static const String claudeBaseUrl = 'https://api.anthropic.com/v1';
  static const String claudeMessagesEndpoint = '/messages';
  static const String claudeModel = 'claude-opus-4-5';
  static const String claudeApiVersion = '2023-06-01';
  static const int claudeMaxTokens = 1500;
  static const int claudeMaxTokensChat = 800;
  
  // Google Gemini API
  static const String geminiModel = 'gemini-1.5-flash';

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
