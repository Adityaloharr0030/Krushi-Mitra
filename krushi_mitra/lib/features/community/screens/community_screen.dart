import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krushi_mitra/core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'package:krushi_mitra/core/providers/community_provider.dart';
import 'package:krushi_mitra/shared/widgets/loading_widget.dart';
import 'package:krushi_mitra/shared/widgets/error_widget.dart' as custom;
import '../../../data/models/post_model.dart';
import 'create_post_screen.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Farmer Community',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.celestialGradient,
          ),
        ),
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet. Be the first to ask!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(posts[index]);
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (err, stack) => custom.ErrorDisplayWidget(message: 'Failed to load posts: $err'),
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          gradient: AppTheme.celestialGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryEmerald.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(post.farmerName[0], style: GoogleFonts.outfit(color: AppColors.primaryEmerald, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.farmerName, 
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)
                      ),
                      Text(
                        DateFormat('MMM d, h:mm a').format(post.createdAt), 
                        style: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w600)
                      ),
                    ],
                  ),
                ),
                if (post.farmerName == 'Suresh Kumar') 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, size: 14, color: AppColors.primaryEmerald),
                        const SizedBox(width: 4),
                        Text(
                          'Expert', 
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.primaryEmerald, fontWeight: FontWeight.w800)
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.title, 
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, 
                color: AppColors.textSecondary,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (post.cropTag != null)
                  _buildTag(post.cropTag!, AppColors.primaryEmerald.withValues(alpha: 0.1), AppColors.primaryEmerald),
                if (post.problemTag != null)
                  _buildTag(post.problemTag!, AppColors.error.withValues(alpha: 0.1), AppColors.error),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildInteractionButton(Icons.thumb_up_rounded, '${post.likes}'),
                    const SizedBox(width: 20),
                    _buildInteractionButton(Icons.mode_comment_rounded, '${post.commentsCount}'),
                  ],
                ),
                _buildInteractionButton(Icons.share_rounded, ''),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: textColor),
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textHint),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            count, 
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)
          ),
        ],
      ],
    );
  }
}
