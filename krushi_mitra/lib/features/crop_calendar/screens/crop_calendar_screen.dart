import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';

// AI-generated crop calendar data based on farmer's crops
final _cropCalendarData = <String, Map<String, dynamic>>{
  'Wheat': {
    'season': 'Rabi',
    'duration': '135 Days',
    'emoji': '🌾',
    'months': [
      {'month': 'Nov', 'phase': 'Land Prep & Sowing', 'tasks': ['Deep ploughing after first rain', 'Apply FYM 5-8 tonnes/acre', 'Sow at 20cm row spacing']},
      {'month': 'Dec', 'phase': 'Tillering Stage', 'tasks': ['First irrigation 21 DAS', 'Apply urea 35 kg/acre top dressing', 'Hand weeding or 2,4-D spray']},
      {'month': 'Jan', 'phase': 'Jointing', 'tasks': ['Second irrigation at jointing', 'Monitor for rust/smut', 'Spray Propiconazole if rust seen']},
      {'month': 'Feb', 'phase': 'Heading & Flowering', 'tasks': ['Critical irrigation at flowering', 'Watch for aphid attack', 'No nitrogen after this stage']},
      {'month': 'Mar-Apr', 'phase': 'Maturity & Harvest', 'tasks': ['Stop irrigation 15 days before', 'Harvest when grain is hard & golden', 'Thresh within 3 days of cutting']},
    ],
  },
  'Rice': {
    'season': 'Kharif',
    'duration': '120 Days',
    'emoji': '🍚',
    'months': [
      {'month': 'Jun', 'phase': 'Nursery & Transplanting', 'tasks': ['Raise nursery 20 days before', 'Puddling and levelling', 'Transplant 2-3 seedlings per hill']},
      {'month': 'Jul', 'phase': 'Tillering', 'tasks': ['Maintain 5cm standing water', 'Apply urea 25 kg/acre', 'Hand weeding at 20 & 40 DAS']},
      {'month': 'Aug', 'phase': 'Panicle Initiation', 'tasks': ['Second top dressing of urea', 'Monitor for stem borer', 'Ensure continuous water']},
      {'month': 'Sep', 'phase': 'Flowering & Grain Fill', 'tasks': ['Critical irrigation stage', 'Spray for blast if spotted', 'No nitrogen after flowering']},
      {'month': 'Oct', 'phase': 'Harvest', 'tasks': ['Drain field 10 days before', 'Harvest at 20% grain moisture', 'Sun-dry to 14% for storage']},
    ],
  },
  'Soybean': {
    'season': 'Kharif',
    'duration': '120 Days',
    'emoji': '🫘',
    'months': [
      {'month': 'Jun', 'phase': 'Land Prep & Sowing', 'tasks': ['Deep ploughing', 'Apply FYM 10 t/ha', 'Seed treatment with Rhizobium']},
      {'month': 'Jul', 'phase': 'Germination & Growth', 'tasks': ['Sow at 3-4 cm depth', 'Maintain soil moisture', 'Apply pre-emergence herbicide']},
      {'month': 'Aug', 'phase': 'Vegetative Growth', 'tasks': ['First weeding at 20 DAS', 'Top dressing nitrogen if needed', 'Monitor for stem fly']},
      {'month': 'Sep', 'phase': 'Flowering & Pods', 'tasks': ['Ensure adequate irrigation', 'Spray for pod borer if needed']},
      {'month': 'Oct', 'phase': 'Maturity & Harvest', 'tasks': ['Stop irrigation 15 days before', 'Harvest when pods turn brown']},
    ],
  },
  'Cotton': {
    'season': 'Kharif',
    'duration': '160 Days',
    'emoji': '🏵️',
    'months': [
      {'month': 'May-Jun', 'phase': 'Sowing', 'tasks': ['Treat seeds with Imidacloprid', 'Sow at 90x60 cm spacing', 'Apply basal dose DAP 50 kg/acre']},
      {'month': 'Jul', 'phase': 'Vegetative Growth', 'tasks': ['Thinning to 1 plant per hill', 'Inter-cultivation for weeds', 'Top dress urea 25 kg/acre']},
      {'month': 'Aug', 'phase': 'Squaring & Flowering', 'tasks': ['Monitor for bollworm', 'Install pheromone traps', 'Second top dressing']},
      {'month': 'Sep-Oct', 'phase': 'Boll Formation', 'tasks': ['Spray Neem oil for sucking pests', 'Adequate irrigation at boll stage', 'Pick mature bolls promptly']},
      {'month': 'Nov-Dec', 'phase': 'Final Picking', 'tasks': ['Complete picking before rains', 'Grade cotton by quality', 'Sell when market price is favorable']},
    ],
  },
  'Onion': {
    'season': 'Rabi',
    'duration': '130 Days',
    'emoji': '🧅',
    'months': [
      {'month': 'Oct-Nov', 'phase': 'Nursery & Transplanting', 'tasks': ['Raise nursery 6 weeks before', 'Transplant seedlings at 15x10cm', 'Apply FYM + Potash at transplanting']},
      {'month': 'Dec', 'phase': 'Bulb Initiation', 'tasks': ['Irrigate every 7-10 days', 'Apply Sulphur 10 kg/acre', 'Weed control critical period']},
      {'month': 'Jan', 'phase': 'Bulb Development', 'tasks': ['Top dress urea 20 kg/acre', 'Monitor for thrips', 'Spray Imidacloprid if thrips cross ETL']},
      {'month': 'Feb', 'phase': 'Maturity', 'tasks': ['Reduce irrigation frequency', 'When 50% neck fall, stop water', 'Cure bulbs in shade for 7 days']},
      {'month': 'Mar', 'phase': 'Harvest & Storage', 'tasks': ['Harvest, cure, and grade', 'Store in well-ventilated shed', 'Sell in batches for best price']},
    ],
  },
  'Tomato': {
    'season': 'Kharif/Rabi',
    'duration': '120 Days',
    'emoji': '🍅',
    'months': [
      {'month': 'Sep-Oct', 'phase': 'Nursery & Transplanting', 'tasks': ['Raise seedlings in pro-trays', 'Transplant at 60x45cm', 'Stake plants early']},
      {'month': 'Nov', 'phase': 'Vegetative & Flowering', 'tasks': ['Apply 19:19:19 foliar spray', 'Pinch side shoots', 'Monitor for whitefly & leaf curl']},
      {'month': 'Dec', 'phase': 'Fruiting', 'tasks': ['Drip irrigation is ideal', 'Apply Calcium for blossom end rot', 'Spray Mancozeb for late blight']},
      {'month': 'Jan', 'phase': 'Harvesting', 'tasks': ['Pick at breaker stage for transport', 'Harvest every 3-4 days', 'Grade by size and color']},
      {'month': 'Feb', 'phase': 'Final Harvest', 'tasks': ['Remove old plants', 'Apply neem cake to soil', 'Plan rotation — avoid Solanaceae']},
    ],
  },
};

