import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
      backgroundColor: AppColors.backgroundStone,
      appBar: AppBar(
        title: const Text('Soil Advisor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_recommendation != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              onPressed: () => setState(() => _recommendation = null),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_recommendation != null) 
              _buildResultCard()
            else ...[
              _buildHeader(),
              const SizedBox(height: 32),
              _buildInputForm(),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeSoil,
                icon: _isAnalyzing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Icon(Icons.auto_awesome_outlined),
                label: Text(_isAnalyzing ? 'Analyzing Soil...' : 'Generate AI Advice'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  backgroundColor: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soil Analysis',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in your soil details to get customized fertilizer and care recommendations.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('General Info'),
          const SizedBox(height: 12),
          _buildDropdownContainer(
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _soilType,
                items: ['Black', 'Red', 'Alluvial', 'Sandy', 'Loamy']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _soilType = val!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField('pH Level', (val) => _ph = val ?? '', keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Target Crop', (val) => _crop = val!, validator: (val) => val?.isEmpty ?? true ? 'Required' : null),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Field Area (Acres)', (val) => _area = val!, validator: (val) => val?.isEmpty ?? true ? 'Required' : null, keyboardType: TextInputType.number),
          
          const SizedBox(height: 32),
          _buildFieldLabel('Macronutrient Levels (N-P-K)'),
          const SizedBox(height: 12),
          _buildNutrientRow('Nitrogen', _nitrogen, (val) => setState(() => _nitrogen = val!)),
          const SizedBox(height: 12),
          _buildNutrientRow('Phosphorus', _phosphorus, (val) => setState(() => _phosphorus = val!)),
          const SizedBox(height: 12),
          _buildNutrientRow('Potassium', _potassium, (val) => setState(() => _potassium = val!)),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildDropdownContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildTextField(String label, void Function(String?) onSaved, {String? Function(String?)? validator, TextInputType? keyboardType}) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: label,
        fillColor: AppColors.surfaceWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildNutrientRow(String label, String value, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: ['Low', 'Medium', 'High']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final rec = _recommendation!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soil Analysis Complete',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildResultItem('Assessment', rec.assessment, Icons.analytics_outlined),
        _buildResultItem('Soil Health Advice', rec.fertilizers, Icons.science_outlined, isSpecial: true),
        _buildResultItem('Organic Solutions', rec.organicAmendments, Icons.eco_outlined),
        if (rec.limeRecommendation.isNotEmpty && rec.limeRecommendation.toLowerCase() != 'none')
          _buildResultItem('pH Correction', rec.limeRecommendation, Icons.water_drop_outlined),
        _buildResultItem('Next Steps', rec.nextSteps, Icons.format_list_numbered_rounded),
      ],
    );
  }

  Widget _buildResultItem(String title, String content, IconData icon, {bool isSpecial = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isSpecial ? AppColors.surfaceContainerLow : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: isSpecial ? Border.all(color: AppColors.primaryGreen.withOpacity(0.1)) : null,
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
}
