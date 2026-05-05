import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/smart_context_model.dart';
import '../../data/models/market_price_model.dart';
import 'auth_provider.dart';
import 'weather_provider.dart';
import 'market_provider.dart';
import 'database_provider.dart';
import '../../data/models/farm_diary_model.dart';

final smartContextProvider = Provider<FarmerContext>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final weatherAsync = ref.watch(weatherProvider);
  final mandiAsync = ref.watch(mandiProvider);
  
  final profile = userAsync.asData?.value;
  final weather = weatherAsync.asData?.value;
  final List<MarketPrice> marketPrices = mandiAsync.asData?.value ?? [];

  // We can't easily watch a stream here without converting to AsyncValue
  // For now, we use the profile as the trigger.
  // In a more complex app, we might have a dedicated diaryProvider.
  
  return FarmerContext(
    profile: profile,
    weather: weather,
    marketPrices: marketPrices,
    diaryEntries: [], // Will be populated by specific features if needed, or we can add a listener
  );
});

// A stream provider for diary entries that stays synced
final farmerDiaryProvider = StreamProvider<List<FarmDiaryEntry>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final profile = userAsync.asData?.value;
  
  if (profile == null) return Stream.value([]);
  
  return ref.watch(databaseServiceProvider).getDiaryEntries(profile.id);
});

// The ultimate context that includes diary
final ubiquitousContextProvider = Provider<FarmerContext>((ref) {
  final baseContext = ref.watch(smartContextProvider);
  final diaryAsync = ref.watch(farmerDiaryProvider);
  
  return FarmerContext(
    profile: baseContext.profile,
    weather: baseContext.weather,
    marketPrices: baseContext.marketPrices,
    diaryEntries: diaryAsync.asData?.value ?? [],
  );
});
