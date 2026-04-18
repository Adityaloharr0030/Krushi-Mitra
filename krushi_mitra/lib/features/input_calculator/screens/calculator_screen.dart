import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agri Calculators'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.accent,
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

    // Simple mock calculation based on standard recommendations per acre
    double urea = 0, dap = 0, mop = 0;
    
    switch (_crop) {
      case 'Wheat':
        urea = 45; dap = 50; mop = 20; break;
      case 'Rice':
        urea = 50; dap = 40; mop = 25; break;
      case 'Cotton':
        urea = 60; dap = 50; mop = 30; break;
      case 'Soybean':
        urea = 20; dap = 60; mop = 20; break;
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _crop,
                    decoration: const InputDecoration(labelText: 'Select Crop'),
                    items: ['Wheat', 'Rice', 'Cotton', 'Soybean']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _crop = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _areaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Land Area',
                      suffixText: 'Acres',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                    child: const Text('Calculate Needs'),
                  )
                ],
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            const Text('Required Fertilizers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildResultRow('Urea (Nitrogen)', _result!['Urea']!, Colors.grey.shade300),
            const SizedBox(height: 8),
            _buildResultRow('DAP (Phosphorus)', _result!['DAP']!, Colors.grey.shade800),
            const SizedBox(height: 8),
            _buildResultRow('MOP (Potassium)', _result!['MOP']!, Colors.red.shade200),
          ]
        ],
      ),
    );
  }

  Widget _buildResultRow(String name, double amount, Color color) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 16),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text('\${amount.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 18, color: AppColors.primary)),
      ),
    );
  }
}
