import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/services/ai_service.dart';
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
      // In a real app, you would pass the selected language here
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
      appBar: CustomAppBar(
        title: AppStrings.cropDoctorHi,
        actions: [
          if (_selectedImage != null && !_isAnalyzing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selectedImage == null) ...[
                _buildImagePicker(),
              ] else if (_isAnalyzing) ...[
                _buildAnalysisInProgress(),
              ] else if (_errorMessage != null) ...[
                ErrorDisplayWidget(
                  message: _errorMessage!,
                  onRetry: _analyzeImage,
                ),
              ] else if (_diagnosisResult != null) ...[
                _buildResultCard(_diagnosisResult!),
              ] else ...[
                _buildImagePreview(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.energy_savings_leaf,
          size: 80,
          color: AppColors.primaryLight,
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.uploadImageHi,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Take a clear photo of the affected crop area',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _analyzeImage,
          icon: const Icon(Icons.analytics),
          label: const Text(AppStrings.diagnoseHi, style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisInProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            color: Colors.white.withOpacity(0.5),
            colorBlendMode: BlendMode.modulate,
          ),
        ),
        const SizedBox(height: 32),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.analyzingHi,
          style: Theme.of(context).textTheme.headlineSmall,
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
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      result.cropName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Chip(
                      label: Text(
                        isHealthy ? AppStrings.cropHealthy : AppStrings.cropDiseased,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: statusColor,
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (!isHealthy) ...[
                  _buildResultRow('Disease:', result.diseaseName, color: statusColor, isBold: true),
                  const SizedBox(height: 8),
                  _buildResultRow('Severity:', result.severity),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Symptoms', Icons.visibility),
                  Text(result.symptoms),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Causes', Icons.info_outline),
                  Text(result.causes),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Organic Treatment', Icons.eco),
                  Text(result.treatmentOrganic),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Chemical Treatment', Icons.science),
                  Text(result.treatmentChemical),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Prevention', Icons.shield),
                  Text(result.prevention),
                ] else ...[
                  const Text(
                    'Your crop looks healthy based on this image. Keep up the good work! Make sure to continue regular monitoring.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {
            // Navigate to Chatbot with context
          },
          icon: const Icon(Icons.chat),
          label: const Text(AppStrings.askAiMore),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
