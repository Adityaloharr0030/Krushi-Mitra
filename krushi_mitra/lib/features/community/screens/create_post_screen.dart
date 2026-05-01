import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krushi_mitra/core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'package:krushi_mitra/core/providers/auth_provider.dart';
import 'package:krushi_mitra/core/providers/database_provider.dart';
import '../../../data/models/post_model.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCrop = 'Select Crop';
  String _selectedPostType = 'Question';
  bool _isLoading = false;

  final List<String> _crops = ['Select Crop', 'Wheat', 'Rice', 'Sugarcane', 'Cotton', 'Onion', 'Tomato'];
  final List<String> _postTypes = ['Question', 'Success Story', 'Tip', 'Market Info'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and content')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final farmerAsync = ref.read(currentUserProvider);
    final farmer = farmerAsync.value;
    final db = ref.read(databaseServiceProvider);

    final post = Post(
      id: const Uuid().v4(),
      farmerId: farmer?.id ?? 'anonymous',
      farmerName: farmer?.name ?? 'Anonymous Farmer',
      title: _titleController.text,
      content: _contentController.text,
      cropTag: _selectedCrop == 'Select Crop' ? null : _selectedCrop,
      problemTag: _selectedPostType,
      likes: 0,
      commentsCount: 0,
      createdAt: DateTime.now(),
    );

    try {
      await db.createPost(post);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.onSurface),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.celestialGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Post Type',
                          icon: Icons.category_rounded,
                          value: _selectedPostType,
                          items: _postTypes,
                          onChanged: (val) => setState(() => _selectedPostType = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Crop Tag',
                          icon: Icons.grass_rounded,
                          value: _selectedCrop,
                          items: _crops,
                          onChanged: (val) => setState(() => _selectedCrop = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter title...',
                      labelText: 'Title',
                      filled: true,
                      fillColor: AppColors.background.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint),
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts...',
                      labelText: 'Content',
                      filled: true,
                      fillColor: AppColors.background.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint),
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAttachPhoto(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEmerald,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primaryEmerald.withValues(alpha: 0.4),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'PUBLISH POST',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryEmerald, size: 20),
        filled: true,
        fillColor: AppColors.background.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textHint),
      ),
      initialValue: value,
      items: items.map((type) => DropdownMenuItem(value: type, child: Text(type, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAttachPhoto() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryEmerald.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_a_photo_rounded, color: AppColors.primaryEmerald, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attach Photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Show details to other farmers',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
