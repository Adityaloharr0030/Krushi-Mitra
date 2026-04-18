import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

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
      appBar: const CustomAppBar(title: 'Crop Calendar (फसल कैलेंडर)'),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Soybean (JS 335)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDark)),
                    Text('Kharif Season', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Change Crop'),
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
            width: 80,
            child: Column(
              children: [
                if (!isFirst) Container(height: 20, width: 2, color: isActive ? AppColors.primary : AppColors.divider),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    month,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: isActive ? AppColors.primary : AppColors.divider)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Card(
                elevation: isActive ? 4 : 1,
                color: isActive ? Colors.white : AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isActive ? AppColors.primaryLight : Colors.transparent),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(phase, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      ...tasks.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: Icon(Icons.circle, size: 8, color: AppColors.accent),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(task)),
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
