import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/market_service.dart';
import 'auth_provider.dart';
import '../../data/models/market_price_model.dart';

final marketServiceProvider = Provider((ref) => MarketService());

final mandiProvider = FutureProvider<List<MarketPrice>>((ref) async {
  ref.keepAlive(); // Keeps data cached at the Riverpod level for better performance
  final service = ref.watch(marketServiceProvider);
  final profileAsync = ref.watch(currentUserProvider);

  return profileAsync.maybeWhen(
    data: (profile) async {
      if (profile != null) {
        // Fetch all commodities for the state (no commodity filter)
        return await service.getMarketPrices(
          state: profile.state,
          forceRefresh: true, // Bypass SharedPreferences cache
        );
      }
      return await service.getMarketPrices(state: 'Maharashtra', forceRefresh: true);
    },
    orElse: () => service.getMarketPrices(state: 'Maharashtra', forceRefresh: true),
  );
});
