import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/market_provider.dart';
import '../../../core/services/ai_service.dart';
import '../../../data/models/market_price_model.dart';
import '../../../core/providers/smart_context_provider.dart';
import '../../../data/models/smart_context_model.dart';

class MandiPricesScreen extends ConsumerStatefulWidget {
  const MandiPricesScreen({super.key});

  @override
  ConsumerState<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends ConsumerState<MandiPricesScreen> {
  String? _selectedCommodity;
  String _selectedState = 'Maharashtra';

  @override
  Widget build(BuildContext context) {
    final mandiAsync = ref.watch(mandiProvider);
    final smartContext = ref.watch(smartContextProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Official Mandi Rates',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.celestialGradient,
          ),
        ),
      ),
      body: mandiAsync.when(
        data: (prices) {
          final availableCommodities = prices.map((p) => p.commodity).toSet().toList()..sort();
          if (availableCommodities.isEmpty) availableCommodities.add('Wheat');
          
          String currentCommodity = _selectedCommodity ?? '';
          if (!availableCommodities.contains(currentCommodity)) {
            final profile = smartContext.profile;
            if (profile != null && profile.cropsGrown.isNotEmpty && availableCommodities.contains(profile.cropsGrown.first)) {
              currentCommodity = profile.cropsGrown.first;
            } else {
              currentCommodity = availableCommodities.first;
            }
          }

          final filteredPrices = prices.where((p) => p.commodity == currentCommodity).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFilters(availableCommodities, currentCommodity),
                const SizedBox(height: 24),
                if (filteredPrices.isNotEmpty) _buildBestMandiCard(filteredPrices.first),
                const SizedBox(height: 24),
                _buildSmartMarketAnalysis(filteredPrices, smartContext, currentCommodity),
                const SizedBox(height: 24),
                _buildPriceTrendChart(),
                const SizedBox(height: 24),
                _buildPriceTable(filteredPrices),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text('Connection Issue', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text('Unable to fetch live data. Please check your internet or API keys.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(List<String> commodities, String currentCommodity) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Commodity', isDense: true),
            value: currentCommodity,
            items: commodities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCommodity = val);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'State', isDense: true),
            initialValue: _selectedState,
            items: const [
              DropdownMenuItem(value: 'Maharashtra', child: Text('Maharashtra')),
              DropdownMenuItem(value: 'Uttar Pradesh', child: Text('UP')),
              DropdownMenuItem(value: 'Punjab', child: Text('Punjab')),
              DropdownMenuItem(value: 'Rajasthan', child: Text('Rajasthan')),
            ],
            onChanged: (val) {
               if (val != null) setState(() => _selectedState = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSmartMarketAnalysis(List<MarketPrice> prices, FarmerContext smartContext, String currentCommodity) {
    if (prices.isEmpty) return const SizedBox.shrink();

    final priceData = prices.take(5).map((p) => {
      'market': p.market,
      'price': p.modalPrice,
      'district': p.district,
    }).toList();

    return FutureBuilder<String>(
      future: AIService().getMarketAnalysis(smartContext, priceData, currentCommodity),
      builder: (context, snapshot) {
        final advice = snapshot.data ?? 'Analyzing current market trends...';
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryEmerald.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('💰', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI MARKET STRATEGY',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryEmerald,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      advice,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBestMandiCard(MarketPrice price) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryEmerald.withValues(alpha: 0.05),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.stars_rounded, color: AppColors.primaryEmerald, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Live Market Highlight', 
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${price.market} (${price.district}) is offering ₹${price.modalPrice.toInt()}/qtl for ${price.commodity}. Updated on ${price.date}.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500),
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
        borderRadius: BorderRadius.circular(28),
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
          Text(
            'Weekly Price Analytics', 
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)
          ),
          Text(
            'Projected trend based on current arrivals', 
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w600)
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: AppColors.outlineVariant.withValues(alpha: 0.3), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(days[value.toInt()], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textHint)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 1000,
                maxY: 5000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2200),
                      FlSpot(1, 2350),
                      FlSpot(2, 2300),
                      FlSpot(3, 2450),
                      FlSpot(4, 2500),
                      FlSpot(5, 2400),
                      FlSpot(6, 2600),
                    ],
                    isCurved: true,
                    gradient: AppTheme.celestialGradient,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true, 
                      gradient: LinearGradient(
                        colors: [AppColors.primaryEmerald.withValues(alpha: 0.2), AppColors.primaryEmerald.withValues(alpha: 0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

  Widget _buildPriceTable(List<MarketPrice> prices) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                'Current Arrivals', 
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)
              ),
              IconButton(
                icon: const Icon(Icons.sync_rounded, color: AppColors.primaryEmerald), 
                onPressed: () => ref.refresh(mandiProvider),
                style: IconButton.styleFrom(backgroundColor: AppColors.primaryEmerald.withValues(alpha: 0.1)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (prices.isEmpty) 
             Center(child: Text('No active data for selected filters', style: GoogleFonts.plusJakartaSans(color: AppColors.textHint)))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                horizontalMargin: 0,
                columnSpacing: 32,
                headingRowHeight: 40,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 56,
                columns: [
                  DataColumn(label: Text('District', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.textHint, fontSize: 12))),
                  DataColumn(label: Text('Mandi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.textHint, fontSize: 12))),
                  DataColumn(label: Text('Modal Rate', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.textHint, fontSize: 12))),
                ],
                rows: prices.take(10).map<DataRow>((MarketPrice p) => DataRow(
                  cells: [
                    DataCell(Text(p.district, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                    DataCell(Text(p.market, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                    DataCell(Text('₹${p.modalPrice.toInt()}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primaryEmerald, fontSize: 15))),
                  ],
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
