import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/ai_service.dart';
import '../models/listing_model.dart';

/// Helper to merge user-created local listings with downloaded/fallback listings
List<MarketplaceListing> _mergeListings(List<MarketplaceListing> primary, List<MarketplaceListing> secondary) {
  final Map<String, MarketplaceListing> map = {};
  for (final l in secondary) {
    map[l.id] = l;
  }
  for (final l in primary) {
    map[l.id] = l;
  }
  final sorted = map.values.toList();
  sorted.sort((a, b) => b.dateListed.compareTo(a.dateListed));
  return sorted;
}

/// SharedPreferences helper functions
Future<List<MarketplaceListing>> getLocalListings() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('local_user_listings');
    if (jsonStr != null) {
      final List list = json.decode(jsonStr);
      return list.map((e) => MarketplaceListing.fromJson(e as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    debugPrint('Error getting local user listings: $e');
  }
  return [];
}

Future<void> saveLocalListings(List<MarketplaceListing> listings) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = listings.map((e) {
      final map = e.toJson();
      map['dateListed'] = e.dateListed.toIso8601String();
      return map;
    }).toList();
    await prefs.setString('local_user_listings', json.encode(jsonList));
  } catch (e) {
    debugPrint('Error saving local user listings: $e');
  }
}

Future<List<MarketplaceListing>> getCachedMarketplace() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cached_firestore_listings');
    if (jsonStr != null) {
      final List list = json.decode(jsonStr);
      return list.map((e) => MarketplaceListing.fromJson(e as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    debugPrint('Error getting cached marketplace listings: $e');
  }
  return [];
}

Future<void> saveCachedMarketplace(List<MarketplaceListing> listings) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = listings.map((e) {
      final map = e.toJson();
      map['dateListed'] = e.dateListed.toIso8601String();
      return map;
    }).toList();
    await prefs.setString('cached_firestore_listings', json.encode(jsonList));
  } catch (e) {
    debugPrint('Error saving cached marketplace listings: $e');
  }
}

/// Static fallback listings for complete offline resilience
List<MarketplaceListing> getStaticFallbackListings() {
  final now = DateTime.now();
  return [
    MarketplaceListing(
      id: 'static_1',
      sellerId: 'static_seller_1',
      farmerName: 'Ramesh Kumar',
      commodity: 'Wheat',
      quantity: 150.0,
      unit: 'Quintal',
      pricePerUnit: 2450.0,
      quality: 'A',
      location: 'Nashik, Maharashtra',
      description: 'Sun-dried Lokwan wheat. Excellent quality, low moisture content, ideal for milling.',
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=500&auto=format&fit=crop',
      phoneNumber: '9876543210',
      dateListed: now.subtract(const Duration(hours: 4)),
      isVerified: true,
      isOrganic: true,
      deliveryAvailable: true,
      isNegotiable: true,
    ),
    MarketplaceListing(
      id: 'static_2',
      sellerId: 'static_seller_2',
      farmerName: 'Sanjay Patil',
      commodity: 'Onion',
      quantity: 80.0,
      unit: 'Quintal',
      pricePerUnit: 1400.0,
      quality: 'A+',
      location: 'Pune, Maharashtra',
      description: 'Freshly harvested Nasik Red onions. Well-graded, medium size, long shelf life.',
      imageUrl: 'https://images.unsplash.com/photo-1508747703725-719ae2c226e1?q=80&w=500&auto=format&fit=crop',
      phoneNumber: '9823456789',
      dateListed: now.subtract(const Duration(hours: 8)),
      isVerified: true,
      isOrganic: false,
      deliveryAvailable: true,
      isNegotiable: true,
    ),
    MarketplaceListing(
      id: 'static_3',
      sellerId: 'static_seller_3',
      farmerName: 'Anil Shinde',
      commodity: 'Tomato',
      quantity: 500.0,
      unit: 'Kg',
      pricePerUnit: 18.0,
      quality: 'B',
      location: 'Satara, Maharashtra',
      description: 'Firm hybrid tomatoes, perfect for transportation. Picked early morning.',
      imageUrl: 'https://images.unsplash.com/photo-1595855759920-86582396756a?q=80&w=500&auto=format&fit=crop',
      phoneNumber: '9854321098',
      dateListed: now.subtract(const Duration(hours: 12)),
      isVerified: false,
      isOrganic: true,
      deliveryAvailable: false,
      isNegotiable: true,
    ),
    MarketplaceListing(
      id: 'static_4',
      sellerId: 'static_seller_4',
      farmerName: 'Baldev Singh',
      commodity: 'Rice',
      quantity: 200.0,
      unit: 'Quintal',
      pricePerUnit: 4200.0,
      quality: 'A+',
      location: 'Kolhapur, Maharashtra',
      description: 'Super fine long grain aromatic Basmati. Cleaned and packed in 50kg bags.',
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=500&auto=format&fit=crop',
      phoneNumber: '9456781230',
      dateListed: now.subtract(const Duration(days: 1)),
      isVerified: true,
      isOrganic: false,
      deliveryAvailable: true,
      isNegotiable: false,
    ),
    MarketplaceListing(
      id: 'static_5',
      sellerId: 'static_seller_5',
      farmerName: 'Vikas More',
      commodity: 'Soybean',
      quantity: 120.0,
      unit: 'Quintal',
      pricePerUnit: 4600.0,
      quality: 'A',
      location: 'Latur, Maharashtra',
      description: 'Yellow soybean with high oil content. Thoroughly cleaned and graded.',
      imageUrl: 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?q=80&w=500&auto=format&fit=crop',
      phoneNumber: '9123456789',
      dateListed: now.subtract(const Duration(days: 2)),
      isVerified: false,
      isOrganic: false,
      deliveryAvailable: true,
      isNegotiable: true,
    ),
  ];
}

