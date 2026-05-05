import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/farmer_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/farm_diary_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Farmer Profile ---
  
  Future<void> saveFarmerProfile(Farmer farmer) async {
    try {
      await _db.collection('farmers').doc(farmer.id).set(farmer.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint("Firestore Save Error: $e");
      rethrow;
    }
  }

  Future<Farmer?> getFarmerProfile(String uid) async {
    try {
      final doc = await _db.collection('farmers').doc(uid).get(
        const GetOptions(source: Source.serverAndCache)
      ).timeout(const Duration(seconds: 10));
      
      if (doc.exists && doc.data() != null) {
        return Farmer.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Firestore Get Profile Error: $e");
      try {
        final cachedDoc = await _db.collection('farmers').doc(uid).get(const GetOptions(source: Source.cache));
        if (cachedDoc.exists && cachedDoc.data() != null) {
          return Farmer.fromJson(cachedDoc.data()!);
        }
      } catch (_) {}
      return null;
    }
  }

  // --- Community Posts ---

  Future<void> createPost(Post post) async {
    try {
      await _db.collection('posts').doc(post.id).set(post.toJson());
    } catch (e) {
      debugPrint("Firestore Post Error: $e");
      rethrow;
    }
  }

  Stream<List<Post>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList());
  }

  Future<void> likePost(String postId) async {
    try {
      await _db.collection('posts').doc(postId).update({
        'likes': FieldValue.increment(1),
      });
    } catch (e) {
       debugPrint("Firestore Like Error: $e");
    }
  }

  // --- Farm Diary ---

  Future<void> addDiaryEntry(FarmDiaryEntry entry) async {
    try {
      await _db
          .collection('farmers')
          .doc(entry.farmerId)
          .collection('diary')
          .doc(entry.id)
          .set(entry.toJson());
    } catch (e) {
      debugPrint("Firestore Diary Save Error: $e");
      rethrow;
    }
  }

  Stream<List<FarmDiaryEntry>> getDiaryEntries(String farmerId) {
    return _db
        .collection('farmers')
        .doc(farmerId)
        .collection('diary')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FarmDiaryEntry.fromJson(doc.data())).toList());
  }

  Future<void> deleteDiaryEntry(String farmerId, String entryId) async {
    try {
      await _db.collection('farmers').doc(farmerId).collection('diary').doc(entryId).delete();
    } catch (e) {
      debugPrint("Firestore Diary Delete Error: $e");
    }
  }

  // --- Marketplace Listings ---

  Future<void> addMarketListing(Map<String, dynamic> listing) async {
    try {
      await _db.collection('marketplace').doc(listing['id']).set(listing);
    } catch (e) {
      debugPrint("Firestore Marketplace Add Error: $e");
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getMarketListings() {
    return _db
        .collection('marketplace')
        .orderBy('dateListed', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteMarketListing(String listingId) async {
    try {
      await _db.collection('marketplace').doc(listingId).delete();
    } catch (e) {
      debugPrint("Firestore Marketplace Delete Error: $e");
      rethrow;
    }
  }

  Future<void> markListingSold(String listingId) async {
    try {
      await _db.collection('marketplace').doc(listingId).update({'isSold': true});
    } catch (e) {
      debugPrint("Firestore Mark Sold Error: $e");
    }
  }
}
