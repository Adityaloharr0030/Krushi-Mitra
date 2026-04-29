import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../home/screens/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  String? _selectedState;
  final List<String> _states = [
    'Maharashtra', 'Gujarat', 'Punjab', 'Tamil Nadu', 'Karnataka', 'Andhra Pradesh', 'Uttar Pradesh'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _finishSetup() {
    if (_nameController.text.isNotEmpty && _selectedState != null) {
      // In a real app, save to SharedPreferences / Firestore here
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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
              'Tell us about yourself',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This helps Krushi Mitra provide personalized advice and relevant schemes.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
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

            // In a full implementation, we'd add Land Size, District, and Crops here
            const TextField(
              decoration: InputDecoration(
                labelText: 'District (Optional)',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: _finishSetup,
              child: const Text('Start Using Krushi Mitra'),
            ),
          ],
        ),
      ),
    );
  }
}
