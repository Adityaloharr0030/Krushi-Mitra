import 'farmer_model.dart';
import '../../core/services/weather_service.dart';
import 'market_price_model.dart';
import 'farm_diary_model.dart';

class FarmerContext {
  final Farmer? profile;
  final WeatherData? weather;
  final List<MarketPrice> marketPrices;
  final List<FarmDiaryEntry> diaryEntries;
  final DateTime lastUpdated;

  FarmerContext({
    this.profile,
    this.weather,
    this.marketPrices = const [],
    this.diaryEntries = const [],
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  String get language => profile?.preferredLanguage ?? 'en';

  Map<String, dynamic> toAIJson() {
    return {
      'farmer': profile?.toJson(),
      'weather': weather?.toJson(),
      'market': marketPrices.take(3).map((e) => e.toJson()).toList(),
      'diary_summary': _getDiarySummary(),
      'timestamp': lastUpdated.toIso8601String(),
    };
  }

  String _getDiarySummary() {
    if (diaryEntries.isEmpty) return "No recent transactions.";
    final income = diaryEntries.where((e) => !e.isExpense).fold(0.0, (sum, e) => sum + e.cost);
    final expense = diaryEntries.where((e) => e.isExpense).fold(0.0, (sum, e) => sum + e.cost);
    return "Total Income: ₹$income, Total Expense: ₹$expense. Recent activity: ${diaryEntries.first.activity}";
  }
}
