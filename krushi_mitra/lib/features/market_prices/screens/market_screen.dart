import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
      debugPrint('Error loading prices: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStone,
      appBar: AppBar(
        title: const Text('Mandi Prices'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundStone,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedState,
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
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) {
              _selectedCommodity = value;
              _loadPrices();
            },
            decoration: InputDecoration(
              hintText: 'Search for crops...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
              fillColor: AppColors.surfaceWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricesList() {
    if (_prices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textHint.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('No prices found for this location.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _prices.length,
      itemBuilder: (context, index) {
        final price = _prices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price.commodity,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${price.modalPrice}/Qtl',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${price.market}, ${price.district}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildRangeCol('Min Range', '₹${price.minPrice}'),
                  const Spacer(),
                  _buildRangeCol('Max Range', '₹${price.maxPrice}', isEnd: true),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                width: double.infinity,
                child: _buildMiniChart(price.commodity),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Updated: ${price.date}',
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.notifications_active_outlined, size: 14, color: AppColors.primaryGreen),
                        SizedBox(width: 4),
                        Text('Set Alert', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildRangeCol(String label, String value, {bool isEnd = false}) {
    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textHint, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
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
            color: AppColors.primaryGreen,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryGreen.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }
}
