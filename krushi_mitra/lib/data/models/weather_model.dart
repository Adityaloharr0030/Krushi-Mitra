class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double rainfall;
  final String condition; // e.g. "Sunny", "Rainy"
  final DateTime date;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainfall,
    required this.condition,
    required this.date,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      rainfall: (json['rainfall'] as num).toDouble(),
      condition: json['condition'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'rainfall': rainfall,
      'condition': condition,
      'date': date.toIso8601String(),
    };
  }
}
