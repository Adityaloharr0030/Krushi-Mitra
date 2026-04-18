import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FarmDiaryScreen extends StatefulWidget {
  const FarmDiaryScreen({super.key});

  @override
  State<FarmDiaryScreen> createState() => _FarmDiaryScreenState();
}

class _FarmDiaryScreenState extends State<FarmDiaryScreen> {
  // Mock Crop Lifecycle data
  final String _currentCrop = "Wheat";
  final int _daysSinceSowing = 24;

  final List<Map<String, dynamic>> _activities = [
    {'title': 'Sowing Completed', 'date': '12 Nov 2025', 'icon': Icons.agriculture, 'color': Colors.brown},
    {'title': 'First Irrigation', 'date': '02 Dec 2025', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'title': 'NPK Fertilizer Added', 'date': '05 Dec 2025', 'icon': Icons.science, 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Farm Diary'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActiveCropHeader(),
            const SizedBox(height: 24),
            _buildAITipCard(),
            const SizedBox(height: 24),
            _buildLedgerSummary(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Activity Timeline', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add Activity')),
              ],
            ),
            const SizedBox(height: 16),
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCropHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Crop: $_currentCrop', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: bold)),
              const Icon(Icons.grass, color: AppColors.secondaryAmber, size: 32),
            ],
          ),
          const SizedBox(height: 8),
          Text('Area: 2.5 Acres', style: const TextStyle(color: Colors.white70)),
          Text('Sown: 12 Nov 2025 (Day $_daysSinceSowing)', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _daysSinceSowing / 120, // rough 120 day crop cycle
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryAmber),
          ),
          const SizedBox(height: 8),
          const Center(child: Text('Expected Harvest: Mid-March 2026', style: TextStyle(color: Colors.white, fontWeight: bold))),
        ],
      ),
    );
  }

  Widget _buildAITipCard() {
    return Card(
      color: AppColors.surfaceGreenLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.psychology, color: AppColors.primaryGreen, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This Week\'s AI Focus', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryGreen, fontWeight: bold)),
                  const SizedBox(height: 8),
                  const Text('Your wheat is in the Crown Root Initiation (CRI) stage. Ensure adequate moisture; skip second irrigation if soil is still damp from last week. Watch out for early termite infestation.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Expense Overview (₹)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildExpenseItem('Seeds', '₹3,500'),
                _buildExpenseItem('Fertilizers', '₹2,800'),
                _buildExpenseItem('Labor', '₹1,500'),
              ],
            ),
            const Divider(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Input Cost:', style: TextStyle(fontWeight: bold, fontSize: 16)),
                Text('₹7,800', style: TextStyle(color: AppColors.error, fontWeight: bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Add New Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(String label, String amount) {
    return Column(
      children: [
        Text(amount, style: const TextStyle(fontWeight: bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 20),
                  ),
                  if (index != _activities.length - 1)
                    Container(height: 40, width: 2, color: Colors.grey.shade300),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity['title'] as String, style: const TextStyle(fontWeight: bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(activity['date'] as String, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
const bold = FontWeight.bold;
