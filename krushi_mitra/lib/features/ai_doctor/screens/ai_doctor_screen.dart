import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/ai_doctor_provider.dart';
import '../../../core/services/ai_service.dart';

class AIDoctorScreen extends ConsumerStatefulWidget {
  const AIDoctorScreen({super.key});

  @override
  ConsumerState<AIDoctorScreen> createState() => _AIDoctorScreenState();
}

class _AIDoctorScreenState extends ConsumerState<AIDoctorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiDoctorProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Upload a photo to diagnose your crop',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCameraHero(aiState),
                  const SizedBox(height: 24),
                  if (aiState.diagnosis != null) ...[
                    _buildDiagnosisResult(aiState.diagnosis!),
                    const SizedBox(height: 24),
                    _buildTreatmentTabs(aiState.diagnosis!),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ] else if (aiState.isLoading) ...[
                    _buildLoadingResult(),
                  ],
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          '🤖 AI Crop Doctor',
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
              colors: [Color(0xFF1B5E20), Color(0xFF0D1F12)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraHero(AIDoctorState state) {
    return GestureDetector(
      onTap: () => ref.read(aiDoctorProvider.notifier).pickImage(ImageSource.camera),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          image: state.selectedImage != null
              ? DecorationImage(
                  image: FileImage(state.selectedImage!),
                  fit: BoxFit.cover,
                )
              : const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?q=80&w=1000&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: state.selectedImage != null ? 0 : 5, sigmaY: state.selectedImage != null ? 0 : 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.selectedImage == null) ...[
                  const Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to take photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 1, width: 40, color: AppColors.outlineVariant),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR', style: GoogleFonts.manrope(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ),
                      Container(height: 1, width: 40, color: AppColors.outlineVariant),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSecondaryButton('📁 Browse Gallery', () => ref.read(aiDoctorProvider.notifier).pickImage(ImageSource.gallery)),
                ] else if (state.isLoading) ...[
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text('Analyzing crop...', style: GoogleFonts.manrope(color: Colors.white)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisResult(CropDiagnosis diagnosis) {
    final sev = diagnosis.severity.toLowerCase();
    final severityColor = sev.contains('high') || sev.contains('severe')
        ? const Color(0xFFC62828)
        : sev.contains('medium')
            ? const Color(0xFFE67E22)
            : const Color(0xFF2E7D32);

    final statusEmoji = diagnosis.isHealthy ? '✅' : '⚠️';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [severityColor, severityColor.withOpacity(0.7)]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(statusEmoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diagnosis.diseaseName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Crop: ${diagnosis.cropName}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  diagnosis.symptoms,
                  style: GoogleFonts.manrope(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(
                      'Confidence: ${diagnosis.confidencePercent.round()}% 🎯',
                      AppColors.surfaceContainerHighest,
                      AppColors.onSurface,
                    ),
                    _buildChip(
                      diagnosis.severity.toUpperCase(),
                      severityColor.withOpacity(0.2),
                      severityColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('AI is diagnosing your crop...', style: GoogleFonts.manrope(color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTreatmentTabs(CropDiagnosis diagnosis) {
    return Column(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.onPrimary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 14),
            tabs: const [
              Tab(text: 'Organic'),
              Tab(text: 'Chemical'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrganicTab(diagnosis),
              _buildChemicalTab(diagnosis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrganicTab(CropDiagnosis diagnosis) {
    final suggestions = diagnosis.treatmentOrganic
        .split(RegExp(r'[\n•-]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return SingleChildScrollView(
      child: Column(
        children: [
          ...suggestions.map((s) => _buildTreatmentItem('🌿 $s')).toList(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00695C).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4DB6AC).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFF4DB6AC), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prevention: ${diagnosis.prevention}',
                    style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFFB2DFDB)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChemicalTab(CropDiagnosis diagnosis) {
    final suggestions = diagnosis.treatmentChemical
        .split(RegExp(r'[\n•-]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return SingleChildScrollView(
      child: Column(
        children: [
          ...suggestions.map((s) => _buildTreatmentItem('🧪 $s')).toList(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4A0000).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEF9A9A).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF9A9A), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Causes: ${diagnosis.causes}',
                    style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFFFFCDD2)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.manrope(fontSize: 14, color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: AppColors.tertiary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.share_outlined, size: 20),
              SizedBox(width: 8),
              Text('Share Report'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(color: AppColors.outlineVariant),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: Text(
            '💬 Ask AI More',
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
