import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/market_provider.dart';
import '../../../core/services/ai_service.dart';
import '../../../data/models/market_price_model.dart';
import '../../../core/providers/smart_context_provider.dart';
import '../../../data/models/smart_context_model.dart';
import '../../../core/constants/api_constants.dart';

class MandiPricesScreen extends ConsumerStatefulWidget {
  const MandiPricesScreen({super.key});

  @override
  ConsumerState<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends ConsumerState<MandiPricesScreen> {

  @override
  Widget build(BuildContext context) {
    final smartContext = ref.watch(smartContextProvider);
    final filters = ref.watch(mandiFiltersProvider);
    final mandiAsync = ref.watch(mandiProvider);
    final useAI = ref.watch(useAIProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          useAI ? 'Smart Predict Mandi Rates' : 'Official Mandi Rates',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.smart_toy_rounded, 
              color: useAI ? AppColors.primaryEmerald : Colors.white,
            ),
            tooltip: useAI ? 'Using Smart predicted pricing' : 'Switch to Smart live pricing',
            onPressed: () {
              ref.read(useAIProvider.notifier).state = !useAI;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !useAI 
                        ? '✨ Switched to live Smart predicted pricing!'
                        : '🏛️ Switched to Official Government Database rates.'
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
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
          const availableCommodities = ApiConstants.supportedCommodities;
          
          // Normalize default commodity
          String defaultCommodity = 'Wheat';
          if (smartContext.profile != null) {
            for (final crop in smartContext.profile!.cropsGrown) {
              final matched = availableCommodities.firstWhere(
                (c) => c.toLowerCase() == crop.trim().toLowerCase(),
                orElse: () => '',
              );
              if (matched.isNotEmpty) {
                defaultCommodity = matched;
                break;
              }
            }
          }

          final currentCommodity = filters.commodity != null && availableCommodities.contains(filters.commodity)
              ? filters.commodity!
              : defaultCommodity;
          
          // Robust filtering with case-insensitive and partial string matches
          var filteredPrices = prices.where((p) {
            final pComm = p.commodity.toLowerCase();
            final cComm = currentCommodity.toLowerCase();
            return pComm == cComm || pComm.contains(cComm) || cComm.contains(pComm);
          }).toList();

          // Safe fallback: if we queried for a specific crop and got results, but local filtering
          // yielded empty due to naming issues, show all results.
          if (filteredPrices.isEmpty && prices.isNotEmpty) {
            filteredPrices = prices;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFilters(availableCommodities, currentCommodity, filters.state),
                const SizedBox(height: 24),
                if (filteredPrices.isNotEmpty) _buildBestMandiCard(filteredPrices.first),
                const SizedBox(height: 24),
                _buildSmartMarketAnalysis(filteredPrices, smartContext, currentCommodity),
                const SizedBox(height: 24),
                _buildPriceTrendChart(filteredPrices),
                const SizedBox(height: 24),
                _buildPriceTable(filteredPrices),
                const SizedBox(height: 24),
                _buildOfficialSourceButton(),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryEmerald)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text('Market Data Unavailable', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                const SizedBox(height: 8),
                Text('No records found for this selection. Try another crop or state.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(mandiProvider),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(List<String> commodities, String currentCommodity, String currentState) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Commodity', isDense: true),
            initialValue: commodities.contains(currentCommodity) ? currentCommodity : commodities.first,
            items: commodities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(mandiFiltersProvider.notifier).update((s) => (state: s.state, commodity: val));
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'State', isDense: true),
            initialValue: currentState,
            items: [
              'Maharashtra', 'Uttar Pradesh', 'Punjab', 'Rajasthan', 'Gujarat', 
              'Madhya Pradesh', 'Karnataka', 'Haryana'
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) {
               if (val != null) {
                 ref.read(mandiFiltersProvider.notifier).update((s) => (state: val, commodity: s.commodity));
               }
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
    final useAI = ref.watch(useAIProvider);
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
                child: Icon(useAI ? Icons.bolt_rounded : Icons.stars_rounded, color: AppColors.primaryEmerald, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                useAI ? 'Smart Price Estimate' : 'Live Market Highlight', 
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            useAI
                ? 'Smart system estimates ${price.market} is offering ₹${price.modalPrice.toInt()}/qtl for ${price.commodity}. (Updated: live sync).'
                : '${price.market} (${price.district}) is offering ₹${price.modalPrice.toInt()}/qtl for ${price.commodity}. Updated on ${price.date}.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTrendChart(List<MarketPrice> prices) {
    if (prices.isEmpty) return const SizedBox.shrink();

    // Build chart spots from real data (up to 7 entries)
    final chartPrices = prices.take(7).toList();
    final spots = <FlSpot>[];
    double minY = double.infinity;
    double maxY = 0;
    for (int i = 0; i < chartPrices.length; i++) {
      final price = chartPrices[i].modalPrice;
      spots.add(FlSpot(i.toDouble(), price));
      if (price < minY) minY = price;
      if (price > maxY) maxY = price;
    }
    // Add padding to Y range
    final yPadding = (maxY - minY) * 0.2;
    minY = (minY - yPadding).clamp(0, double.infinity);
    maxY = maxY + yPadding;

    // Safeguard against layout crashes if minY equals maxY (single price point or all points are identical)
    if (minY == maxY) {
      minY = (minY * 0.9).clamp(0, double.infinity);
      maxY = maxY * 1.1;
      if (minY == 0 && maxY == 0) {
        maxY = 100;
      }
    }

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
            'Price Comparison by Mandi', 
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary)
          ),
          Text(
            'Modal rates across ${chartPrices.length} mandis', 
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
                        final idx = value.toInt();
                        if (idx >= 0 && idx < chartPrices.length) {
                          final name = chartPrices[idx].market;
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(name.length > 6 ? '${name.substring(0, 5)}…' : name, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textHint)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (chartPrices.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: AppTheme.celestialGradient,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
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

  Future<void> _launchUrl(String urlString) async {
    final cleanUrlString = urlString.trim();
    if (cleanUrlString.isEmpty) return;
    
    Uri? url;
    try {
      url = Uri.parse(cleanUrlString);
      if (!url.hasScheme) {
        url = Uri.parse('https://$cleanUrlString');
      }
    } catch (e) {
      debugPrint('Error parsing URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid URL link.')),
        );
      }
      return;
    }

    try {
      bool launched = await launchUrl(url, mode: LaunchMode.platformDefault);
      if (!launched) {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link. Please try manually.')),
        );
      }
    } catch (e) {
      try {
        final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open link. Please try manually.')),
          );
        }
      } catch (ex) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening link: $ex')),
          );
        }
      }
    }
  }

  Widget _buildOfficialSourceButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryEmerald.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl('https://agmarknet.gov.in'),
        icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white),
        label: Text(
          'VISIT OFFICIAL AGMARKNET PORTAL',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryEmerald,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }
}
