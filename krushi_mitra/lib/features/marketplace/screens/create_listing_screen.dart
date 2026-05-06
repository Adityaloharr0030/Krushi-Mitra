import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/marketplace_provider.dart';
import '../models/listing_model.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  final MarketplaceListing? existingListing;

  const CreateListingScreen({super.key, this.existingListing});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aiService = AIService();
  final _commodityController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();

  String _unit = 'Quintal';
  bool _isGenerating = false;
  bool _isSubmitting = false;
  String _aiQuality = 'B';
  bool _isOrganic = false;
  bool _deliveryAvailable = false;
  bool _isNegotiable = true;
  final _minOrderController = TextEditingController();
  
  File? _imageFile;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingListing != null) {
      final listing = widget.existingListing!;
      _commodityController.text = listing.commodity;
      _quantityController.text = listing.quantity.toString();
      _priceController.text = listing.pricePerUnit.toString();
      _descController.text = listing.description;
      _phoneController.text = listing.phoneNumber ?? '';
      _unit = listing.unit;
      _aiQuality = listing.quality;
      _isOrganic = listing.isOrganic;
      _deliveryAvailable = listing.deliveryAvailable;
      _isNegotiable = listing.isNegotiable;
      if (listing.minimumOrder > 0) _minOrderController.text = listing.minimumOrder.toString();
    }
    
    _commodityController.addListener(() {
      setState(() {}); // Refresh chips based on typing
    });
  }

  static const _crops = [
    'Wheat', 'Rice', 'Onion', 'Tomato', 'Potato', 'Cotton',
    'Sugarcane', 'Soybean', 'Corn', 'Chilli', 'Banana',
    'Mango', 'Grapes', 'Orange', 'Garlic', 'Carrot',
  ];

  @override
  void dispose() {
    _commodityController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Using optimized settings to keep image size small for Zero-Config Base64 support
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 40,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String> _uploadImage(String id) async {
    if (_imageFile == null) return widget.existingListing?.imageUrl ?? '';
    
    // Attempt 1: Try real Firebase Storage
    try {
      final String? bucket = Firebase.app().options.storageBucket;
      final storage = bucket != null && bucket.isNotEmpty 
          ? FirebaseStorage.instanceFor(bucket: bucket)
          : FirebaseStorage.instance;
          
      final ref = storage.ref().child('marketplace').child('$id.jpg');
      final bytes = await _imageFile!.readAsBytes();
      final uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint('Storage upload failed: $e');
    }

    // Attempt 2: Zero-Config Base64 Fallback (Stores image directly in database)
    // This solves the "Storage not enabled" issue for the user automatically.
    try {
      debugPrint('Using Zero-Config Base64 mode...');
      final bytes = await _imageFile!.readAsBytes();
      
      // Safety check for Firestore 1MB limit
      if (bytes.length > 800000) { 
        throw 'Photo too large for direct listing. Please take a smaller photo.';
      }
      
      final base64Str = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64Str';
    } catch (e) {
      debugPrint('Base64 encoding failed: $e');
      rethrow;
    }
  }

  void _generateAIDescription() async {
    if (_commodityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter what you are selling first')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final details = {
        'commodity': _commodityController.text,
        'quantity': double.tryParse(_quantityController.text) ?? 0,
        'unit': _unit,
        'price': double.tryParse(_priceController.text) ?? 0,
      };

      final results = await Future.wait([
        _aiService.generateListingDescription(details, 'en'),
        _aiService.scoreListingQuality(details),
      ]);

      if (mounted) {
        setState(() {
          _descController.text = results[0];
          _aiQuality = results[1];
          _isGenerating = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _getAIPrice() async {
    if (_commodityController.text.isEmpty) return;
    setState(() => _isGenerating = true);
    try {
      final suggested = await _aiService.suggestListingPrice(_commodityController.text, 2100, 'en');
      if (mounted) {
        setState(() {
          _priceController.text = suggested.toStringAsFixed(0);
          _isGenerating = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && widget.existingListing == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a picture of your crop')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authServiceProvider).currentUser;
      final profile = ref.read(currentUserProvider).valueOrNull;
      final id = widget.existingListing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      String imageUrl = '';
      try {
        imageUrl = await _uploadImage(id);
      } catch (e) {
        debugPrint('Image upload failed, falling back to placeholder: $e');
        // Use a high-quality placeholder from Unsplash so the UI still looks premium
        imageUrl = 'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?q=80&w=500&auto=format&fit=crop';
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note: Photo could not be saved to cloud. Using placeholder instead.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      final listing = MarketplaceListing(
        id: id,
        sellerId: widget.existingListing?.sellerId ?? user?.uid ?? '',
        farmerName: widget.existingListing?.farmerName ?? profile?.name ?? user?.displayName ?? 'Farmer',
        commodity: _commodityController.text.trim(),
        quantity: double.tryParse(_quantityController.text) ?? 0,
        unit: _unit,
        pricePerUnit: double.tryParse(_priceController.text) ?? 0,
        quality: _aiQuality,
        location: widget.existingListing?.location ?? (profile != null ? '${profile.district}, ${profile.state}' : 'India'),
        description: _descController.text.trim(),
        imageUrl: imageUrl,
        phoneNumber: _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''),
        dateListed: widget.existingListing?.dateListed ?? DateTime.now(),
        isOrganic: _isOrganic,
        deliveryAvailable: _deliveryAvailable,
        isNegotiable: _isNegotiable,
        minimumOrder: double.tryParse(_minOrderController.text) ?? 0,
      );

      await ref.read(marketplaceActionsProvider).addListing(listing);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(widget.existingListing != null ? 'Listing updated!' : 'Listing published!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              ],
            ),
            backgroundColor: AppColors.primaryEmerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.existingListing != null ? 'Edit Listing' : 'Sell Your Crop', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.celestialGradient)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('CROP PICTURE'),
              const SizedBox(height: 12),
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildSectionLabel('CROP DETAILS'),
              const SizedBox(height: 12),
              _buildCropInput(),
              const SizedBox(height: 24),
              _buildSectionLabel('QUANTITY & PRICING'),
              const SizedBox(height: 12),
              _buildQuantityPrice(),
              const SizedBox(height: 24),
              _buildSectionLabel('CONTACT DETAILS'),
              const SizedBox(height: 12),
              _buildPhoneField(),
              const SizedBox(height: 24),
              _buildSectionLabel('PRODUCE OPTIONS'),
              const SizedBox(height: 12),
              _buildProduceOptions(),
              const SizedBox(height: 24),
              _buildAISection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(width: 4, height: 14, decoration: BoxDecoration(color: AppColors.primaryEmerald, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
          image: _imageFile != null 
            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
            : (widget.existingListing?.imageUrl.isNotEmpty ?? false)
              ? DecorationImage(image: NetworkImage(widget.existingListing!.imageUrl), fit: BoxFit.cover)
              : null,
        ),
        child: (_imageFile == null && (widget.existingListing?.imageUrl.isEmpty ?? true))
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo_rounded, size: 40, color: AppColors.primaryEmerald),
                const SizedBox(height: 12),
                Text('Add Crop Photo', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                Text('High quality photos attract more buyers', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary)),
              ],
            )
          : Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
              ),
            ),
      ),
    );
  }

  Widget _buildCropInput() {
    final typedText = _commodityController.text.trim().toLowerCase();
    final matchingCrops = _crops.where((c) => c.toLowerCase().contains(typedText)).toList();
    final isTypedCropInList = _crops.any((c) => c.toLowerCase() == typedText);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.outline.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _commodityController,
            decoration: const InputDecoration(
              labelText: 'Crop Name (e.g. Wheat, Rice)', 
              prefixIcon: Icon(Icons.grass_rounded),
              hintText: 'Type your crop name...',
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter crop name' : null,
          ),
          // Only show Quick Select if the typed text matches some crops in the list
          // If NOT in list and NOT empty, hide the other options (as requested)
          if (typedText.isNotEmpty && matchingCrops.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Is it one of these?', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: matchingCrops.map((crop) => GestureDetector(
                onTap: () => setState(() => _commodityController.text = crop),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _commodityController.text == crop ? AppColors.primaryEmerald : AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(crop, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _commodityController.text == crop ? Colors.white : AppColors.textPrimary)),
                ),
              )).toList(),
            ),
          ] else if (typedText.isEmpty) ...[
            const SizedBox(height: 16),
            Text('Popular Crops:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _crops.take(8).map((crop) => GestureDetector(
                onTap: () => setState(() => _commodityController.text = crop),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _commodityController.text == crop ? AppColors.primaryEmerald : AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(crop, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _commodityController.text == crop ? Colors.white : AppColors.textPrimary)),
                ),
              )).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildQuantityPrice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.outline.withValues(alpha: 0.3))),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Total Weight'),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _unit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: ['Kg', 'Quintal', 'Ton'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (val) => setState(() => _unit = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price per Unit (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded)),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'AI Price Suggestion',
                child: InkWell(
                  onTap: _isGenerating ? null : _getAIPrice,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.primaryEmerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: _isGenerating
                        ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryEmerald))
                        : const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryEmerald),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.outline.withValues(alpha: 0.3))),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Mobile Number',
          hintText: '10 digit number',
          prefixIcon: Icon(Icons.phone_rounded),
          prefixText: '+91 ',
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) return 'Required for buyers';
          final cleaned = val.trim().replaceAll(RegExp(r'[^0-9]'), '');
          if (cleaned.length < 10) return 'Invalid number';
          return null;
        },
      ),
    );
  }

  Widget _buildProduceOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.outline.withValues(alpha: 0.3))),
      child: Column(children: [
        _buildSwitch('🌿 Organic Produce', 'No chemical usage', _isOrganic, (v) => setState(() => _isOrganic = v)),
        Divider(color: AppColors.outline.withValues(alpha: 0.2), height: 24),
        _buildSwitch('🚚 Delivery Available', 'You can transport to buyer', _deliveryAvailable, (v) => setState(() => _deliveryAvailable = v)),
        Divider(color: AppColors.outline.withValues(alpha: 0.2), height: 24),
        _buildSwitch('💬 Price Negotiable', 'Open to bargaining', _isNegotiable, (v) => setState(() => _isNegotiable = v)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _minOrderController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Minimum Order Quantity', prefixIcon: const Icon(Icons.shopping_basket_rounded), hintText: 'Optional'),
        ),
      ]),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
      ])),
      Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primaryEmerald),
    ]);
  }

  Widget _buildAISection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryEmerald.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('AI Description Assistant', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryEmerald)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryEmerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('Quality Score: $_aiQuality', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.primaryEmerald, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Write something about your crop...',
              hintText: 'Or tap below to auto-write...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _isGenerating ? null : _generateAIDescription,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isGenerating)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryEmerald))
                  else
                    const Text('✨', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text('Write with AI', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryEmerald)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryEmerald,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          disabledBackgroundColor: AppColors.textSecondary,
        ),
        child: _isSubmitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(widget.existingListing != null ? 'Update Listing' : 'List My Crop Now', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
