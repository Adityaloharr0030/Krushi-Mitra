import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FarmDiaryScreen extends StatefulWidget {
  const FarmDiaryScreen({super.key});

  @override
  State<FarmDiaryScreen> createState() => _FarmDiaryScreenState();
}

class _FarmDiaryScreenState extends State<FarmDiaryScreen> {
  final List<DiaryEntry> _entries = [
    DiaryEntry(date: DateTime.now(), activity: 'Spraying Pesticides', crop: 'Onion', cost: 1200),
    DiaryEntry(date: DateTime.now().subtract(const Duration(days: 2)), activity: 'Fertilizer Application', crop: 'Onion', cost: 3500),
    DiaryEntry(date: DateTime.now().subtract(const Duration(days: 5)), activity: 'Sowing Seeds', crop: 'Wheat', cost: 8000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStone,
      appBar: AppBar(
        title: const Text('Farm Diary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCostOverview(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activities',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCostOverview() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seasonal Spend', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('₹12,700', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.white12,
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 32),
          LinearProgressIndicator(
            value: 0.65,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spent: ₹12.7k', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Budget: ₹20k', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: _entries.map((entry) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.backgroundStone,
              child: Icon(
                entry.activity.contains('Spraying') ? Icons.opacity : Icons.eco_outlined,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.activity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${entry.crop} • ${entry.date.day}/${entry.date.month}', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            ),
            Text('₹${entry.cost.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryGreen)),
          ],
        ),
      )).toList(),
    );
  }
}

class DiaryEntry {
  final DateTime date;
  final String activity;
  final String crop;
  final double cost;

  DiaryEntry({required this.date, required this.activity, required this.crop, required this.cost});
}
