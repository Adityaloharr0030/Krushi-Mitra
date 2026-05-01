import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: \$e')));
      }
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Soil Advisor',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_recommendation != null) 
              _buildResultCard()
            else ...[
              _buildInputForm(),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: _isAnalyzing ? null : AppTheme.celestialGradient,
                  color: _isAnalyzing ? AppColors.outlineVariant : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isAnalyzing ? null : [
                    BoxShadow(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeSoil,
                  icon: _isAnalyzing 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Icon(Icons.analytics_rounded, color: Colors.white),
                  label: Text(
                    _isAnalyzing ? 'Analyzing Soil...' : 'Get AI Recommendation',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
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
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppTheme.celestialGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Soil Health Data', 
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            DropdownButtonFormField<String>(
              initialValue: _soilType,
              decoration: const InputDecoration(labelText: 'Soil Type', prefixIcon: Icon(Icons.terrain_rounded)),
              items: ['Black', 'Red', 'Alluvial', 'Sandy', 'Loamy']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _soilType = val!),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'pH Level', prefixIcon: Icon(Icons.science_rounded)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onSaved: (val) => _ph = val ?? '',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Crop', prefixIcon: Icon(Icons.grass_rounded)),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => _crop = val!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              decoration: const InputDecoration(labelText: 'Field Area', suffixText: 'Acres', prefixIcon: Icon(Icons.square_foot_rounded)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _area = val!,
            ),
            const SizedBox(height: 32),

            Text(
              'Macronutrient Levels', 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textSecondary)
            ),
            const SizedBox(height: 16),
            
            _buildNutrientDropdown('Nitrogen (N)', _nitrogen, (val) => setState(() => _nitrogen = val!)),
            const SizedBox(height: 12),
            _buildNutrientDropdown('Phosphorus (P)', _phosphorus, (val) => setState(() => _phosphorus = val!)),
            const SizedBox(height: 12),
            _buildNutrientDropdown('Potassium (K)', _potassium, (val) => setState(() => _potassium = val!)),
          ],
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Analysis', 
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryEmerald), 
                  onPressed: () => setState(() => _recommendation = null),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primaryEmerald.withValues(alpha: 0.1)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1),
            ),
            _buildResultSection('Assessment', rec.assessment, Icons.analytics_rounded, AppColors.primaryEmerald),
            _buildResultSection('Fertilizers Needed', rec.fertilizers, Icons.science_rounded, AppColors.primaryEmerald),
            _buildResultSection('Organic Amendments', rec.organicAmendments, Icons.eco_rounded, Colors.orange),
            if (rec.limeRecommendation.isNotEmpty && rec.limeRecommendation.toLowerCase() != 'none')
              _buildResultSection('pH Correction', rec.limeRecommendation, Icons.water_drop_rounded, Colors.blue),
            if (rec.micronutrients.isNotEmpty && rec.micronutrients.toLowerCase() != 'none')
              _buildResultSection('Micronutrients', rec.micronutrients, Icons.grain_rounded, Colors.purple),
            _buildResultSection('Next Steps', rec.nextSteps, Icons.checklist_rounded, AppColors.primaryEmerald),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(String title, String content, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title, 
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, 
              color: AppColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
