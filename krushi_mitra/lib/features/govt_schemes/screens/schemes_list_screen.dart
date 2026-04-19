import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
      backgroundColor: AppColors.backgroundStone,
      appBar: AppBar(
        title: const Text('Government Schemes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const SizedBox(height: 16),
          Expanded(child: _buildSchemeList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search schemes...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.surfaceWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = filter);
                }
              },
              backgroundColor: AppColors.surfaceWhite,
              selectedColor: AppColors.primaryGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide.none),
              showCheckmark: false,
              elevation: 0,
              pressElevation: 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchemeList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _mockSchemes.length,
      itemBuilder: (context, index) {
        final scheme = _mockSchemes[index];
        final daysLeft = scheme.deadline.difference(DateTime.now()).inDays;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(32),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SchemeDetailScreen(scheme: scheme)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                        child: const Icon(Icons.account_balance_outlined, color: AppColors.primaryGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scheme.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              scheme.benefitAmount,
                              style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    scheme.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: daysLeft <= 7 ? Colors.orange.withOpacity(0.1) : AppColors.backgroundStone,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$daysLeft days left to apply',
                          style: TextStyle(
                            color: daysLeft <= 7 ? Colors.orange : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.textHint),
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
