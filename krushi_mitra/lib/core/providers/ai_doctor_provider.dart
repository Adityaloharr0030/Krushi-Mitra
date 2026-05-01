import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';

class AIDoctorState {
  final bool isLoading;
  final CropDiagnosis? diagnosis;
  final XFile? selectedImage;

  AIDoctorState({
    this.isLoading = false, 
    this.diagnosis, 
    this.selectedImage
  });

  // Get a File object from the selected XFile
  File? get selectedImageFile => selectedImage != null ? File(selectedImage!.path) : null;

  AIDoctorState copyWith({
    bool? isLoading, 
    CropDiagnosis? diagnosis, 
    XFile? selectedImage
  }) {
    return AIDoctorState(
      isLoading: isLoading ?? this.isLoading,
      diagnosis: diagnosis ?? this.diagnosis,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

class AIDoctorNotifier extends StateNotifier<AIDoctorState> {
  AIDoctorNotifier() : super(AIDoctorState());

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      state = state.copyWith(selectedImage: image, isLoading: true);
      
      try {
        final diagnosis = await AIService().analyzeCropImage(
          File(image.path), 
          'en', // TODO: Get language from a global settings provider
        );
        
        state = state.copyWith(
          isLoading: false,
          diagnosis: diagnosis,
        );
      } catch (e) {
        state = state.copyWith(isLoading: false);
        // Handle error (could add an error field to AIDoctorState)
        debugPrint('AI Doctor Error: $e');
      }
    }
  }
}

final aiDoctorProvider = StateNotifierProvider<AIDoctorNotifier, AIDoctorState>((ref) {
  return AIDoctorNotifier();
});
