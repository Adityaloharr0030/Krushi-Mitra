import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/market_service.dart';

final mandiProvider = StateNotifierProvider<MandiNotifier, AsyncValue<List<MarketPrice>>>((ref) {
  return MandiNotifier();
});

class MandiNotifier extends StateNotifier<AsyncValue<List<MarketPrice>>> {
  MandiNotifier() : super(const AsyncValue.loading()) {
    fetchPrices();
  }

  Future<void> fetchPrices({String? stateFilter, String? commodityFilter}) async {
    state = const AsyncValue.loading();
    try {
      final prices = await MarketService().getMarketPrices(
        state: stateFilter,
        commodity: commodityFilter,
      );
      state = AsyncValue.data(prices);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<double> getTrend(String commodity) {
    return MarketService().getPriceTrend(commodity);
  }
}
