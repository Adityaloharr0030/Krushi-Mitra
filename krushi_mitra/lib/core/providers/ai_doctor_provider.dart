import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';
import '../utils/image_helper.dart';

class AIDoctorState {
  final bool isLoading;
  final File? selectedImage;
  final CropDiagnosis? diagnosis;
  final String? error;

  AIDoctorState({
    this.isLoading = false,
    this.selectedImage,
    this.diagnosis,
    this.error,
  });

  AIDoctorState copyWith({
    bool? isLoading,
    File? selectedImage,
    CropDiagnosis? diagnosis,
    String? error,
  }) {
    return AIDoctorState(
      isLoading: isLoading ?? this.isLoading,
      selectedImage: selectedImage ?? this.selectedImage,
      diagnosis: diagnosis ?? this.diagnosis,
      error: error ?? this.error,
    );
  }
}

final aiDoctorProvider = StateNotifierProvider<AIDoctorNotifier, AIDoctorState>((ref) {
  return AIDoctorNotifier();
});

class AIDoctorNotifier extends StateNotifier<AIDoctorState> {
  AIDoctorNotifier() : super(AIDoctorState());

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      state = state.copyWith(isLoading: true, error: null);

      // Compress image
      final File? compressedFile = await ImageHelper.compressImageForUpload(pickedFile.path);
      
      if (compressedFile == null) {
        state = state.copyWith(isLoading: false, error: 'Failed to process image');
        return;
      }

      state = state.copyWith(selectedImage: compressedFile);

      // Analyze with Gemini
      final diagnosis = await AIService().analyzeCropImage(compressedFile, 'en');
      
      state = state.copyWith(
        isLoading: false,
        diagnosis: diagnosis,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Diagnosis failed: $e',
      );
    }
  }

  void reset() {
    state = AIDoctorState();
  }
}
