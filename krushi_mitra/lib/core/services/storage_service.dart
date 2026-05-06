import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  // Using the explicit bucket from google-services.json
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'krushi-mitra-dd431.firebasestorage.app');

  Future<String?> uploadProfilePic(String userId, File file) async {
    try {
      final ref = _storage.ref().child('profile_pics').child('$userId.jpg');
      final bytes = await file.readAsBytes();
      final uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Storage Upload Error: $e");
      // Fallback to legacy domain
      try {
        final legacyStorage = FirebaseStorage.instanceFor(bucket: 'krushi-mitra-dd431.appspot.com');
        final ref = legacyStorage.ref().child('profile_pics').child('$userId.jpg');
        final bytes = await file.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        return await ref.getDownloadURL();
      } catch (_) {
        return null;
      }
    }
  }
}