/// Stream of all marketplace listings from Firestore with zero-latency caching & AI fallback
final marketplaceStreamProvider = StreamProvider<List<MarketplaceListing>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final controller = StreamController<List<MarketplaceListing>>();

  // Load initial local + cached data immediately for zero-perceived-latency
  Future<void> loadInitialData() async {
    final local = await getLocalListings();
    final cached = await getCachedMarketplace();
    if (controller.isClosed) return;
    
    if (cached.isEmpty && local.isEmpty) {
      controller.add(getStaticFallbackListings());
    } else {
      controller.add(_mergeListings(local, cached));
    }
  }

  loadInitialData();

  final subscription = db.getMarketListings().listen(
    (jsonList) async {
      final List<MarketplaceListing> validListings = [];
      for (final json in jsonList) {
        try {
          validListings.add(MarketplaceListing.fromJson(json));
        } catch (e) {
          debugPrint('Error parsing marketplace listing: $e');
        }
      }
      
      // Save downloaded listings as cached listings
      await saveCachedMarketplace(validListings);
      
      final local = await getLocalListings();
      final merged = _mergeListings(local, validListings);
      
      if (!controller.isClosed) {
        controller.add(merged);
      }
    },
    onError: (err) async {
      debugPrint('Firestore Marketplace Stream Error: $err. Initiating AI/Offline recovery.');
      final local = await getLocalListings();
      final cached = await getCachedMarketplace();
      
      // If offline or permission-denied, try to fetch simulated/live listings from Gemini AI
      List<MarketplaceListing> aiList = [];
      try {
        final rawAi = await AIService().getAIMarketplaceListings();
        aiList = rawAi.map((json) => MarketplaceListing.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Gemini AI Marketplace generator failed: $e');
      }
      
      final fallbackPool = aiList.isNotEmpty ? aiList : getStaticFallbackListings();
      final merged = _mergeListings(local, [...cached, ...fallbackPool]);
      
      if (!controller.isClosed) {
        controller.add(merged);
      }
    }
  );

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
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
    // 1. Save locally
    try {
      final local = await getLocalListings();
      final updated = List<MarketplaceListing>.from(local);
      final idx = updated.indexWhere((l) => l.id == listing.id);
      if (idx != -1) {
        updated[idx] = listing;
      } else {
        updated.insert(0, listing);
      }
      await saveLocalListings(updated);
    } catch (e) {
      debugPrint('Error saving local listing action: $e');
    }

    // 2. Upload to Firestore (ignore errors to keep local work functional)
    try {
      await _ref.read(databaseServiceProvider).addMarketListing(listing.toJson());
    } catch (e) {
      debugPrint('Firestore upload ignored error: $e');
    }
  }

  Future<void> deleteListing(String listingId) async {
    // 1. Delete locally
    try {
      final local = await getLocalListings();
      final updated = local.where((l) => l.id != listingId).toList();
      await saveLocalListings(updated);
      
      // Also delete from cached firestore listings if it exists there
      final cached = await getCachedMarketplace();
      final updatedCached = cached.where((l) => l.id != listingId).toList();
      await saveCachedMarketplace(updatedCached);
    } catch (e) {
      debugPrint('Error deleting local listing action: $e');
    }

    // 2. Delete from Firestore
    try {
      await _ref.read(databaseServiceProvider).deleteMarketListing(listingId);
    } catch (e) {
      debugPrint('Firestore delete ignored error: $e');
    }
  }

  Future<void> markSold(String listingId) async {
    // 1. Mark sold locally
    try {
      final local = await getLocalListings();
      final updated = local.map((l) {
        if (l.id == listingId) {
          return MarketplaceListing(
            id: l.id,
            sellerId: l.sellerId,
            farmerName: l.farmerName,
            commodity: l.commodity,
            quantity: l.quantity,
            unit: l.unit,
            pricePerUnit: l.pricePerUnit,
            quality: l.quality,
            location: l.location,
            description: l.description,
            imageUrl: l.imageUrl,
            phoneNumber: l.phoneNumber,
            dateListed: l.dateListed,
            isVerified: l.isVerified,
            isSold: true,
            isOrganic: l.isOrganic,
            deliveryAvailable: l.deliveryAvailable,
            minimumOrder: l.minimumOrder,
            isNegotiable: l.isNegotiable,
          );
        }
        return l;
      }).toList();
      await saveLocalListings(updated);

      final cached = await getCachedMarketplace();
      final updatedCached = cached.map((l) {
        if (l.id == listingId) {
          return MarketplaceListing(
            id: l.id,
            sellerId: l.sellerId,
            farmerName: l.farmerName,
            commodity: l.commodity,
            quantity: l.quantity,
            unit: l.unit,
            pricePerUnit: l.pricePerUnit,
            quality: l.quality,
            location: l.location,
            description: l.description,
            imageUrl: l.imageUrl,
            phoneNumber: l.phoneNumber,
            dateListed: l.dateListed,
            isVerified: l.isVerified,
            isSold: true,
            isOrganic: l.isOrganic,
            deliveryAvailable: l.deliveryAvailable,
            minimumOrder: l.minimumOrder,
            isNegotiable: l.isNegotiable,
          );
        }
        return l;
      }).toList();
      await saveCachedMarketplace(updatedCached);
    } catch (e) {
      debugPrint('Error marking local listing sold action: $e');
    }

    // 2. Mark sold in Firestore
    try {
      await _ref.read(databaseServiceProvider).markListingSold(listingId);
    } catch (e) {
      debugPrint('Firestore mark sold ignored error: $e');
    }
  }
}
