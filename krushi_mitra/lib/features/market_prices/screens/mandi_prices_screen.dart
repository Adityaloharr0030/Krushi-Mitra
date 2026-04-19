import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../data/models/mandi_price_model.dart';
import 'package:intl/intl.dart';

class MandiPricesScreen extends StatefulWidget {
  const MandiPricesScreen({super.key});

  @override
  State<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen> {
  // Mock Data
  final List<MandiPrice> _prices = [
    MandiPrice(id: '1', state: 'Maharashtra', district: 'Nashik', commodity: 'Onion', minPrice: 1500, maxPrice: 2200, modalPrice: 1850, date: DateTime.now()),
    MandiPrice(id: '2', state: 'Maharashtra', district: 'Pune', commodity: 'Onion', minPrice: 1600, maxPrice: 2300, modalPrice: 1900, date: DateTime.now()),
    MandiPrice(id: '3', state: 'Maharashtra', district: 'Nashik', commodity: 'Tomato', minPrice: 800, maxPrice: 1500, modalPrice: 1100, date: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStone,
      appBar: AppBar(
        title: const Text('Mandi Intelligence'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilters(),
            const SizedBox(height: 32),
            _buildBestMandiCard(),
            const SizedBox(height: 40),
            Text(
              'Price Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPriceTrendChart(),
            const SizedBox(height: 40),
            Text(
              'Comparative Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPriceComparisonList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: 'Onion',
                items: const [
                  DropdownMenuItem(value: 'Onion', child: Text('Onion')),
                  DropdownMenuItem(value: 'Tomato', child: Text('Tomato')),
                ],
                onChanged: (val) {},
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: 'Nashik',
                items: const [
                  DropdownMenuItem(value: 'Nashik', child: Text('Nashik')),
                  DropdownMenuItem(value: 'Pune', child: Text('Pune')),
                ],
                onChanged: (val) {},
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBestMandiCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.2),
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
              const Icon(Icons.stars_rounded, color: AppColors.tertiarySaffron, size: 24),
              const SizedBox(width: 8),
              Text(
                'Market Opportunity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Pune Mandi is currently offering the highest rate for Onion at ₹1,900/qtl.',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 12),
          Text(
            'This is 5% higher than your local Nashik market.',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.near_me_outlined, size: 18),
            label: const Text('View Route (64 km)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryGreen,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTrendChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 7 Days',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 1500,
                maxY: 2000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1600),
                      FlSpot(1, 1650),
                      FlSpot(2, 1850),
                      FlSpot(3, 1750),
                      FlSpot(4, 1900),
                      FlSpot(5, 1880),
                      FlSpot(6, 1910),
                    ],
                    isCurved: true,
                    color: AppColors.primaryGreen,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryGreen.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceComparisonList() {
    return Column(
      children: _prices.where((p) => p.commodity == 'Onion').map((p) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.backgroundStone,
              child: Text(p.district[0], style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.district, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${p.commodity} • Modal Rate', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${p.modalPrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryGreen)),
                const Text('per Quintal', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }
}
