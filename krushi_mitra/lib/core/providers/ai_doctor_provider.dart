import 'dart:io';
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
      
      // Mocking a diagnosis for demonstration/build purposes
      // In real app, call AIService().analyzeCropImage(File(image.path), 'en')
      await Future.delayed(const Duration(seconds: 2));
      
      state = state.copyWith(
        isLoading: false,
        diagnosis: CropDiagnosis(
          cropName: 'Tomato',
          healthStatus: 'diseased',
          diseaseName: 'Early Blight',
          severity: 'medium',
          symptoms: 'Dark spots with concentric rings on lower leaves.',
          causes: 'Fungus Alternaria solani',
          treatmentOrganic: 'Apply neem oil spray and remove infected leaves.',
          treatmentChemical: 'Spray Mancozeb or Chlorothalonil as per instructions.',
          prevention: 'Rotate crops and avoid overhead watering.',
          confidencePercent: 92.0,
        ),
      );
    }
  }
}

final aiDoctorProvider = StateNotifierProvider<AIDoctorNotifier, AIDoctorState>((ref) {
  return AIDoctorNotifier();
});
