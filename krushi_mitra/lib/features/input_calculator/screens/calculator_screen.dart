import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Agri Calculators',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.celestialGradient,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Fertilizer'),
              Tab(text: 'Seed Rate'),
              Tab(text: 'Pesticide'),
              Tab(text: 'Irrigation'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FertilizerCalculator(),
            _SeedRateCalculator(),
            _PesticideCalculator(),
            _IrrigationCalculator(),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────
class _CalcCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CalcCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        ],
      ),
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
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const _ResultCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value $unit',
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildCalcDropdown<T>({
  required T value,
  required List<T> items,
  required String label,
  required ValueChanged<T?> onChanged,
}) {
  return DropdownButtonFormField<T>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    dropdownColor: AppColors.surfaceContainerHigh,
    style: GoogleFonts.manrope(color: AppColors.onSurface, fontSize: 15),
    items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString()))).toList(),
    onChanged: onChanged,
  );
}

Widget _buildNumField(TextEditingController ctrl, String label, String suffix) {
  return TextFormField(
    controller: ctrl,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    style: GoogleFonts.manrope(color: AppColors.onSurface),
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      suffixStyle: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 12),
    ),
  );
}

Widget _buildCalcButton(String label, VoidCallback onTap) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      gradient: AppTheme.celestialGradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryEmerald.withValues(alpha: 0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
      ),
    ),
  );
}

// ─── 1. Fertilizer Calculator ─────────────────────────────────────
class _FertilizerCalculator extends StatefulWidget {
  const _FertilizerCalculator();

  @override
  State<_FertilizerCalculator> createState() => _FertilizerCalculatorState();
}

class _FertilizerCalculatorState extends State<_FertilizerCalculator> {
  final _areaCtrl = TextEditingController();
  String _crop = 'Wheat';
  Map<String, double>? _result;

  // NPK requirements per acre (Urea, DAP, MOP) in kg
  static const _requirements = {
    'Wheat':     {'Urea': 45.0, 'DAP': 50.0, 'MOP': 20.0},
    'Rice':      {'Urea': 50.0, 'DAP': 40.0, 'MOP': 25.0},
    'Cotton':    {'Urea': 60.0, 'DAP': 50.0, 'MOP': 30.0},
    'Soybean':   {'Urea': 20.0, 'DAP': 60.0, 'MOP': 20.0},
    'Onion':     {'Urea': 55.0, 'DAP': 45.0, 'MOP': 35.0},
    'Sugarcane': {'Urea': 80.0, 'DAP': 60.0, 'MOP': 50.0},
    'Maize':     {'Urea': 65.0, 'DAP': 55.0, 'MOP': 25.0},
    'Tomato':    {'Urea': 40.0, 'DAP': 70.0, 'MOP': 60.0},
  };

