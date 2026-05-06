import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/screens/main_screen.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/farmer_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/loading_widget.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  final _landSizeController = TextEditingController();
  final _cropsController = TextEditingController();
  
  String? _selectedState;
  String? _selectedSoilType;
  String? _selectedIrrigation;
  File? _imageFile;
  bool _isUploading = false;

  final _storage = StorageService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  final List<String> _states = [
    'Maharashtra', 'Gujarat', 'Punjab', 'Tamil Nadu', 'Karnataka', 'Andhra Pradesh', 'Uttar Pradesh'
  ];

  final List<String> _soilTypes = ['Black', 'Red', 'Alluvial', 'Sandy', 'Loamy', 'Laterite'];
  final List<String> _irrigationSources = ['Well', 'Borewell', 'Canal', 'Rainfed', 'River'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. First check if we already have a loaded profile in the provider
      final existingProfile = ref.read(currentUserProvider).value;
      if (existingProfile != null) {
        debugPrint("ProfileSetup: Pre-filling with existing data");
        setState(() {
          _nameController.text = existingProfile.name;
          _districtController.text = existingProfile.district;
          _landSizeController.text = existingProfile.landSize.toString();
          _cropsController.text = existingProfile.cropsGrown.join(', ');
          _selectedState = existingProfile.state;
          _selectedSoilType = existingProfile.soilType;
          _selectedIrrigation = existingProfile.irrigationSource;
        });
      } else {
        // 2. Fallback to Firebase Auth display name if new profile
        final user = ref.read(authServiceProvider).currentUser;
        if (user != null && user.displayName != null && _nameController.text.isEmpty) {
          setState(() {
            _nameController.text = user.displayName!;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    _landSizeController.dispose();
    _cropsController.dispose();
    super.dispose();
  }

  void _finishSetup() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    if (_nameController.text.isNotEmpty && _selectedState != null && _landSizeController.text.isNotEmpty) {
      setState(() => _isUploading = true);
      
      final existingProfile = ref.read(currentUserProvider).value;
      String? photoUrl = existingProfile?.photoUrl ?? user.photoURL;

      if (_imageFile != null) {
        photoUrl = await _storage.uploadProfilePic(user.uid, _imageFile!);
      }

      final farmer = Farmer(
        id: user.uid,
        name: _nameController.text.trim(),
        photoUrl: photoUrl,
        state: _selectedState!,
        district: _districtController.text.isNotEmpty ? _districtController.text.trim() : 'Nashik',
        landSize: double.tryParse(_landSizeController.text) ?? 2.5,
        cropsGrown: _cropsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        preferredLanguage: 'en',
        soilType: _selectedSoilType,
        irrigationSource: _selectedIrrigation,
      );

      await ref.read(profileActionProvider.notifier).saveProfile(farmer);

      if (mounted) {
        setState(() => _isUploading = false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required details')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingProfile = ref.watch(currentUserProvider).value;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Farmer Profile', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.celestialGradient)),
      ),
      body: _isUploading 
        ? const Center(child: LoadingWidget(message: 'Uploading profile...'))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.3), width: 4),
                          boxShadow: [
                            BoxShadow(color: AppColors.primaryEmerald.withValues(alpha: 0.1), blurRadius: 12, spreadRadius: 4),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: AppColors.surfaceObsidian,
                          backgroundImage: (_imageFile != null 
                            ? FileImage(_imageFile!) 
                            : (existingProfile?.photoUrl != null && existingProfile!.photoUrl!.isNotEmpty
                                ? NetworkImage(existingProfile!.photoUrl!) 
                                : null)) as ImageProvider?,
                          child: (_imageFile == null && (existingProfile?.photoUrl == null || existingProfile!.photoUrl!.isEmpty)) 
                            ? Icon(Icons.person_rounded, size: 60, color: AppColors.textSecondary)
                            : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryEmerald,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
            _buildSectionTitle('BASIC INFORMATION'),
            const SizedBox(height: 16),
            _buildTextField(_nameController, 'Full Name', Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildStateDropdown(),
            const SizedBox(height: 16),
            _buildTextField(_districtController, 'District', Icons.location_city_outlined),
            
            const SizedBox(height: 32),
            _buildSectionTitle('FARM DETAILS'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(_landSizeController, 'Land Size (Acres)', Icons.square_foot_rounded, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildSoilDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            _buildIrrigationDropdown(),
            const SizedBox(height: 16),
            _buildTextField(_cropsController, 'Crops Grown (e.g. Wheat, Onion)', Icons.grass_rounded),
            
            const SizedBox(height: 48),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TELL US ABOUT YOUR FARM',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primaryEmerald,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personalize Your Experience',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.primaryEmerald, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textSecondary, letterSpacing: 1.0),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: AppColors.surfaceWhite,
      ),
    );
  }

  Widget _buildStateDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select State', prefixIcon: const Icon(Icons.map_outlined), filled: true, fillColor: AppColors.surfaceWhite),
      value: _selectedState,
      items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => _selectedState = v),
    );
  }

  Widget _buildSoilDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Soil Type', prefixIcon: const Icon(Icons.terrain_rounded), filled: true, fillColor: AppColors.surfaceWhite),
      value: _selectedSoilType,
      items: _soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => _selectedSoilType = v),
    );
  }

  Widget _buildIrrigationDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Irrigation Source', prefixIcon: const Icon(Icons.water_drop_rounded), filled: true, fillColor: AppColors.surfaceWhite),
      value: _selectedIrrigation,
      items: _irrigationSources.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => _selectedIrrigation = v),
    );
  }

  Widget _buildSubmitButton() {
    final isLoading = ref.watch(profileActionProvider).isLoading;
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryEmerald.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _finishSetup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isLoading ? null : AppTheme.celestialGradient,
            color: isLoading ? AppColors.textHint : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Save Profile & Continue', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
