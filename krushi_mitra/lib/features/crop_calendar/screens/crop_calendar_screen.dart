import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class CropCalendarScreen extends StatelessWidget {
  const CropCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for a Kharif Soybean crop
    final months = [
      {'month': 'June', 'phase': 'Land Preparation', 'tasks': ['Deep ploughing', 'Apply FYM 10 t/ha', 'Seed treatment with Rhizobium']},
      {'month': 'July', 'phase': 'Sowing & Germination', 'tasks': ['Sow at 3-4 cm depth', 'Maintain soil moisture', 'Apply pre-emergence herbicide']},
      {'month': 'August', 'phase': 'Vegetative Growth', 'tasks': ['First hand weeding at 20 DAS', 'Apply top dressing of Nitrogen if deficient', 'Monitor for stem fly']},
      {'month': 'September', 'phase': 'Flowering & Pod Formation', 'tasks': ['Ensure adequate irrigation', 'Spray for pod borer if crossed ETL']},
      {'month': 'October', 'phase': 'Maturity & Harvesting', 'tasks': ['Stop irrigation 15 days before harvest', 'Harvest when leaves drop and pods turn yellow/brown']},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Crop Calendar',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.celestialGradient,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('🌱', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soybean (JS 335)',
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Kharif Season • 120 Days',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryEmerald),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
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
                  tasks: monthData['tasks'] as List<String>,
                  isActive: index == 2, // Highlight August as current month
                );
              },
            ),
          ),
        ],
      ),
    );
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
          // Timeline logic
          SizedBox(
            width: 90,
            child: Column(
              children: [
                if (!isFirst) Container(height: 20, width: 3, decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryEmerald : AppColors.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isActive ? AppTheme.celestialGradient : null,
                    color: isActive ? null : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isActive ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.5)),
                    boxShadow: isActive ? [
                      BoxShadow(color: AppColors.primaryEmerald.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                    ] : null,
                  ),
                  child: Text(
                    month,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 3, decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryEmerald : AppColors.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isActive ? AppColors.primaryEmerald.withValues(alpha: 0.3) : AppColors.outlineVariant.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isActive ? 0.08 : 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(isActive ? Icons.bolt_rounded : Icons.schedule_rounded, 
                               color: isActive ? AppColors.primaryEmerald : AppColors.textHint, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            phase, 
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800, 
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...tasks.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.primaryEmerald : AppColors.textHint,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    task,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
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
