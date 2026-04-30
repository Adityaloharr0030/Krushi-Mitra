import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'scheme_detail_screen.dart';
import '../../../data/models/scheme_model.dart';

class SchemesListScreen extends StatefulWidget {
  const SchemesListScreen({super.key});

  @override
  State<SchemesListScreen> createState() => _SchemesListScreenState();
}

class _SchemesListScreenState extends State<SchemesListScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Central', 'State', 'Subsidy', 'Insurance'];

  // Mock Data
  final List<Scheme> _mockSchemes = [
    Scheme(
      id: '1',
      name: 'PM-Kisan Samman Nidhi',
      description: 'Income support of ₹6,000/- per year in three equal installments to all land holding farmer families.',
      ministryLogo: 'https://via.placeholder.com/50',
      deadline: DateTime.now().add(const Duration(days: 3)),
      benefitAmount: '₹6,000 / year',
      eligibilityCriteria: ['Small & marginal farmers', 'Landholding citizens', 'Not paying income tax'],
      requiredDocuments: ['Aadhaar Card', 'Bank Passbook', 'Land Ownership Details'],
      howToApply: '1. Visit pmkisan.gov.in\n2. Click on New Farmer Registration\n3. Enter Aadhaar and Bank details',
      websiteLink: 'https://pmkisan.gov.in',
      helplineNumber: '155261',
    ),
    Scheme(
      id: '2',
      name: 'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
      description: 'Crop insurance scheme integrating multiple stakeholders on a single platform, yielding better efficiency in service delivery.',
      ministryLogo: 'https://via.placeholder.com/50',
      deadline: DateTime.now().add(const Duration(days: 15)),
      benefitAmount: 'Variable Coverage',
      eligibilityCriteria: ['All farmers growing notified crops in notified areas'],
      requiredDocuments: ['Aadhaar Card', 'Sowing Certificate', 'Land Records'],
      howToApply: 'Apply via CSC centers or directly on the PMFBY portal.',
      websiteLink: 'https://pmfby.gov.in',
      helplineNumber: '14447',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Schemes'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildSchemeList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search schemes by keyword...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.surfaceWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              selectedColor: AppColors.secondaryAmber,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchemeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockSchemes.length,
      itemBuilder: (context, index) {
        final scheme = _mockSchemes[index];
        final daysLeft = scheme.deadline.difference(DateTime.now()).inDays;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SchemeDetailScreen(scheme: scheme),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.account_balance, size: 40, color: AppColors.primaryGreen),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scheme.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scheme.benefitAmount,
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    scheme.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: daysLeft <= 7 ? AppColors.error.withValues(alpha: 0.1) : AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: daysLeft <= 7 ? AppColors.error : AppColors.primaryGreen,
                          ),
                        ),
                        child: Text(
                          'Deadline: $daysLeft days left',
                          style: TextStyle(
                            color: daysLeft <= 7 ? AppColors.error : AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
