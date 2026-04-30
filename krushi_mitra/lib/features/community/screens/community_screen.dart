import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../data/models/post_model.dart';
import 'create_post_screen.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Mock Data
  final List<Post> _posts = [
    Post(
      id: '1',
      farmerId: 'f1',
      farmerName: 'Ramesh Patil',
      title: 'White flies on Tomato Crop',
      content: 'I noticed white flies on my tomato leaves this morning. Does anyone have a good organic remedy? Neem oil didn\'t seem to work.',
      cropTag: 'Tomato',
      problemTag: 'Pest',
      likes: 12,
      commentsCount: 4,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Post(
      id: '2',
      farmerId: 'f2',
      farmerName: 'Suresh Kumar',
      title: 'Successful Onion Harvest!',
      content: 'Using the drip irrigation tips from this forum helped me increase my yield by 20% this season. Thank you Krushi Mitra community!',
      cropTag: 'Onion',
      likes: 45,
      commentsCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(_posts[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
        },
        backgroundColor: AppColors.secondaryAmber,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                  child: Text(post.farmerName[0], style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.farmerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(DateFormat('MMM d, h:mm a').format(post.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                if (post.farmerName == 'Suresh Kumar') // Mock expert verification
                   const Chip(
                    label: Text('Expert', style: TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 12),
            Row(
              children: [
                if (post.cropTag != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(label: Text(post.cropTag!), backgroundColor: AppColors.surfaceGreenLight),
                  ),
                if (post.problemTag != null)
                  Chip(label: Text(post.problemTag!), backgroundColor: Colors.red.shade50),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.thumb_up_alt_outlined, size: 20), onPressed: () {}),
                    Text('${post.likes}'),
                    const SizedBox(width: 16),
                    IconButton(icon: const Icon(Icons.comment_outlined, size: 20), onPressed: () {}),
                    Text('${post.commentsCount}'),
                  ],
                ),
                IconButton(icon: const Icon(Icons.share, size: 20), onPressed: () {}),
              ],
            )
          ],
        ),
      ),
    );
  }
}
