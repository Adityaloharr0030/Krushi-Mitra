import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
      backgroundColor: AppColors.backgroundStone,
      appBar: AppBar(
        title: const Text('Crop Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Soybean (JS 335)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                    Text('Kharif Season', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Change', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
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
            width: 80,
            child: Column(
              children: [
                if (!isFirst) Container(height: 20, width: 2, color: isActive ? AppColors.primaryGreen : AppColors.divider),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryGreen : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    month,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: isActive ? AppColors.primaryGreen : AppColors.divider)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(32),
                  border: isActive ? Border.all(color: AppColors.primaryGreen.withOpacity(0.3), width: 1) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(phase, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    ...tasks.map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(task, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4))),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
