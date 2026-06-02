import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/market_service.dart';
import 'auth_provider.dart';
import '../../data/models/market_price_model.dart';
import '../constants/api_constants.dart';

final marketServiceProvider = Provider((ref) => MarketService());

final mandiFiltersProvider = StateProvider<({String state, String? commodity})>((ref) {
  final profile = ref.watch(currentUserProvider).value;
  
  String defaultCommodity = 'Wheat';
  if (profile != null && profile.cropsGrown.isNotEmpty) {
    for (final crop in profile.cropsGrown) {
      final matched = ApiConstants.supportedCommodities.firstWhere(
        (c) => c.toLowerCase() == crop.trim().toLowerCase(),
        orElse: () => '',
      );
      if (matched.isNotEmpty) {
        defaultCommodity = matched;
        break;
      }
    }
  }
  return (state: profile?.state ?? 'Maharashtra', commodity: defaultCommodity);
});

final useAIProvider = StateProvider<bool>((ref) => false);

final mandiProvider = FutureProvider<List<MarketPrice>>((ref) async {
  final service = ref.watch(marketServiceProvider);
  final filters = ref.watch(mandiFiltersProvider);
  final useAI = ref.watch(useAIProvider);
  
  return await service.getMarketPrices(
    state: filters.state,
    commodity: filters.commodity,
    forceRefresh: true,
    forceAI: useAI,
  );
});
