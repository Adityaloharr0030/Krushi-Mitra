import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/services/ai_service.dart';

class AIDoctorScreen extends StatefulWidget {
  const AIDoctorScreen({super.key});

  @override
  State<AIDoctorScreen> createState() => _AIDoctorScreenState();
}

class _AIDoctorScreenState extends State<AIDoctorScreen> {
  final TextEditingController _queryController = TextEditingController();
  final VoiceService _voiceService = VoiceService();
  final AIService _aiService = AIService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isProcessing = false;
  bool _isListening = false;
  File? _selectedImage;
  CropDiagnosis? _diagnosis;
  
  final List<Map<String, dynamic>> _chatHistory = [];

  final List<String> _suggestedQuestions = [
    "ये क्या बीमारी है?",
    "कब पानी देना चाहिए?",
    "पीले पत्ते क्यों हो रहे हैं?",
    "कौन सा खाद डालें?"
  ];

  @override
  void initState() {
    super.initState();
    _aiService.initialize();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _diagnosis = null; // Reset previous diagnosis
      });
      _analyzeCrop();
    }
  }

  Future<void> _analyzeCrop() async {
    if (_selectedImage == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final diagnosis = await _aiService.analyzeCropImage(_selectedImage!, 'hi');
      setState(() {
        _diagnosis = diagnosis;
        _isProcessing = false;
      });
      _voiceService.speak("Diagnosis complete. Crop issue appears to be ${diagnosis.diseaseName}.", languageCode: 'en-US');
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error analyzing crop: $e')));
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _queryController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'content': text});
      _queryController.clear();
      _isProcessing = true;
    });

    try {
      final response = await _aiService.chat(_chatHistory, text, 'hi');
      setState(() {
         _chatHistory.add({'role': 'assistant', 'content': response});
         _isProcessing = false;
      });
      _voiceService.speak(response, languageCode: 'hi-IN');
    } catch (e) {
       setState(() => _isProcessing = false);
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to chat: $e')));
       }
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _voiceService.startListening((text) {
        setState(() {
          _queryController.text = text;
        });
      }, localeId: 'hi_IN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUploadSection(),
          const SizedBox(height: 24),
          _buildChatSection(),
          const SizedBox(height: 24),
          if (_isProcessing)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: AppColors.primaryGreen))),
          if (_diagnosis != null)
            _buildResultCard(),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      height: _selectedImage == null ? 180 : 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceGreenLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen, width: 2, style: BorderStyle.solid),
      ),
      child: _selectedImage != null 
        ? Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(_selectedImage!, fit: BoxFit.cover)),
              Positioned(
                top: 8, right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() { _selectedImage = null; _diagnosis = null; })),
                )
              )
            ],
          )
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, size: 48, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
              child: const Text('Take Photo of Crop'),
            ),
            TextButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text('Or upload from gallery'),
            ),
          ],
        ),
    );
  }

  Widget _buildChatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_chatHistory.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final chat = _chatHistory[index];
                final isUser = chat['role'] == 'user';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(isUser ? 'You' : 'Krushi Mitra', style: TextStyle(fontWeight: FontWeight.bold, color: isUser ? AppColors.primaryGreen : AppColors.secondaryAmber)),
                      Text(chat['content']),
                    ]
                  )
                );
              }
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  hintText: 'Ask Krushi Mitra...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primaryGreen),
                    onPressed: _sendMessage,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _isListening ? AppColors.error : AppColors.secondaryAmber,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.white),
                onPressed: _toggleListening,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestedQuestions.map((q) => ActionChip(
            label: Text(q),
            backgroundColor: AppColors.surfaceWhite,
            side: BorderSide(color: Colors.grey.shade300),
            onPressed: () {
              _queryController.text = q;
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    if (_diagnosis == null) return const SizedBox.shrink();
    
    final diag = _diagnosis!;
    final isHealthy = diag.isHealthy;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isHealthy ? Icons.check_circle : Icons.warning_amber_rounded, color: isHealthy ? AppColors.primaryGreen : AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHealthy ? 'Crop Looks Healthy!' : 'Issue Detected: ${diag.diseaseName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isHealthy ? AppColors.primaryGreen : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildResultSection('Crop Identified', diag.cropName),
            _buildResultSection('Severity', diag.severity.toUpperCase()),
            _buildResultSection('Symptoms', diag.symptoms),
            _buildResultSection('Cause', diag.causes),
            if (!isHealthy) ...[
              _buildResultSection('Organic Remedy', diag.treatmentOrganic),
              _buildResultSection('Chemical Remedy', diag.treatmentChemical),
              _buildResultSection('Prevention', diag.prevention),
            ],
            const SizedBox(height: 8),
            Text('Confidence: ${diag.confidencePercent}%', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }
}
