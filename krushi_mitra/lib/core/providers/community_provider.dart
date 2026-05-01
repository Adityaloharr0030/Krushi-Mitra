import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../../data/models/post_model.dart';

final postsStreamProvider = StreamProvider<List<Post>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db.getPosts();
});
