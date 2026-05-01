import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/market_provider.dart';
import '../../../core/services/market_service.dart';

class MandiPricesScreen extends ConsumerStatefulWidget {
  const MandiPricesScreen({super.key});

  @override
  ConsumerState<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends ConsumerState<MandiPricesScreen> {
  String _selectedCommodity = 'Wheat';
  String _selectedState = 'Maharashtra';

  @override
  Widget build(BuildContext context) {
    final mandiAsync = ref.watch(mandiProvider);

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
        data: (prices) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFilters(),
              const SizedBox(height: 24),
              if (prices.isNotEmpty) _buildBestMandiCard(prices.first),
              const SizedBox(height: 24),
              _buildPriceTrendChart(),
              const SizedBox(height: 24),
              _buildPriceTable(prices),
            ],
          ),
        ),
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

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Commodity', isDense: true),
            initialValue: _selectedCommodity,
            items: const [
              DropdownMenuItem(value: 'Wheat', child: Text('Wheat')),
              DropdownMenuItem(value: 'Rice', child: Text('Rice')),
              DropdownMenuItem(value: 'Onion', child: Text('Onion')),
              DropdownMenuItem(value: 'Tomato', child: Text('Tomato')),
            ],
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
                rows: prices.take(10).map((p) => DataRow(
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
