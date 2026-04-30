import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/market_service.dart';

final marketServiceProvider = Provider((ref) => MarketService());

final mandiProvider = FutureProvider<List<MarketPrice>>((ref) async {
  final service = ref.watch(marketServiceProvider);
  return await service.getMarketPrices();
});
