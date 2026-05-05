import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/services/market_service.dart';
import '../../../../data/models/market_price_model.dart';
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedState,
            decoration: const InputDecoration(
              labelText: 'Select State',
              prefixIcon: Icon(Icons.map_rounded),
            ),
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
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search Commodity',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (value) {
              _selectedCommodity = value;
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
      padding: const EdgeInsets.all(20),
      itemCount: _prices.length,
      itemBuilder: (context, index) {
        final price = _prices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price.commodity,
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '₹${price.modalPrice}/Qtl',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryEmerald),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${price.variety} • ${price.market}, ${price.district}',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Min Range', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('₹${price.minPrice}', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Max Range', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('₹${price.maxPrice}', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 80,
                width: double.infinity,
                child: _buildMiniChart(price.commodity),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Updated: ${price.date}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textHint, fontWeight: FontWeight.w600)),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_active_rounded, size: 18),
                    label: const Text('Set Alert'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryEmerald,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
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
            color: AppColors.primaryEmerald,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [AppColors.primaryEmerald.withValues(alpha: 0.2), AppColors.primaryEmerald.withValues(alpha: 0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
