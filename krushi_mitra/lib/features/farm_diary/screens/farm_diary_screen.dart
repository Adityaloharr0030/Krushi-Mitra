import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/models/farm_diary_model.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../core/providers/smart_context_provider.dart';
import '../../../core/services/ai_service.dart';

class FarmDiaryScreen extends ConsumerStatefulWidget {
  const FarmDiaryScreen({super.key});

  @override
  ConsumerState<FarmDiaryScreen> createState() => _FarmDiaryScreenState();
}

class _FarmDiaryScreenState extends ConsumerState<FarmDiaryScreen> {
  static const _activities = [
    'Sowing Seeds',
    'Fertilizer Application',
    'Pesticide Spraying',
    'Irrigation',
    'Harvesting',
    'Land Preparation',
    'Weeding',
    'Selling Produce',
    'Labour Payment',
    'Other',
  ];

  static const _categories = [
    'Seeds', 'Fertilizer', 'Pesticide', 'Labour', 'Machinery', 'Income', 'Other'
  ];

  void _showAddEntryBottomSheet(String farmerId) {
    String selectedActivity = _activities[0];
    String selectedCategory = _categories[0];
    final costController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isExpense = true;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceObsidian,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 20),
                  Text('📔 New Farm Entry', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 24),
                  
                  // Expense/Income Toggle
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Expense')),
                          selected: isExpense,
                          onSelected: (val) => setModalState(() => isExpense = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Income')),
                          selected: !isExpense,
                          onSelected: (val) => setModalState(() => isExpense = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date Picker
                  _buildPickerTile(
                    icon: Icons.calendar_today_rounded,
                    label: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    onTap: () async {
                      final picked = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                      if (picked != null) setModalState(() => selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown(
                    label: 'Activity',
                    value: selectedActivity,
                    items: _activities,
                    onChanged: (v) => setModalState(() => selectedActivity = v!),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: costController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: isExpense ? 'Cost (₹)' : 'Amount Received (₹)',
                      prefixIcon: const Icon(Icons.currency_rupee_rounded),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final entry = FarmDiaryEntry(
                          id: const Uuid().v4(),
                          farmerId: farmerId,
                          date: selectedDate,
                          activity: selectedActivity,
                          category: selectedCategory,
                          cost: double.tryParse(costController.text) ?? 0,
                          isExpense: isExpense,
                          notes: notesController.text,
                        );
                        await ref.read(databaseServiceProvider).addDiaryEntry(entry);
                        Navigator.pop(ctx);
                      },
                      child: const Text('SAVE ENTRY'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundMidnight,
      body: userAsync.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('Please login to use Diary'));
          
          return StreamBuilder<List<FarmDiaryEntry>>(
            stream: ref.watch(databaseServiceProvider).getDiaryEntries(profile.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: LoadingWidget());
              final entries = snapshot.data ?? [];
              
              return CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildSummaryHeader(entries),
                          const SizedBox(height: 16),
                          _SmartAnalysisCard(entries: entries),
                          const SizedBox(height: 24),
                          if (entries.isEmpty) _buildEmptyState() else _buildEntryList(entries),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: userAsync.maybeWhen(
        data: (profile) => profile != null ? FloatingActionButton.extended(
          onPressed: () => _showAddEntryBottomSheet(profile.id),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Entry'),
          backgroundColor: AppColors.primaryEmerald,
        ) : null,
        orElse: () => null,
      ),
    );
  }


  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      backgroundColor: AppColors.backgroundMidnight,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('Farm Diary', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        background: Container(decoration: BoxDecoration(gradient: AppTheme.luxuryGradient)),
      ),
    );
  }

  Widget _buildSummaryHeader(List<FarmDiaryEntry> entries) {
    final expense = entries.where((e) => e.isExpense).fold(0.0, (sum, e) => sum + e.cost);
    final income = entries.where((e) => !e.isExpense).fold(0.0, (sum, e) => sum + e.cost);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCardDecoration,
      child: Row(
        children: [
          _buildStat('Total Spend', expense, AppColors.error),
          Container(width: 1, height: 40, color: AppColors.outlineVariant),
          _buildStat('Total Income', income, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildStat(String label, double val, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMediumEmphasis, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('₹${val.toInt()}', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.auto_stories_rounded, size: 80, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('No Records Found', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('Start tracking your farm finances.', style: GoogleFonts.plusJakartaSans(color: AppColors.textMediumEmphasis)),
        ],
      ),
    );
  }

  Widget _buildEntryList(List<FarmDiaryEntry> entries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceObsidian,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (e.isExpense ? AppColors.error : AppColors.success).withValues(alpha: 0.1),
              child: Icon(e.isExpense ? Icons.remove_rounded : Icons.add_rounded, color: e.isExpense ? AppColors.error : AppColors.success),
            ),
            title: Text(e.activity, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white)),
            subtitle: Text('${e.date.day}/${e.date.month} • ${e.category}', style: TextStyle(color: AppColors.textMediumEmphasis)),
            trailing: Text('₹${e.cost.toInt()}', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16)),
          ),
        );
      },
    );
  }

  Widget _buildPickerTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundMidnight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryEmerald, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white)),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: AppColors.textMediumEmphasis),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppColors.surfaceObsidian,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}

class _SmartAnalysisCard extends ConsumerWidget {
  final List<FarmDiaryEntry> entries;
  const _SmartAnalysisCard({required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextData = ref.watch(ubiquitousContextProvider);

    return FutureBuilder<String>(
      future: AIService().getDiaryAnalysis(contextData),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: AppColors.primaryEmerald.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMART BUDGET TIP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryEmerald,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snapshot.data!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
}
