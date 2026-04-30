import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../../../core/theme/app_colors.dart';

// ─── Data Model ──────────────────────────────────────────────────
class DiaryEntry {
  final int? id;
  final DateTime date;
  final String activity;
  final String crop;
  final double cost;
  final String notes;

  DiaryEntry({
    this.id,
    required this.date,
    required this.activity,
    required this.crop,
    required this.cost,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'activity': activity,
        'crop': crop,
        'cost': cost,
        'notes': notes,
      };

  factory DiaryEntry.fromMap(Map<String, dynamic> map) => DiaryEntry(
        id: map['id'] as int?,
        date: DateTime.parse(map['date'] as String),
        activity: map['activity'] as String,
        crop: map['crop'] as String,
        cost: (map['cost'] as num).toDouble(),
        notes: map['notes'] as String? ?? '',
      );
}

// ─── Database Helper ─────────────────────────────────────────────
class DiaryDatabase {
  static final DiaryDatabase _instance = DiaryDatabase._internal();
  factory DiaryDatabase() => _instance;
  DiaryDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = p.join(await getDatabasesPath(), 'farm_diary.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute(
        '''CREATE TABLE diary_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          activity TEXT NOT NULL,
          crop TEXT NOT NULL,
          cost REAL NOT NULL,
          notes TEXT
        )''',
      ),
    );
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query('diary_entries', orderBy: 'date DESC');
    return maps.map(DiaryEntry.fromMap).toList();
  }

  Future<int> insertEntry(DiaryEntry entry) async {
    final db = await database;
    return db.insert('diary_entries', entry.toMap()..remove('id'));
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
  }
}

// ─── Screen ──────────────────────────────────────────────────────
class FarmDiaryScreen extends StatefulWidget {
  const FarmDiaryScreen({super.key});

  @override
  State<FarmDiaryScreen> createState() => _FarmDiaryScreenState();
}

