import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../data/models/scheme_model.dart';

class SchemeDetailScreen extends StatelessWidget {
  final Scheme scheme;

  const SchemeDetailScreen({super.key, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStone,
      appBar: AppBar(
        title: const Text('Scheme Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderHero(context),
            const SizedBox(height: 32),
            _buildEligibilityStatus(context),
            const SizedBox(height: 40),
            _buildEditorialSection(context, 'About this Scheme', scheme.description, Icons.info_outline),
            _buildListSection(context, 'Eligibility Criteria', scheme.eligibilityCriteria, Icons.person_outline),
            _buildListSection(context, 'Required Documents', scheme.requiredDocuments, Icons.description_outlined),
            _buildEditorialSection(context, 'How to Apply', scheme.howToApply, Icons.play_circle_outlined),
            const SizedBox(height: 120),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.auto_awesome_outlined, color: Colors.white),
        label: const Text('Verify with AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeaderHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.account_balance_outlined, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            scheme.name,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Benefit: ${scheme.benefitAmount}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityStatus(BuildContext context) {
    const isEligible = true;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isEligible ? AppColors.surfaceWhite : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            isEligible ? Icons.check_circle_rounded : Icons.info_rounded,
            color: isEligible ? AppColors.primaryGreen : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEligible ? 'Likely Eligible' : 'Check Criteria',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  isEligible 
                      ? 'Based on your farm profile, you can apply now.'
                      : 'You might need additional documentation.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorialSection(BuildContext context, String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: TextStyle(color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildListSection(BuildContext context, String title, List<String> items, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 6, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(item, style: TextStyle(color: AppColors.textSecondary))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