// Fallback for crops not in our database
Map<String, dynamic> _getDefaultCalendar(String cropName) {
  final month = DateTime.now().month;
  final season = (month >= 6 && month <= 9) ? 'Kharif' : (month >= 10 || month <= 2) ? 'Rabi' : 'Zaid';
  return {
    'season': season,
    'duration': '~120 Days',
    'emoji': '🌿',
    'months': [
      {'month': 'Month 1', 'phase': 'Land Preparation', 'tasks': ['Soil testing & ploughing', 'Apply organic manure', 'Seed selection & treatment']},
      {'month': 'Month 2', 'phase': 'Sowing & Early Growth', 'tasks': ['Sow at recommended spacing', 'First irrigation after sowing', 'Pre-emergence weed control']},
      {'month': 'Month 3', 'phase': 'Vegetative Growth', 'tasks': ['Top dressing fertilizer', 'Inter-cultivation', 'Pest monitoring']},
      {'month': 'Month 4', 'phase': 'Reproductive Stage', 'tasks': ['Critical irrigation', 'Foliar nutrient spray', 'Disease management']},
      {'month': 'Month 5', 'phase': 'Harvest', 'tasks': ['Harvest at optimal maturity', 'Post-harvest processing', 'Market or store properly']},
    ],
  };
}

