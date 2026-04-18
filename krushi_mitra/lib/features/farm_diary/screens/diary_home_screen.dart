import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class FarmDiaryScreen extends StatefulWidget {
  const FarmDiaryScreen({super.key});

  @override
  State<FarmDiaryScreen> createState() => _FarmDiaryScreenState();
}

class _FarmDiaryScreenState extends State<FarmDiaryScreen> {
  final List<Map<String, dynamic>> _entries = [
    {'date': '15 Apr 2026', 'activity': 'Urea Application', 'category': 'Fertilizer', 'cost': 1200.0, 'isExpense': true},
    {'date': '12 Apr 2026', 'activity': 'Tractor Rent', 'category': 'Labour', 'cost': 800.0, 'isExpense': true},
    {'date': '10 Apr 2026', 'activity': 'Sold Wheat (5 Qtls)', 'category': 'Income', 'cost': 11500.0, 'isExpense': false},
    {'date': '05 Apr 2026', 'activity': 'Seed Purchase', 'category': 'Seed', 'cost': 2500.0, 'isExpense': true},
  ];

  @override
  Widget build(BuildContext context) {
    double totalIncome = _entries.where((e) => !e['isExpense']).fold(0, (sum, e) => sum + e['cost']);
    double totalExpense = _entries.where((e) => e['isExpense']).fold(0, (sum, e) => sum + e['cost']);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Farm Diary (खेत डायरी)'),
      body: Column(
        children: [
          _buildSummaryCards(totalIncome, totalExpense),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Entries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: entry['isExpense'] ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                    child: Icon(
                      entry['isExpense'] ? Icons.arrow_outward : Icons.south_west,
                      color: entry['isExpense'] ? AppColors.error : AppColors.success,
                    ),
                  ),
                  title: Text(entry['activity'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('\${entry['date']} • \${entry['category']}'),
                  trailing: Text(
                    '\${entry['isExpense'] ? '-' : '+'}₹\${entry['cost']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: entry['isExpense'] ? AppColors.error : AppColors.success,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add entry screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expense) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(title: 'Total Income', amount: income, color: AppColors.success),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(title: 'Total Expense', amount: expense, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryCard({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('₹\$amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
