import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../data/models/scheme_model.dart';

class SchemeDetailScreen extends StatelessWidget {
  final Scheme scheme;

  const SchemeDetailScreen({super.key, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scheme.name),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
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
            _buildSection(context, 'About this Scheme', scheme.description),
            _buildListSection(context, 'Eligibility Criteria', scheme.eligibilityCriteria),
            _buildListSection(context, 'Required Documents', scheme.requiredDocuments),
            _buildSection(context, 'How to Apply', scheme.howToApply),
            const SizedBox(height: 100), // padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Open AI Chat filled with context
        },
        backgroundColor: AppColors.secondaryAmber,
        icon: const Icon(Icons.smart_toy, color: Colors.white),
        label: const Text('Ask AI about this', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.account_balance, size: 48, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            Text(
              scheme.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Benefit: ${scheme.benefitAmount}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityChecker(BuildContext context) {
    // Mocking an eligible status for demonstration
    const isEligible = true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEligible ? AppColors.surfaceGreenLight : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isEligible ? AppColors.primaryGreen : AppColors.error),
      ),
      child: Row(
        children: [
          const Icon(
            isEligible ? Icons.check_circle : Icons.warning,
            color: isEligible ? AppColors.primaryGreen : AppColors.error,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eligibility Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isEligible ? AppColors.primaryGreen : AppColors.error,
                  ),
                ),
                Text(
                  isEligible 
                      ? 'Based on your profile, you are likely eligible for this scheme.'
                      : 'You might not meet all criteria based on your profile.',
                  style: Theme.of(context).textTheme.bodyMedium,
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
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildListSection(BuildContext context, String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyLarge)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
