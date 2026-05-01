import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/market_service.dart';
import 'auth_provider.dart';

final marketServiceProvider = Provider((ref) => MarketService());

final mandiProvider = FutureProvider<List<MarketPrice>>((ref) async {
  ref.keepAlive(); // Keeps data cached for better performance
  final service = ref.watch(marketServiceProvider);
  final profileAsync = ref.watch(currentUserProvider);

  return profileAsync.maybeWhen(
    data: (profile) async {
      if (profile != null) {
        return await service.getMarketPrices(
          state: profile.state,
          commodity: profile.cropsGrown.isNotEmpty ? profile.cropsGrown.first : null,
        );
      }
      return await service.getMarketPrices(state: 'Maharashtra');
    },
    orElse: () => service.getMarketPrices(state: 'Maharashtra'),
  );
});
