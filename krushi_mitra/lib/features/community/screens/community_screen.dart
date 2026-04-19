import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
      backgroundColor: AppColors.backgroundStone,
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostEditorial(_posts[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPostEditorial(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                child: Text(post.farmerName[0], style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.farmerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(DateFormat('MMM d').format(post.createdAt), style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                  ],
                ),
              ),
              if (post.farmerName == 'Suresh Kumar')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Text('EXPERT', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(post.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 12),
          Text(post.content, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              if (post.cropTag != null)
                _buildTag(post.cropTag!, AppColors.primaryGreen),
              if (post.problemTag != null)
                _buildTag(post.problemTag!, AppColors.error),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildStat(Icons.thumb_up_outlined, post.likes.toString()),
                  const SizedBox(width: 20),
                  _buildStat(Icons.mode_comment_outlined, post.commentsCount.toString()),
                ],
              ),
              const Icon(Icons.share_outlined, size: 20, color: AppColors.textHint),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStat(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textHint),
        const SizedBox(width: 6),
        Text(count, style: const TextStyle(color: AppColors.textHint, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
