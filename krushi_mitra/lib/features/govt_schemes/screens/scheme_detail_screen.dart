import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/scheme_model.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/providers/smart_context_provider.dart';

// ignore_for_file: use_build_context_synchronously
class SchemeDetailScreen extends ConsumerStatefulWidget {
  final Scheme scheme;

  const SchemeDetailScreen({super.key, required this.scheme});

  @override
  ConsumerState<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends ConsumerState<SchemeDetailScreen> {
  bool _isAnalyzing = false;

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch link')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _checkEligibility() async {
    setState(() => _isAnalyzing = true);
    
    try {
      final contextData = ref.read(ubiquitousContextProvider);
      
      final schemeData = {
        'name': widget.scheme.name,
        'eligibility': widget.scheme.eligibilityCriteria.join(', '),
        'benefit': widget.scheme.benefitAmount,
      };

      final response = await AIService().checkSchemeEligibility(
        contextData,
        schemeData,
      );

      if (mounted) {
        _showAIResponse(response);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showAIResponse(String response) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_rounded, color: AppColors.primaryEmerald),
                  const SizedBox(width: 12),
                  Text(
                    'AI Eligibility Analysis',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Text(
                  response,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Scheme Details',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.celestialGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 24),
            _buildEligibilityChecker(context),
            const SizedBox(height: 24),
            _buildSection(context, 'About this Scheme', widget.scheme.description),
            _buildListSection(context, 'Eligibility Criteria', widget.scheme.eligibilityCriteria),
            _buildListSection(context, 'Required Documents', widget.scheme.requiredDocuments),
            _buildSection(context, 'How to Apply', widget.scheme.howToApply),
            const SizedBox(height: 32),
            
            // ACTION BUTTONS
            _buildActionButtons(),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FloatingActionButton.extended(
          onPressed: _isAnalyzing ? null : _checkEligibility,
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: _isAnalyzing ? null : AppTheme.celestialGradient,
              color: _isAnalyzing ? AppColors.outlineVariant : null,
              borderRadius: BorderRadius.circular(32),
              boxShadow: _isAnalyzing ? [] : [
                BoxShadow(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _isAnalyzing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  _isAnalyzing ? 'Analyzing Profile...' : 'Check My Eligibility',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryEmerald.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _launchUrl(widget.scheme.applyLink),
            icon: const Icon(Icons.bolt_rounded, color: Colors.white),
            label: Text(
              'DIRECT APPLY NOW',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, 
                fontWeight: FontWeight.w900, 
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl(widget.scheme.websiteLink),
                icon: const Icon(Icons.language_rounded, color: AppColors.primaryEmerald, size: 20),
                label: Text(
                  'Portal',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.primaryEmerald),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryEmerald, width: 2),
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl('tel:${widget.scheme.helplineNumber}'),
                icon: const Icon(Icons.headset_mic_rounded, color: AppColors.accentAmber, size: 20),
                label: Text(
                  'Helpline',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.accentAmber),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accentAmber, width: 2),
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(32),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.account_balance_rounded, size: 40, color: AppColors.primaryEmerald),
          ),
          const SizedBox(height: 24),
          Text(
            widget.scheme.name,
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Benefit: ${widget.scheme.benefitAmount}',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryEmerald),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityChecker(BuildContext context) {
    const statusColor = AppColors.neonCyan;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Eligibility Check',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the button below for a personalized, AI-driven eligibility analysis based on your farm profile.',
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
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          const SizedBox(height: 12),
          Text(
            content, 
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppTheme.celestialGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildListSection(BuildContext context, String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppColors.primaryEmerald, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item, 
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)
                  )
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
