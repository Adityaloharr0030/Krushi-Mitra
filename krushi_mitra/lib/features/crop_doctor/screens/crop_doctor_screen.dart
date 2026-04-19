import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/ai_service.dart';
import 'package:image_picker/image_picker.dart';

class CropDoctorScreen extends StatefulWidget {
  const CropDoctorScreen({super.key});

  @override
  State<CropDoctorScreen> createState() => _CropDoctorScreenState();
}

class _CropDoctorScreenState extends State<CropDoctorScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  CropDiagnosis? _diagnosisResult;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();
  final AIService _aiService = AIService();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _diagnosisResult = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await _aiService.analyzeCropImage(_selectedImage!, 'hi');
      setState(() {
        _diagnosisResult = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _diagnosisResult = null;
      _errorMessage = null;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStone,
      appBar: AppBar(
        title: const Text('Crop Doctor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_selectedImage != null && !_isAnalyzing)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              onPressed: _reset,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage == null) ...[
              _buildImagePicker(),
            ] else if (_isAnalyzing) ...[
              _buildAnalysisInProgress(),
            ] else if (_errorMessage != null) ...[
              _buildErrorDisplay(),
            ] else if (_diagnosisResult != null) ...[
              _buildResultCard(_diagnosisResult!),
            ] else ...[
              _buildImagePreview(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.primaryContainer.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: 64,
                color: AppColors.primaryGreen.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload Crop Photo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Our AI will analyze symptoms and suggest treatments within seconds.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.3)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.file(
            _selectedImage!,
            height: 350,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _analyzeImage,
          icon: const Icon(Icons.psychology_outlined),
          label: const Text('Analyze Findings'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 64),
            backgroundColor: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisInProgress() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.file(
                _selectedImage!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Scanning issues...',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 12),
        const Text(
          'Our AI is identifying the crop and potential diseases.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultCard(CropDiagnosis result) {
    final bool isHealthy = result.isHealthy;
    final Color statusColor = isHealthy ? AppColors.success : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              result.cropName,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                isHealthy ? 'Healthy' : 'Diseased',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.file(
            _selectedImage!,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        if (!isHealthy) ...[
          _buildInfoSection('Diagnosis', result.diseaseName, Icons.bug_report_outlined, statusColor),
          _buildInfoSection('Severity', result.severity, Icons.analytics_outlined, AppColors.tertiarySaffron),
          const SizedBox(height: 16),
          _buildDetailCard('Symptoms', result.symptoms, Icons.visibility_outlined),
          _buildDetailCard('Causes', result.causes, Icons.info_outline),
          _buildDetailCard('Solution (Organic)', result.treatmentOrganic, Icons.eco_outlined, isSpecial: true),
          _buildDetailCard('Solution (Chemical)', result.treatmentChemical, Icons.science_outlined),
          _buildDetailCard('Prevention', result.prevention, Icons.shield_outlined),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Your crop appears to be in excellent condition. Maintain regular hydration and monitoring.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Discuss with AI Assistant'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String content, IconData icon, {bool isSpecial = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSpecial ? AppColors.surfaceContainerLow : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textHint.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
        const SizedBox(height: 24),
        Text(
          'Analysis Failed',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(_errorMessage!, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _analyzeImage,
          child: const Text('Retry Analysis'),
        ),
      ],
    );
  }
}
