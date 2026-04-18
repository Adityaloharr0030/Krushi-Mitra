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
      appBar: AppBar(
        title: const Text('Mandi Prices'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilters(),
            const SizedBox(height: 24),
            _buildBestMandiCard(),
            const SizedBox(height: 24),
            _buildPriceTrendChart(),
            const SizedBox(height: 24),
            _buildPriceTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Commodity', isDense: true),
            value: 'Onion',
            items: const [
              DropdownMenuItem(value: 'Onion', child: Text('Onion')),
              DropdownMenuItem(value: 'Tomato', child: Text('Tomato')),
              DropdownMenuItem(value: 'Wheat', child: Text('Wheat')),
            ],
            onChanged: (val) {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'District', isDense: true),
            value: 'Nashik',
            items: const [
              DropdownMenuItem(value: 'Nashik', child: Text('Nashik')),
              DropdownMenuItem(value: 'Pune', child: Text('Pune')),
            ],
            onChanged: (val) {},
          ),
        ),
      ],
    );
  }

  Widget _buildBestMandiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGreenLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.secondaryAmber),
              const SizedBox(width: 8),
              Text('Best Price Near You', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryGreen)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Pune Mandi is offering ₹1900/qtl for Onion (Modal Price), which is ₹50 higher than Nashik.'),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions (60km)'),
          )
        ],
      ),
    );
  }

  Widget _buildPriceTrendChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('7-Day Price Trend (Onion)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(days[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                  minX: 0,
                  maxX: 6,
                  minY: 1500,
                  maxY: 2500,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1600),
                        FlSpot(1, 1650),
                        FlSpot(2, 1800),
                        FlSpot(3, 1750),
                        FlSpot(4, 1850),
                        FlSpot(5, 1900),
                        FlSpot(6, 1850),
                      ],
                      isCurved: true,
                      color: AppColors.primaryGreen,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: AppColors.primaryGreen.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Today\'s Rates (₹/Quintal)', style: Theme.of(context).textTheme.titleLarge),
                IconButton(icon: const Icon(Icons.add_alert, color: AppColors.secondaryAmber), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(AppColors.surfaceGreenLight),
                columns: const [
                  DataColumn(label: Text('Mandi')),
                  DataColumn(label: Text('Min')),
                  DataColumn(label: Text('Max')),
                  DataColumn(label: Text('Modal')),
                ],
                rows: _prices.where((p) => p.commodity == 'Onion').map((p) => DataRow(
                  cells: [
                    DataCell(Text(p.district)),
                    DataCell(Text('₹${p.minPrice.toInt()}')),
                    DataCell(Text('₹${p.maxPrice.toInt()}')),
                    DataCell(Text('₹${p.modalPrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
