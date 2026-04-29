import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/market_provider.dart';

final selectedMarketFilterProvider = StateProvider<String>((ref) => 'All Crops');

class MarketPricesScreen extends ConsumerWidget {
  const MarketPricesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mandiAsync = ref.watch(mandiProvider);
    final selectedFilter = ref.watch(selectedMarketFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   mandiAsync.when(
                    data: (prices) => _buildMarketOverviewCard(prices),
                    loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Live Mandi Rates'),
                  const SizedBox(height: 12),
                  _buildMarketFilters(ref, selectedFilter),
                  const SizedBox(height: 16),
                  mandiAsync.when(
                    data: (prices) => _buildCommodityList(prices, selectedFilter),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      title: Text(
        'Market Prices',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildMarketOverviewCard(List<dynamic> prices) {
    // Determine overall trend (dummy logic for premium feel)
    bool isBullish = true; 
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBullish 
              ? [const Color(0xFF1B5E20), const Color(0xFF004D40)]
              : [const Color(0xFFE65100), const Color(0xFFBF360C)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isBullish ? const Color(0xFF1B5E20) : const Color(0xFFE65100)).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market Trend',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      isBullish ? 'Bullish 📈' : 'Bearish 📉',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    prices.isNotEmpty ? prices.first.market : 'Local Mandi',
                    style: GoogleFonts.manrope(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Prices for ${prices.length} main commodities are currently stable across your region.',
              style: GoogleFonts.manrope(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildMarketFilters(WidgetRef ref, String selected) {
    final filters = ['All Crops', 'Grains', 'Vegetables', 'Fruits'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;
          return GestureDetector(
            onTap: () => ref.read(selectedMarketFilterProvider.notifier).state = filter,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
              child: Text(
                filter,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommodityList(List<dynamic> prices, String filter) {
    // Very simple filtering logic for the mock categories
    final filtered = filter == 'All Crops' 
        ? prices 
        : prices.where((p) {
            if (filter == 'Grains') return ['Wheat', 'Rice', 'Maize', 'Bajra'].contains(p.commodity);
            if (filter == 'Vegetables') return ['Tomato', 'Onion', 'Potato'].contains(p.commodity);
            return true;
          }).toList();

    return Column(
      children: filtered.map((item) {
        final isUp = item.modalPrice > 2000; // Dummy comparison
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getEmoji(item.commodity),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.commodity,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '${item.market}, ${item.state}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${item.modalPrice.round()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isUp ? AppColors.primary : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isUp ? '+₹20' : '-₹45',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isUp ? AppColors.primary : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getEmoji(String name) {
    if (name.contains('Wheat')) return '🌾';
    if (name.contains('Cotton')) return '☁️';
    if (name.contains('Onion')) return '🧅';
    if (name.contains('Tomato')) return '🍅';
    if (name.contains('Soybean')) return '🫘';
    return '🌱';
  }
}
