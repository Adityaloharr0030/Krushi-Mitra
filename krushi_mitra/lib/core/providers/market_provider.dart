import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/market_service.dart';
import 'auth_provider.dart';
import '../../data/models/market_price_model.dart';

final marketServiceProvider = Provider((ref) => MarketService());

final mandiFiltersProvider = StateProvider<({String state, String? commodity})>((ref) {
  final profile = ref.watch(currentUserProvider).value;
  return (state: profile?.state ?? 'Maharashtra', commodity: null);
});

final mandiProvider = FutureProvider<List<MarketPrice>>((ref) async {
  final service = ref.watch(marketServiceProvider);
  final filters = ref.watch(mandiFiltersProvider);
  
  return await service.getMarketPrices(
    state: filters.state,
    commodity: filters.commodity,
    forceRefresh: true,
  );
});