  void _calculate() {
    final area = double.tryParse(_areaCtrl.text);
    if (area == null || area <= 0) return;
    final req = _requirements[_crop]!;
    setState(() {
      _result = {
        'Urea': req['Urea']! * area,
        'DAP': req['DAP']! * area,
        'MOP': req['MOP']! * area,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CalcCard(
            title: 'Fertilizer Requirement',
            children: [
              _buildCalcDropdown<String>(
                value: _crop,
                items: _requirements.keys.toList(),
                label: 'Select Crop',
                onChanged: (v) => setState(() { _crop = v!; _result = null; }),
              ),
              const SizedBox(height: 16),
              _buildNumField(_areaCtrl, 'Land Area', 'Acres'),
              const SizedBox(height: 24),
              _buildCalcButton('Calculate Fertilizer Needs', _calculate),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Text(
              'Required Quantities',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _ResultCard(label: 'Urea (Nitrogen — N)', value: _result!['Urea']!.toStringAsFixed(1), unit: 'kg', color: const Color(0xFF64B5F6), icon: Icons.science_rounded),
            _ResultCard(label: 'DAP (Phosphorus — P)', value: _result!['DAP']!.toStringAsFixed(1), unit: 'kg', color: const Color(0xFFA5D6A7), icon: Icons.science_rounded),
            _ResultCard(label: 'MOP (Potassium — K)',  value: _result!['MOP']!.toStringAsFixed(1), unit: 'kg', color: const Color(0xFFFFCC80), icon: Icons.science_rounded),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Split Urea into 3 doses: basal, tillering & panicle. Apply DAP & MOP as basal.',
                      style: GoogleFonts.manrope(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── 2. Seed Rate Calculator ──────────────────────────────────────
class _SeedRateCalculator extends StatefulWidget {
  const _SeedRateCalculator();

  @override
  State<_SeedRateCalculator> createState() => _SeedRateCalculatorState();
}

class _SeedRateCalculatorState extends State<_SeedRateCalculator> {
  final _areaCtrl = TextEditingController();
  String _crop = 'Wheat';
  String _method = 'Broadcasting';
  Map<String, dynamic>? _result;

  static const _seedRates = {
    'Wheat':     {'Broadcasting': 120.0, 'Drilling': 100.0, 'Transplanting': 80.0},
    'Rice':      {'Broadcasting': 60.0,  'Drilling': 40.0,  'Transplanting': 25.0},
    'Cotton':    {'Broadcasting': 4.0,   'Drilling': 3.0,   'Transplanting': 2.5},
    'Soybean':   {'Broadcasting': 75.0,  'Drilling': 65.0,  'Transplanting': 50.0},
    'Onion':     {'Broadcasting': 10.0,  'Drilling': 8.0,   'Transplanting': 5.0},
    'Maize':     {'Broadcasting': 22.0,  'Drilling': 18.0,  'Transplanting': 15.0},
    'Sugarcane': {'Broadcasting': 5000.0,'Drilling': 4500.0,'Transplanting': 4000.0},
    'Tomato':    {'Broadcasting': 0.5,   'Drilling': 0.4,   'Transplanting': 0.3},
  };

  static const _methods = ['Broadcasting', 'Drilling', 'Transplanting'];

  void _calculate() {
    final area = double.tryParse(_areaCtrl.text);
    if (area == null || area <= 0) return;
    final ratePerAcre = _seedRates[_crop]![_method]!;
    final totalSeed = ratePerAcre * area;
    final unit = _crop == 'Sugarcane' ? 'setts' : 'kg';
    setState(() {
      _result = {
        'ratePerAcre': ratePerAcre,
        'totalSeed': totalSeed,
        'unit': unit,
        'note': _crop == 'Sugarcane'
            ? 'Use 2-3 budded setts. Treat with Dithane M-45 before planting.'
            : 'Treat seeds with Thiram @ 3g/kg before sowing for disease protection.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CalcCard(
            title: 'Seed Rate Calculator',
            children: [
              _buildCalcDropdown<String>(
                value: _crop,
                items: _seedRates.keys.toList(),
                label: 'Select Crop',
                onChanged: (v) => setState(() { _crop = v!; _result = null; }),
              ),
              const SizedBox(height: 16),
              _buildCalcDropdown<String>(
                value: _method,
                items: _methods,
                label: 'Sowing Method',
                onChanged: (v) => setState(() { _method = v!; _result = null; }),
              ),
              const SizedBox(height: 16),
              _buildNumField(_areaCtrl, 'Land Area', 'Acres'),
              const SizedBox(height: 24),
              _buildCalcButton('Calculate Seed Requirement', _calculate),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Text(
              'Seed Requirement',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _ResultCard(
              label: 'Rate per Acre',
              value: _result!['ratePerAcre'].toStringAsFixed(1),
              unit: _result!['unit'],
              color: const Color(0xFFA5D6A7),
              icon: Icons.grass_rounded,
            ),
            _ResultCard(
              label: 'Total Seed Required',
              value: _result!['totalSeed'].toStringAsFixed(1),
              unit: _result!['unit'],
              color: AppColors.accentAmber,
              icon: Icons.agriculture_rounded,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accentAmber, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _result!['note'],
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── 3. Pesticide Calculator ──────────────────────────────────────
class _PesticideCalculator extends StatefulWidget {
  const _PesticideCalculator();

  @override
  State<_PesticideCalculator> createState() => _PesticideCalculatorState();
}

class _PesticideCalculatorState extends State<_PesticideCalculator> {
  final _areaCtrl = TextEditingController();
  String _pesticide = 'Chlorpyrifos 20EC';
  String _targetPest = 'Aphids';
  Map<String, dynamic>? _result;

  static const _pesticides = {
    'Chlorpyrifos 20EC': {
      'dose': 2.5, 'unit': 'ml/L', 'sprayVol': 200.0,
      'note': 'Systemic insecticide. Wear gloves & mask. Do not spray near water bodies.',
    },
    'Emamectin Benzoate 5SG': {
      'dose': 0.4, 'unit': 'g/L', 'sprayVol': 150.0,
      'note': 'Effective against Bollworm. PHI: 3 days. Do not spray during flowering.',
    },
    'Lambda-cyhalothrin 5EC': {
      'dose': 1.0, 'unit': 'ml/L', 'sprayVol': 200.0,
      'note': 'Broad-spectrum pyrethroid. Best applied in evening hours.',
    },
    'Copper Oxychloride 50WP': {
      'dose': 3.0, 'unit': 'g/L', 'sprayVol': 200.0,
      'note': 'Fungicide. Do not mix with alkaline compounds. PHI: 7 days.',
    },
    'Mancozeb 75WP': {
      'dose': 2.5, 'unit': 'g/L', 'sprayVol': 200.0,
      'note': 'Preventive fungicide. Repeat every 7-10 days. PHI: 15 days.',
    },
    'Imidacloprid 17.8SL': {
      'dose': 0.5, 'unit': 'ml/L', 'sprayVol': 150.0,
      'note': 'Systemic insecticide. Do not spray on flowering crops — harmful to bees.',
    },
  };

  static const _pests = ['Aphids', 'Whitefly', 'Bollworm', 'Leaf Blight', 'Powdery Mildew', 'Stem Borer'];

  void _calculate() {
    final area = double.tryParse(_areaCtrl.text);
    if (area == null || area <= 0) return;
    final p = _pesticides[_pesticide]!;
    final totalWater = (p['sprayVol'] as double) * area;         // L total
    final totalPesticide = (p['dose'] as double) * totalWater;  // ml or g total
    setState(() {
      _result = {
        'totalWater': totalWater,
        'totalPesticide': totalPesticide,
        'unit': p['unit'],
        'note': p['note'],
        'tanks': (totalWater / 15).ceil(), // 15L knapsack sprayer
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CalcCard(
            title: 'Pesticide Dosage Calculator',
            children: [
              _buildCalcDropdown<String>(
                value: _pesticide,
                items: _pesticides.keys.toList(),
                label: 'Select Pesticide',
                onChanged: (v) => setState(() { _pesticide = v!; _result = null; }),
              ),
              const SizedBox(height: 16),
              _buildCalcDropdown<String>(
                value: _targetPest,
                items: _pests,
                label: 'Target Pest / Disease',
                onChanged: (v) => setState(() { _targetPest = v!; }),
              ),
              const SizedBox(height: 16),
              _buildNumField(_areaCtrl, 'Field Area', 'Acres'),
              const SizedBox(height: 24),
              _buildCalcButton('Calculate Dosage', _calculate),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Text(
              'Application Guide',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _ResultCard(
              label: 'Total Water Required',
              value: _result!['totalWater'].toStringAsFixed(0),
              unit: 'litres',
              color: AppColors.secondary,
              icon: Icons.water_drop_rounded,
            ),
            _ResultCard(
              label: 'Total Pesticide',
              value: _result!['totalPesticide'].toStringAsFixed(1),
              unit: _result!['unit'].toString().split('/').first,
              color: const Color(0xFFEF9A9A),
              icon: Icons.science_outlined,
            ),
            _ResultCard(
              label: 'Knapsack Tanks (15L each)',
              value: _result!['tanks'].toString(),
              unit: 'tanks',
              color: AppColors.accentAmber,
              icon: Icons.backpack_rounded,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.health_and_safety_outlined, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Safety: ${_result!['note']}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── 4. Irrigation Calculator ─────────────────────────────────────
class _IrrigationCalculator extends StatefulWidget {
  const _IrrigationCalculator();

  @override
  State<_IrrigationCalculator> createState() => _IrrigationCalculatorState();
}

class _IrrigationCalculatorState extends State<_IrrigationCalculator> {
  final _areaCtrl = TextEditingController();
  String _crop = 'Wheat';
  String _stage = 'Vegetative';
  String _soilType = 'Medium (Loamy)';
  Map<String, dynamic>? _result;

  // Water requirement in mm/day per crop × growth stage
  static const _waterReq = {
    'Wheat':     {'Vegetative': 4.0, 'Reproductive': 5.5, 'Maturity': 3.0},
    'Rice':      {'Vegetative': 7.0, 'Reproductive': 9.0, 'Maturity': 5.0},
    'Cotton':    {'Vegetative': 5.0, 'Reproductive': 7.0, 'Maturity': 3.5},
    'Sugarcane': {'Vegetative': 6.0, 'Reproductive': 8.0, 'Maturity': 4.0},
    'Maize':     {'Vegetative': 4.5, 'Reproductive': 6.5, 'Maturity': 3.0},
    'Soybean':   {'Vegetative': 4.0, 'Reproductive': 5.5, 'Maturity': 2.5},
    'Tomato':    {'Vegetative': 3.5, 'Reproductive': 5.0, 'Maturity': 3.0},
    'Onion':     {'Vegetative': 3.0, 'Reproductive': 4.5, 'Maturity': 2.0},
  };

  static const _stages = ['Vegetative', 'Reproductive', 'Maturity'];

  // Irrigation interval in days
  static const _intervals = {
    'Light (Sandy)': 4,
    'Medium (Loamy)': 7,
    'Heavy (Clay)': 10,
  };

  void _calculate() {
    final area = double.tryParse(_areaCtrl.text);
    if (area == null || area <= 0) return;
    final mmPerDay = _waterReq[_crop]![_stage]!;
    final interval = _intervals[_soilType]!;
    // 1 mm/day × 1 acre = 4047 litres/day
    final litresPerDay = mmPerDay * area * 4047;
    final litresPerIrrigation = litresPerDay * interval;
    setState(() {
      _result = {
        'mmPerDay': mmPerDay,
        'litresPerDay': litresPerDay,
        'interval': interval,
        'litresPerIrrigation': litresPerIrrigation,
        'tip': _buildTip(_crop, _stage),
      };
    });
  }

  String _buildTip(String crop, String stage) {
    if (stage == 'Reproductive') return 'Critical growth stage — do not skip irrigation.';
    if (stage == 'Maturity') return 'Reduce water for $crop in maturity to improve quality.';
    return 'Irrigate early morning or evening to reduce evaporation.';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CalcCard(
            title: 'Irrigation Water Calculator',
            children: [
              _buildCalcDropdown<String>(
                value: _crop,
                items: _waterReq.keys.toList(),
                label: 'Select Crop',
                onChanged: (v) => setState(() { _crop = v!; _result = null; }),
              ),
              const SizedBox(height: 16),
              _buildCalcDropdown<String>(
                value: _stage,
                items: _stages,
                label: 'Growth Stage',
                onChanged: (v) => setState(() { _stage = v!; _result = null; }),
              ),
              const SizedBox(height: 16),
              _buildCalcDropdown<String>(
                value: _soilType,
                items: _intervals.keys.toList(),
                label: 'Soil Type',
                onChanged: (v) => setState(() { _soilType = v!; _result = null; }),
              ),
              const SizedBox(height: 16),
              _buildNumField(_areaCtrl, 'Field Area', 'Acres'),
              const SizedBox(height: 24),
              _buildCalcButton('Calculate Water Need', _calculate),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Text(
              'Irrigation Schedule',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _ResultCard(
              label: 'Water Requirement / Day',
              value: (_result!['litresPerDay'] / 1000).toStringAsFixed(1),
              unit: 'kL/day',
              color: AppColors.secondary,
              icon: Icons.water_drop_rounded,
            ),
            _ResultCard(
              label: 'Irrigation Interval',
              value: _result!['interval'].toString(),
              unit: 'days',
              color: AppColors.accentAmber,
              icon: Icons.schedule_rounded,
            ),
            _ResultCard(
              label: 'Water per Irrigation',
              value: (_result!['litresPerIrrigation'] / 1000).toStringAsFixed(1),
              unit: 'kL',
              color: const Color(0xFF64B5F6),
              icon: Icons.local_drink_rounded,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_rounded, color: AppColors.primaryEmerald, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _result!['tip'],
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
