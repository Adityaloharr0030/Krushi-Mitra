import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/services/ai_service.dart';

class SoilInputScreen extends StatefulWidget {
  const SoilInputScreen({super.key});

  @override
  State<SoilInputScreen> createState() => _SoilInputScreenState();
}

class _SoilInputScreenState extends State<SoilInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final AIService _aiService = AIService();
  
  String _soilType = 'Black';
  String _nitrogen = 'Medium';
  String _phosphorus = 'Medium';
  String _potassium = 'Medium';
  String _ph = '';
  String _area = '';
  String _crop = '';
  
  bool _isAnalyzing = false;
  SoilRecommendation? _recommendation;

  Future<void> _analyzeSoil() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isAnalyzing = true;
      _recommendation = null;
    });

    try {
      final data = {
        'soilType': _soilType,
        'nitrogen': _nitrogen,
        'phosphorus': _phosphorus,
        'potassium': _potassium,
        'ph': _ph.isEmpty ? 'Unknown' : _ph,
        'areaAcres': _area,
      };

      final result = await _aiService.analyzeSoil(data, _crop, 'en');
      setState(() {
        _recommendation = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: \$e')));
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'AI Soil Advisor'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_recommendation != null) 
              _buildResultCard()
            else ...[
              _buildInputForm(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeSoil,
                icon: _isAnalyzing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.analytics),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Get Recommendation'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter Soil Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _soilType,
                decoration: const InputDecoration(labelText: 'Soil Type'),
                items: ['Black', 'Red', 'Alluvial', 'Sandy', 'Loamy']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _soilType = val!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'pH Level (Optional)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onSaved: (val) => _ph = val ?? '',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Target Crop'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _crop = val!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: const InputDecoration(labelText: 'Field Area (Acres)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _area = val!,
              ),
              const SizedBox(height: 24),

              const Text('Macronutrient Levels', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              _buildNutrientDropdown('Nitrogen (N)', _nitrogen, (val) => setState(() => _nitrogen = val!)),
              const SizedBox(height: 12),
              _buildNutrientDropdown('Phosphorus (P)', _phosphorus, (val) => setState(() => _phosphorus = val!)),
              const SizedBox(height: 12),
              _buildNutrientDropdown('Potassium (K)', _potassium, (val) => setState(() => _potassium = val!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientDropdown(String label, String value, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: ['Low', 'Medium', 'High']
          .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultCard() {
    final rec = _recommendation!;
    return Card(
      color: AppColors.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AI Recommendation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() => _recommendation = null)),
              ],
            ),
            const Divider(),
            _buildResultSection('Assessment', rec.assessment, Icons.analytics),
            _buildResultSection('Fertilizers Needed', rec.fertilizers, Icons.science),
            _buildResultSection('Organic Amendments', rec.organicAmendments, Icons.eco),
            if (rec.limeRecommendation.isNotEmpty && rec.limeRecommendation.toLowerCase() != 'none')
              _buildResultSection('pH Correction', rec.limeRecommendation, Icons.water_drop),
            if (rec.micronutrients.isNotEmpty && rec.micronutrients.toLowerCase() != 'none')
              _buildResultSection('Micronutrients', rec.micronutrients, Icons.grain),
            _buildResultSection('Next Steps', rec.nextSteps, Icons.format_list_numbered),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }
}
