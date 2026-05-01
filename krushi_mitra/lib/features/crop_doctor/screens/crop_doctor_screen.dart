import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../core/services/ai_service.dart';

class CropDoctorScreen extends StatefulWidget {
  const CropDoctorScreen({super.key});

  @override
  State<CropDoctorScreen> createState() => _CropDoctorScreenState();
}

class _CropDoctorScreenState extends State<CropDoctorScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  CropDiagnosis? _diagnosis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Crop Doctor'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            if (_diagnosis != null) _buildDiagnosisResults(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildActionPanel(),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundMidnight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_search_rounded, size: 64, color: AppColors.primaryEmerald.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('Upload crop photo for diagnosis', style: TextStyle(color: AppColors.textMediumEmphasis)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : () {}, // Camera placeholder
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('CAMERA'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondarySlate),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : () {}, // Gallery placeholder
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('GALLERY'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisResults() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
           // Simplified results for brevity
        ],
      ),
    );
  }
}

class _DiagnosisStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _DiagnosisStep({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryEmerald, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(content, style: TextStyle(color: AppColors.textMediumEmphasis)),
            ],
          ),
        ),
      ],
    );
  }
}
