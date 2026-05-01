import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/screens/main_screen.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/farmer_model.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  String? _selectedState;
  final List<String> _states = [
    'Maharashtra', 'Gujarat', 'Punjab', 'Tamil Nadu', 'Karnataka', 'Andhra Pradesh', 'Uttar Pradesh'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _finishSetup() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    if (_nameController.text.isNotEmpty && _selectedState != null) {
      final farmer = Farmer(
        id: user.uid,
        name: _nameController.text.trim(),
        photoUrl: user.photoURL,
        state: _selectedState!,
        district: _districtController.text.isNotEmpty ? _districtController.text.trim() : 'Nashik',
        landSize: 2.5,
        cropsGrown: ['Wheat', 'Onion'],
        preferredLanguage: 'en',
      );

      // Save to Firestore via provider
      await ref.read(profileActionProvider.notifier).saveProfile(farmer);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'TELL US ABOUT YOURSELF',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primaryEmerald,
                letterSpacing: 3.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Personalize Your Experience',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This helps Krushi Mitra provide personalized AI advice, weather alerts, and localized market schemes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 24),
            
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select State',
                prefixIcon: Icon(Icons.map_outlined),
              ),
              value: _selectedState,
              items: _states.map((state) {
                return DropdownMenuItem(
                  value: state,
                  child: Text(state),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                });
              },
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: 'District (Optional)',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 48),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: ref.watch(profileActionProvider).isLoading ? null : _finishSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  disabledBackgroundColor: AppColors.textHint,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: ref.watch(profileActionProvider).isLoading 
                      ? null 
                      : AppTheme.celestialGradient,
                    color: ref.watch(profileActionProvider).isLoading ? AppColors.textHint : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    child: ref.watch(profileActionProvider).isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Start Your Journey',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ),
            ),
            
            // Error feedback
            if (ref.watch(profileActionProvider).hasError)
              Padding(
                padding: const Offset(0, 16).direction == 0 ? const EdgeInsets.only(top: 16) : const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: ${ref.watch(profileActionProvider).error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
