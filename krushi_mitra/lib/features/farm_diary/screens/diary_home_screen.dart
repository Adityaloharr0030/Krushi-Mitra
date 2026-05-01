import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class DiaryHomeScreen extends StatefulWidget {
  const DiaryHomeScreen({super.key});

  @override
  State<DiaryHomeScreen> createState() => _DiaryHomeScreenState();
}

class _DiaryHomeScreenState extends State<DiaryHomeScreen> {
  // Empty list for real usage. User adds their own data.
  final List<Map<String, dynamic>> _entries = [];

  @override
  Widget build(BuildContext context) {
    double totalIncome = _entries.where((e) => !e['isExpense']).fold(0, (sum, e) => sum + e['cost']);
    double totalExpense = _entries.where((e) => e['isExpense']).fold(0, (sum, e) => sum + e['cost']);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Farm Diary (खेत डायरी)'),
      body: _entries.isEmpty 
        ? _buildEmptyState() 
        : Column(
            children: [
              _buildSummaryCards(totalIncome, totalExpense),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.backgroundCloud,
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
                        backgroundColor: entry['isExpense'] ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                        child: Icon(
                          entry['isExpense'] ? Icons.arrow_outward : Icons.south_west,
                          color: entry['isExpense'] ? AppColors.error : AppColors.success,
                        ),
                      ),
                      title: Text(entry['activity'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${entry['date']} • ${entry['category']}'),
                      trailing: Text(
                        '${entry['isExpense'] ? '-' : '+'}₹${entry['cost']}',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.note_alt_rounded, size: 80, color: AppColors.primaryEmerald),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Diary is Empty',
            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Record your daily farming expenses\nand income to track your profits.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 12),
          Text(
            '₹${amount.toStringAsFixed(0)}', 
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: color)
          ),
        ],
      ),
    );
  }
}
