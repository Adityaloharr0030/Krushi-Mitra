import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/voice_service.dart';

class AIDoctorScreen extends StatefulWidget {
  const AIDoctorScreen({super.key});

  @override
  State<AIDoctorScreen> createState() => _AIDoctorScreenState();
}

class _AIDoctorScreenState extends State<AIDoctorScreen> {
  final TextEditingController _queryController = TextEditingController();
  final VoiceService _voiceService = VoiceService();
  bool _isProcessing = false;
  bool _showResult = false; // Mock state
  bool _isListening = false;

  final List<String> _suggestedQuestions = [
    "ये क्या बीमारी है?",
    "कब पानी देना चाहिए?",
    "पीले पत्ते क्यों हो रहे हैं?",
    "कौन सा खाद डालें?"
  ];

  void _analyzeCrop() {
    setState(() {
      _isProcessing = true;
      _showResult = false;
    });
    
    // Simulate API delay
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isProcessing = false;
        _showResult = true;
      });
      // Speak the diagnosis
      _voiceService.speak("Diagnosis Complete. The problem is Leaf Rust. Please spray Neem oil.", languageCode: 'hi-IN');
    });
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
            const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          if (_showResult)
            _buildResultCard(),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surfaceGreenLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen, width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_a_photo, size: 48, color: AppColors.primaryGreen),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _analyzeCrop, // In reality, opens camera/gallery before analyzing
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
            child: const Text('Take Photo of Crop'),
          ),
          TextButton(
            onPressed: () {},
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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  hintText: 'Ask Krushi Mitra...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primaryGreen),
                    onPressed: _analyzeCrop,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Diagnosis Complete',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildResultSection('Problem (बीमारी)', 'Leaf Rust (पत्ती रोली)'),
            _buildResultSection('Cause (कारण)', 'Fungal infection exacerbated by high humidity.'),
            _buildResultSection('Organic Remedy (जैविक उपाय)', 'Spray Neem oil mixed with water. (नीम का तेल छिड़कें)'),
            _buildResultSection('Chemical Remedy (रासायनिक)', 'Apply Propiconazole 25% EC at 1ml per liter water.'),
            _buildResultSection('Prevention (रोकथाम)', 'Ensure proper plant spacing for air circulation.'),
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
