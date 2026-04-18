import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCrop = 'Select Crop';
  String _selectedPostType = 'Question';

  final List<String> _crops = ['Select Crop', 'Wheat', 'Rice', 'Sugarcane', 'Cotton', 'Onion', 'Tomato'];
  final List<String> _postTypes = ['Question', 'Success Story', 'Tip', 'Market Info'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              // Submit post logic
              Navigator.pop(context);
            },
            child: const Text('POST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Post Type', isDense: true),
                    value: _selectedPostType,
                    items: _postTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (val) => setState(() => _selectedPostType = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Related Crop', isDense: true),
                    value: _selectedCrop,
                    items: _crops.map((crop) => DropdownMenuItem(value: crop, child: Text(crop))).toList(),
                    onChanged: (val) => setState(() => _selectedCrop = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title of your post',
                border: InputBorder.none,
                filled: false,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Describe your question or share your story...',
                border: InputBorder.none,
                filled: false,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_a_photo, size: 32, color: AppColors.primaryGreen),
                    onPressed: () {},
                  ),
                  const Text('Attach Photo', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
