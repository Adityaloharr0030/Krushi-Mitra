import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.backgroundStone,
        appBar: AppBar(
          title: const Text('Agri Calculators'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primaryGreen,
            indicatorWeight: 3,
            tabs: [
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
            Center(child: Text('Seed Rate Calculator')),
            Center(child: Text('Pesticide Calculator')),
            Center(child: Text('Irrigation Calculator')),
          ],
        ),
      ),
    );
  }
}

class _FertilizerCalculator extends StatefulWidget {
  const _FertilizerCalculator();

  @override
  State<_FertilizerCalculator> createState() => _FertilizerCalculatorState();
}

class _FertilizerCalculatorState extends State<_FertilizerCalculator> {
  final _areaController = TextEditingController();
  String _crop = 'Wheat';
  Map<String, double>? _result;

  void _calculate() {
    final area = double.tryParse(_areaController.text);
    if (area == null || area <= 0) return;

    double urea = 0, dap = 0, mop = 0;
    
    switch (_crop) {
      case 'Wheat': urea = 45; dap = 50; mop = 20; break;
      case 'Rice': urea = 50; dap = 40; mop = 25; break;
      case 'Cotton': urea = 60; dap = 50; mop = 30; break;
      case 'Soybean': urea = 20; dap = 60; mop = 20; break;
    }

    setState(() {
      _result = {
        'Urea': urea * area,
        'DAP': dap * area,
        'MOP': mop * area,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Calculator Input', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: _crop,
                  decoration: const InputDecoration(labelText: 'Select Crop'),
                  items: ['Wheat', 'Rice', 'Cotton', 'Soybean']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _crop = val!),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _areaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Land Area',
                    suffixText: 'Acres',
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Calculate Needs', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 40),
            const Text('Required Fertilizers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildResultRow('Urea (Nitrogen)', _result!['Urea']!, Colors.grey.shade400),
            _buildResultRow('DAP (Phosphorus)', _result!['DAP']!, Colors.grey.shade800),
            _buildResultRow('MOP (Potassium)', _result!['MOP']!, Colors.red.shade200),
          ]
        ],
      ),
    );
  }

  Widget _buildResultRow(String name, double amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(Icons.science_rounded, color: color, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${amount.toStringAsFixed(1)} kg', style: const TextStyle(color: AppColors.primaryGreen, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
