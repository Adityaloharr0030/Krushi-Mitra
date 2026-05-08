import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../models/listing_model.dart';

/// Stream of all marketplace listings from Firestore
final marketplaceStreamProvider = StreamProvider<List<MarketplaceListing>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db.getMarketListings().map((jsonList) {
    final List<MarketplaceListing> validListings = [];
    for (final json in jsonList) {
      try {
        validListings.add(MarketplaceListing.fromJson(json));
      } catch (e, st) {
        debugPrint('Error parsing marketplace listing: $e');
        debugPrint('Stacktrace: $st');
        // We skip invalid listings instead of breaking the whole stream
      }
    }
    return validListings;
  });
});

/// Provider to get the current user's ID for ownership checks
final currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.currentUser?.uid;
});

/// Actions provider for adding/deleting listings
final marketplaceActionsProvider = Provider<MarketplaceActions>((ref) {
  return MarketplaceActions(ref);
});

class MarketplaceActions {
  final Ref _ref;
  MarketplaceActions(this._ref);

  Future<void> addListing(MarketplaceListing listing) async {
    await _ref.read(databaseServiceProvider).addMarketListing(listing.toJson());
  }

  Future<void> deleteListing(String listingId) async {
    await _ref.read(databaseServiceProvider).deleteMarketListing(listingId);
  }

  Future<void> markSold(String listingId) async {
    await _ref.read(databaseServiceProvider).markListingSold(listingId);
  }
}