class CropCalendarScreen extends ConsumerStatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  ConsumerState<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends ConsumerState<CropCalendarScreen> {
  String? _selectedCrop;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Crop Calendar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.celestialGradient)),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryEmerald)),
        error: (_, __) => _buildBody(['Wheat', 'Rice']),
        data: (profile) {
          final crops = (profile != null && profile.cropsGrown.isNotEmpty)
              ? profile.cropsGrown
              : ['Wheat', 'Rice'];
          return _buildBody(crops);
        },
      ),
    );
  }

  Widget _buildBody(List<String> farmerCrops) {
    _selectedCrop ??= farmerCrops.first;
    final cropData = _cropCalendarData[_selectedCrop] ?? _getDefaultCalendar(_selectedCrop!);
    final months = cropData['months'] as List<Map<String, dynamic>>;

    // Determine which month tile is "active" — closest to current month
    final currentMonthIdx = _getActiveIndex(months);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
            border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.2))),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryEmerald.withValues(alpha: 0.15),
                      AppColors.neonCyan.withValues(alpha: 0.05)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.primaryEmerald.withValues(alpha: 0.2), blurRadius: 15)],
                      ),
                      child: Center(child: Text(cropData['emoji'] as String, style: const TextStyle(fontSize: 32))),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selectedCrop!, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                            child: Text('${cropData['season']} Season • ${cropData['duration']}', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (farmerCrops.length > 1) ...[
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: farmerCrops.map((crop) {
                      final isSelected = crop == _selectedCrop;
                      final data = _cropCalendarData[crop];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCrop = crop),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryEmerald : AppColors.surfaceVariant.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? AppColors.neonCyan : Colors.transparent),
                              boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryEmerald.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 4))] : [],
                            ),
                            child: Text(
                              '${data?['emoji'] ?? '🌿'} $crop',
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final monthData = months[index];
              return TimelineTile(
                isFirst: index == 0,
                isLast: index == months.length - 1,
                month: monthData['month'] as String,
                phase: monthData['phase'] as String,
                tasks: (monthData['tasks'] as List).cast<String>(),
                isActive: index == currentMonthIdx,
              );
            },
          ),
        ),
      ],
    );
  }

  int _getActiveIndex(List<Map<String, dynamic>> months) {
    final currentMonth = DateTime.now().month;
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final currentShort = monthNames[currentMonth - 1];
    
    for (int i = 0; i < months.length; i++) {
      final m = months[i]['month'] as String;
      if (m.contains(currentShort)) return i;
    }
    return 0;
  }
}

class TimelineTile extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final String month;
  final String phase;
  final List<String> tasks;
  final bool isActive;

  const TimelineTile({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.month,
    required this.phase,
    required this.tasks,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst) Container(height: 20, width: 2, decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [AppColors.outline.withValues(alpha: 0.1), isActive ? AppColors.primaryEmerald : AppColors.outline.withValues(alpha: 0.3)]
                  ),
                  borderRadius: BorderRadius.circular(1),
                )),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryEmerald : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? AppColors.neonCyan : AppColors.outline.withValues(alpha: 0.5), 
                      width: isActive ? 4 : 2
                    ),
                    boxShadow: isActive ? [BoxShadow(color: AppColors.primaryEmerald.withValues(alpha: 0.5), blurRadius: 10)] : [],
                  ),
                  child: isActive ? const Icon(Icons.star_rounded, color: Colors.white, size: 14) : null,
                ),
                if (!isLast) Expanded(child: Container(width: 2, decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [isActive ? AppColors.primaryEmerald : AppColors.outline.withValues(alpha: 0.3), AppColors.outline.withValues(alpha: 0.1)]
                  ),
                  borderRadius: BorderRadius.circular(1),
                ))),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryEmerald.withValues(alpha: 0.08) : AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: isActive ? AppColors.primaryEmerald.withValues(alpha: 0.4) : AppColors.outline.withValues(alpha: 0.2)),
                  boxShadow: isActive ? [BoxShadow(color: AppColors.primaryEmerald.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 12))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primaryEmerald : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              month,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: isActive ? Colors.white : AppColors.textSecondary, letterSpacing: 0.5),
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.neonCyan.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                              child: Text('CURRENT', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.neonCyan, letterSpacing: 1.5)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(phase, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: isActive ? AppColors.primaryEmerald : AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      ...tasks.map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(color: isActive ? AppColors.primaryEmerald.withValues(alpha: 0.2) : AppColors.surfaceVariant, shape: BoxShape.circle),
                                child: Icon(Icons.check_rounded, size: 12, color: isActive ? AppColors.primaryEmerald : AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(task, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600, height: 1.5))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
