import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/services/market_service.dart';
import 'package:fl_chart/fl_chart.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _marketService = MarketService();
  List<MarketPrice> _prices = [];
  bool _isLoading = true;
  String _selectedState = 'Maharashtra';
  String _selectedCommodity = '';

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    setState(() => _isLoading = true);
    try {
      final prices = await _marketService.getMarketPrices(
        state: _selectedState,
        commodity: _selectedCommodity.isEmpty ? null : _selectedCommodity,
      );
      setState(() {
        _prices = prices;
      });
    } catch (e) {
      debugPrint('Error loading prices: \$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Mandi Prices (मंडी भाव)'),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildPricesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedState,
                  decoration: const InputDecoration(labelText: 'State', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: _marketService.getAvailableStates()
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedState = value);
                      _loadPrices();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search Commodity',
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              _selectedCommodity = value;
              // Debounce in a real app
              _loadPrices();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricesList() {
    if (_prices.isEmpty) {
      return const Center(child: Text('No mandi prices found for this criteria.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _prices.length,
      itemBuilder: (context, index) {
        final price = _prices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price.commodity,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹\${price.modalPrice}/Qtl',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('\${price.variety} • \${price.market}, \${price.district}'),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Min Range', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text('₹\${price.minPrice}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Max Range', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text('₹\${price.maxPrice}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: _buildMiniChart(price.commodity),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Updated: \${price.date}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_active, size: 16),
                      label: const Text('Set Alert'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniChart(String commodity) {
    final trendData = _marketService.getPriceTrend(commodity);
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: trendData.reduce((a, b) => a < b ? a : b) * 0.9,
        maxY: trendData.reduce((a, b) => a > b ? a : b) * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: trendData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
