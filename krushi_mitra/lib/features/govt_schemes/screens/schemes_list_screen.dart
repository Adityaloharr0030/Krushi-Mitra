import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'scheme_detail_screen.dart';
import '../../../data/models/scheme_model.dart';

class SchemesListScreen extends StatefulWidget {
  const SchemesListScreen({super.key});

  @override
  State<SchemesListScreen> createState() => _SchemesListScreenState();
}

class _SchemesListScreenState extends State<SchemesListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final List<String> _filters = ['All', 'Central', 'Subsidy', 'Pension', 'Insurance'];

  // Original Government Schemes Data (Populated with real Indian schemes)
  final List<Scheme> _originalSchemes = [
    Scheme(
      id: '1',
      name: 'PM-Kisan Samman Nidhi',
      description: 'Income support of ₹6,000/- per year in three equal installments to all land holding farmer families.',
      ministryLogo: 'https://pmkisan.gov.in/images/logo.png',
      deadline: DateTime.now().add(const Duration(days: 3)),
      benefitAmount: '₹6,000 / year',
      eligibilityCriteria: ['Small & marginal farmers', 'Landholding citizens', 'Not paying income tax'],
      requiredDocuments: ['Aadhaar Card', 'Bank Passbook', 'Land Ownership Details'],
      howToApply: '1. Visit pmkisan.gov.in\n2. Click on New Farmer Registration\n3. Enter Aadhaar and Bank details',
      websiteLink: 'https://pmkisan.gov.in',
      applyLink: 'https://pmkisan.gov.in',
      helplineNumber: '155261',
    ),
    Scheme(
      id: '2',
      name: 'PM Fasal Bima Yojana (PMFBY)',
      description: 'Comprehensive crop insurance against non-preventable natural risks from pre-sowing to post-harvest.',
      ministryLogo: 'https://pmfby.gov.in/images/logo.png',
      deadline: DateTime.now().add(const Duration(days: 15)),
      benefitAmount: 'Variable Coverage',
      eligibilityCriteria: ['All farmers growing notified crops in notified areas'],
      requiredDocuments: ['Aadhaar Card', 'Sowing Certificate', 'Land Records'],
      howToApply: 'Apply via CSC centers or directly on the PMFBY portal.',
      websiteLink: 'https://pmfby.gov.in',
      applyLink: 'https://pmfby.gov.in/farmerRegistrationForm',
      helplineNumber: '14447',
    ),
    Scheme(
      id: '3',
      name: 'Soil Health Card Scheme',
      description: 'Provides information to farmers on nutrient status of their soil along with recommendations on appropriate dosage of nutrients.',
      ministryLogo: 'https://soilhealth.dac.gov.in/images/logo.png',
      deadline: DateTime.now().add(const Duration(days: 365)),
      benefitAmount: 'Free Soil Testing',
      eligibilityCriteria: ['All farmers across the country'],
      requiredDocuments: ['Aadhaar Card', 'Soil Sample'],
      howToApply: 'Contact local Agriculture Officer or visit soilhealth.dac.gov.in',
      websiteLink: 'https://soilhealth.dac.gov.in',
      applyLink: 'https://soilhealth.dac.gov.in/farmer-registration',
      helplineNumber: '1800-180-1551',
    ),
    Scheme(
      id: '4',
      name: 'Kisan Credit Card (KCC)',
      description: 'Provides adequate and timely credit support from the banking system for agriculture and other allied activities.',
      ministryLogo: 'https://www.rbi.org.in/images/logo.png',
      deadline: DateTime.now().add(const Duration(days: 90)),
      benefitAmount: 'Up to ₹3 Lakh Credit',
      eligibilityCriteria: ['All farmers - individuals/joint borrowers', 'Tenant farmers', 'Oral lessees'],
      requiredDocuments: ['Aadhaar Card', 'Land Documents', 'Passport size photo'],
      howToApply: 'Visit your nearest bank branch or apply via the PM-Kisan portal.',
      websiteLink: 'https://www.myscheme.gov.in/schemes/kcc',
      applyLink: 'https://www.myscheme.gov.in/schemes/kcc',
      helplineNumber: '1800-11-5526',
    ),
    Scheme(
      id: '5',
      name: 'PM Krishi Sinchayee Yojana',
      description: 'Focuses on "Har Khet Ko Pani" and "Per Drop More Crop" for irrigation efficiency.',
      ministryLogo: 'https://pmksy.gov.in/images/logo.png',
      deadline: DateTime.now().add(const Duration(days: 60)),
      benefitAmount: 'Up to 80% Subsidy on Drip',
      eligibilityCriteria: ['Farmers with valid land records', 'SHGs', 'Cooperatives'],
      requiredDocuments: ['Aadhaar Card', 'Drip/Sprinkler Invoice', 'Land Map'],
      howToApply: 'Apply on the State Agriculture Department portal or via District Office.',
      websiteLink: 'https://pmksy.gov.in',
      applyLink: 'https://www.myscheme.gov.in/schemes/pmksy',
      helplineNumber: '1800-180-1551',
    ),
    Scheme(
      id: '6',
      name: 'Paramparagat Krishi Vikas Yojana',
      description: 'Promotes organic farming through a cluster approach and PGS (Participatory Guarantee System) certification.',
      ministryLogo: 'https://pgsindia-ncof.gov.in/images/logo.png',
      deadline: DateTime.now().add(const Duration(days: 45)),
      benefitAmount: '₹50,000 / ha (3 years)',
      eligibilityCriteria: ['Groups of 20 or more farmers', 'Willingness to adopt organic practices'],
      requiredDocuments: ['Aadhaar Card', 'Land Map', 'Group Resolution'],
      howToApply: 'Register on the Jaivikkheti portal or via local Regional Council.',
      websiteLink: 'https://www.jaivikkheti.in',
      applyLink: 'https://www.jaivikkheti.in',
      helplineNumber: '0120-2764906',
    ),
    Scheme(
      id: '7',
      name: 'PM Kisan Maandhan Yojana',
      description: 'A voluntary and contributory pension scheme for small and marginal farmers to ensure social security.',
      ministryLogo: 'https://maandhan.in/images/logo.png',
      deadline: DateTime.now().add(const Duration(days: 120)),
      benefitAmount: '₹3,000 Monthly Pension',
      eligibilityCriteria: ['Age 18-40 years', 'Small and Marginal farmers with land up to 2 hectares'],
      requiredDocuments: ['Aadhaar Card', 'Savings Bank Account', 'Kisan Card'],
      howToApply: 'Enroll at nearest Common Service Center (CSC) or self-enroll on maandhan.in',
      websiteLink: 'https://maandhan.in',
      applyLink: 'https://pmkmy.gov.in',
      helplineNumber: '1800-267-6888',
    ),
  ];

  List<Scheme> _schemes = [];
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadPersistedSchemes();
  }

  Future<void> _loadPersistedSchemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('saved_govt_schemes');
      if (savedData != null) {
        final List decoded = json.decode(savedData);
        setState(() {
          _schemes = decoded.map((e) => Scheme.fromJson(e as Map<String, dynamic>)).toList();
        });
        
        final lastSyncStr = prefs.getString('last_schemes_sync_time');
        if (lastSyncStr != null) {
          final lastSync = DateTime.parse(lastSyncStr);
          if (DateTime.now().difference(lastSync).inHours >= 24) {
            _syncSchemesViaAI(quiet: true);
          }
        } else {
          _syncSchemesViaAI(quiet: true);
        }
      } else {
        setState(() {
          _schemes = List.from(_originalSchemes);
        });
        _syncSchemesViaAI(quiet: true);
      }
    } catch (e) {
      setState(() {
        _schemes = List.from(_originalSchemes);
      });
    }
  }

  Future<void> _saveSchemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _schemes.map((e) => e.toJson()).toList();
      await prefs.setString('saved_govt_schemes', json.encode(jsonList));
    } catch (_) {}
  }

  Future<void> _syncSchemesViaAI({bool quiet = false}) async {
    if (!quiet) setState(() => _isSyncing = true);
    try {
      final aiSchemes = await AIService().getAIGovtSchemes('en');
      if (aiSchemes.isNotEmpty) {
        if (mounted) {
          setState(() {
            final Map<String, Scheme> uniqueSchemes = {};
            for (var s in _originalSchemes) {
              uniqueSchemes[s.name.toLowerCase()] = s;
            }
            for (var s in aiSchemes) {
              uniqueSchemes[s.name.toLowerCase()] = s;
            }
            _schemes = uniqueSchemes.values.toList();
          });
        }
        await _saveSchemes();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_schemes_sync_time', DateTime.now().toIso8601String());
        
        if (!quiet && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✨ Schemes synced and updated successfully via AI!')),
          );
        }
      } else {
        if (!quiet && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not fetch new schemes. Using cached version.')),
          );
        }
      }
    } catch (e) {
      if (!quiet && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error syncing: $e')),
        );
      }
    } finally {
      if (mounted && !quiet) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Official Govt Schemes',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: _isSyncing 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.smart_toy_rounded, color: Colors.white),
            tooltip: 'Sync Schemes via AI',
            onPressed: _isSyncing ? null : _syncSchemesViaAI,
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.celestialGradient,
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search official schemes...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryEmerald),
          filled: true,
          fillColor: AppColors.surfaceWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              selectedColor: AppColors.primaryEmerald.withValues(alpha: 0.15),
              labelStyle: GoogleFonts.plusJakartaSans(
                color: isSelected ? AppColors.primaryEmerald : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: AppColors.surfaceWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryEmerald : AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = filter);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchemeList() {
    final filteredSchemes = _schemes.where((scheme) {
      final matchesSearch = scheme.name.toLowerCase().contains(_searchQuery) ||
          scheme.description.toLowerCase().contains(_searchQuery);
      
      bool matchesFilter = true;
      if (_selectedFilter == 'Subsidy') {
        matchesFilter = scheme.description.toLowerCase().contains('subsidy') || 
                        scheme.benefitAmount.toLowerCase().contains('subsidy');
      } else if (_selectedFilter == 'Pension') {
        matchesFilter = scheme.name.toLowerCase().contains('pension') || 
                        scheme.name.toLowerCase().contains('maandhan');
      } else if (_selectedFilter == 'Insurance') {
        matchesFilter = scheme.name.toLowerCase().contains('insurance') || 
                        scheme.name.toLowerCase().contains('bima');
      } else if (_selectedFilter == 'Central') {
        matchesFilter = scheme.name.startsWith('PM');
      }

      return matchesSearch && matchesFilter;
    }).toList();

    return RefreshIndicator(
      color: AppColors.primaryEmerald,
      onRefresh: () => _syncSchemesViaAI(),
      child: filteredSchemes.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: AppColors.outlineVariant),
                      const SizedBox(height: 16),
                      Text(
                        'No schemes found',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pull down to refresh and fetch latest schemes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: filteredSchemes.length,
              itemBuilder: (context, index) {
                final scheme = filteredSchemes[index];
                final daysLeft = scheme.deadline.difference(DateTime.now()).inDays;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SchemeDetailScreen(scheme: scheme),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.assured_workload_rounded, size: 32, color: AppColors.primaryEmerald),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scheme.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      scheme.benefitAmount,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.primaryEmerald,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
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
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, 
                              color: AppColors.textSecondary,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: (daysLeft <= 7 ? AppColors.error : AppColors.primaryEmerald).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: (daysLeft <= 7 ? AppColors.error : AppColors.primaryEmerald).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  'Deadline: $daysLeft days left',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: daysLeft <= 7 ? AppColors.error : AppColors.primaryEmerald,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.primaryEmerald.withValues(alpha: 0.5)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
