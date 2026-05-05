import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/ai_doctor_provider.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/providers/weather_provider.dart';
import '../../../core/providers/smart_context_provider.dart';

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
                  const _SmartWeatherAlert(),
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
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'AI Crop Doctor',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.celestialGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(Icons.psychology_outlined, size: 150, color: Colors.white.withValues(alpha: 0.1)),
              ),
            ],
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
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          image: state.selectedImage != null
              ? DecorationImage(
                  image: FileImage(state.selectedImageFile!),
                  fit: BoxFit.cover,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: state.selectedImage != null ? 0 : 0, sigmaY: state.selectedImage != null ? 0 : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.selectedImage == null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_rounded, size: 48, color: AppColors.primaryEmerald),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Capture Crop Image',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diagnose diseases instantly with AI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSecondaryButton('📁 Pick from Gallery', () => ref.read(aiDoctorProvider.notifier).pickImage(ImageSource.gallery)),
                ] else if (state.isLoading) ...[
                  const CircularProgressIndicator(color: AppColors.primaryEmerald),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing Image...',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)],
                    ),
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryEmerald.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.2)),
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryEmerald,
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisResult(CropDiagnosis diagnosis) {
    final sev = diagnosis.severity.toLowerCase();
    final severityColor = sev.contains('high') || sev.contains('severe')
        ? AppColors.error
        : sev.contains('medium')
            ? AppColors.accentAmber
            : AppColors.success;

    final statusEmoji = diagnosis.isHealthy ? '✅' : '⚠️';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: severityColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(statusEmoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diagnosis.diseaseName,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Detected in: ${diagnosis.cropName}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  diagnosis.symptoms,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, 
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildChip(
                      '${diagnosis.confidencePercent.round()}% Confidence',
                      AppColors.primaryEmerald.withValues(alpha: 0.1),
                      AppColors.primaryEmerald,
                    ),
                    const SizedBox(width: 10),
                    _buildChip(
                      diagnosis.severity.toUpperCase(),
                      severityColor.withValues(alpha: 0.1),
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
          height: 56,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppTheme.celestialGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
            tabs: const [
              Tab(text: 'Organic Solution'),
              Tab(text: 'Chemical Control'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 240,
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
          ...suggestions.map((s) => _buildTreatmentItem('🌿 $s')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00695C).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4DB6AC).withValues(alpha: 0.3)),
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
          ...suggestions.map((s) => _buildTreatmentItem('🧪 $s')),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4A0000).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEF9A9A).withValues(alpha: 0.3)),
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
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share_rounded, size: 20),
          label: Text('Share Full Report', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: AppColors.primaryEmerald,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
          label: Text('Ask AI More Questions', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            foregroundColor: AppColors.primaryEmerald,
            side: const BorderSide(color: AppColors.primaryEmerald, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }
}

class _SmartWeatherAlert extends ConsumerWidget {
  const _SmartWeatherAlert();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextData = ref.watch(ubiquitousContextProvider);

    return contextData.weather != null ? FutureBuilder<String>(
      future: AIService().getWeatherAnalysis(contextData),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Text('☁️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIVE WEATHER CONTEXT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentAmber,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snapshot.data!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ) : const SizedBox.shrink();
  }
}