class _FarmDiaryScreenState extends State<FarmDiaryScreen>
    with SingleTickerProviderStateMixin {
  List<DiaryEntry> _entries = [];
  bool _isLoading = true;
  late AnimationController _totalController;
  late Animation<double> _totalAnimation;
  final double _previousTotal = 0;

  static const _activities = [
    'Sowing Seeds',
    'Fertilizer Application',
    'Pesticide Spraying',
    'Irrigation',
    'Harvesting',
    'Land Preparation',
    'Weeding',
    'Other',
  ];

  static const _crops = [
    'Wheat', 'Rice', 'Cotton', 'Soybean', 'Onion',
    'Tomato', 'Potato', 'Sugarcane', 'Maize', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _totalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _totalAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _totalController, curve: Curves.easeOut),
    );
    _loadEntries();
  }

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final entries = await DiaryDatabase().getAllEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
      _totalController.forward(from: 0);
    }
  }

  double get _totalCost => _entries.fold(0, (sum, e) => sum + e.cost);

  Future<void> _deleteEntry(DiaryEntry entry) async {
    if (entry.id == null) return;
    await DiaryDatabase().deleteEntry(entry.id!);
    setState(() => _entries.removeWhere((e) => e.id == entry.id));
    _totalController.forward(from: 0);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entry deleted', style: GoogleFonts.manrope()),
          backgroundColor: AppColors.surfaceContainerHigh,
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.primary,
            onPressed: () async {
              final restored = await DiaryDatabase().insertEntry(entry);
              await _loadEntries();
            },
          ),
        ),
      );
    }
  }

  void _showAddEntryBottomSheet() {
    String selectedActivity = _activities[0];
    String selectedCrop = _crops[0];
    final costController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '📔 New Diary Entry',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date picker
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.primary,
                              surface: AppColors.surfaceContainer,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: GoogleFonts.manrope(color: AppColors.onSurface, fontSize: 15),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Activity dropdown
                  _buildDropdown<String>(
                    label: 'Activity',
                    value: selectedActivity,
                    items: _activities,
                    onChanged: (v) => setModalState(() => selectedActivity = v!),
                  ),
                  const SizedBox(height: 16),

                  // Crop dropdown
                  _buildDropdown<String>(
                    label: 'Crop',
                    value: selectedCrop,
                    items: _crops,
                    onChanged: (v) => setModalState(() => selectedCrop = v!),
                  ),
                  const SizedBox(height: 16),

                  // Cost field
                  TextFormField(
                    controller: costController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    style: GoogleFonts.manrope(color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Cost (₹)',
                      prefixIcon: Icon(Icons.currency_rupee_rounded, color: AppColors.primary, size: 20),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter cost' : null,
                  ),
                  const SizedBox(height: 16),

                  // Notes field
                  TextFormField(
                    controller: notesController,
                    maxLines: 2,
                    style: GoogleFonts.manrope(color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final entry = DiaryEntry(
                          date: selectedDate,
                          activity: selectedActivity,
                          crop: selectedCrop,
                          cost: double.tryParse(costController.text) ?? 0,
                          notes: notesController.text,
                        );
                        await DiaryDatabase().insertEntry(entry);
                        Navigator.pop(ctx);
                        await _loadEntries();
                      },
                      child: Text(
                        'Save Entry',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
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

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppColors.surfaceContainerHigh,
      style: GoogleFonts.manrope(color: AppColors.onSurface),
      items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString()))).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildCostOverview(),
                        const SizedBox(height: 28),
                        _buildSectionHeader(),
                        const SizedBox(height: 16),
                        if (_entries.isEmpty)
                          _buildEmptyState()
                        else
                          _buildActivityList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryBottomSheet,
        backgroundColor: AppColors.tertiary,
        foregroundColor: AppColors.onTertiary,
        icon: const Icon(Icons.add),
        label: Text(
          'New Entry',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          '📔 Farm Diary',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF006064), Color(0xFF0D1F12)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCostOverview() {
    return AnimatedBuilder(
      animation: _totalAnimation,
      builder: (context, child) {
        final displayTotal = _totalCost * _totalAnimation.value;
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B5E20), Color(0xFF00695C)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seasonal Spend',
                        style: GoogleFonts.manrope(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${displayTotal.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _totalCost > 0 ? (_totalCost / 20000).clamp(0.0, 1.0) : 0,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_entries.length} entries',
                    style: GoogleFonts.manrope(color: Colors.white60, fontSize: 12),
                  ),
                  Text(
                    'Budget: ₹20,000',
                    style: GoogleFonts.manrope(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Activities',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        if (_entries.length > 5)
          TextButton(
            onPressed: _showAllEntriesDialog,
            child: Text(
              'View All',
              style: GoogleFonts.manrope(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No entries yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to record your first farm activity',
              style: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final displayed = _entries.take(10).toList();
    return Column(
      children: displayed.map((entry) => _buildDismissibleEntry(entry)).toList(),
    );
  }

  Widget _buildDismissibleEntry(DiaryEntry entry) {
    return Dismissible(
      key: ValueKey(entry.id ?? entry.date.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => _deleteEntry(entry),
      child: _buildEntryCard(entry),
    );
  }

  Widget _buildEntryCard(DiaryEntry entry) {
    final IconData activityIcon = _getActivityIcon(entry.activity);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(activityIcon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.activity,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.crop} • ${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  style: GoogleFonts.manrope(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (entry.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.notes,
                    style: GoogleFonts.manrope(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            '₹${entry.cost.toInt()}',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAllEntriesDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'All Entries (${_entries.length})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: _entries.length,
                  itemBuilder: (ctx, i) => _buildEntryCard(_entries[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActivityIcon(String activity) {
    if (activity.contains('Sowing')) return Icons.grass_rounded;
    if (activity.contains('Fertilizer')) return Icons.science_rounded;
    if (activity.contains('Pesticide') || activity.contains('Spraying')) return Icons.opacity_rounded;
    if (activity.contains('Irrigation')) return Icons.water_drop_rounded;
    if (activity.contains('Harvesting')) return Icons.agriculture_rounded;
    if (activity.contains('Land')) return Icons.terrain_rounded;
    if (activity.contains('Weeding')) return Icons.eco_rounded;
    return Icons.edit_note_rounded;
  }
}
