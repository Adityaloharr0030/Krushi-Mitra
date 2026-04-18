import 'dart:io';
import 'package:image/image.dart' as img;

class ImageHelper {
  /// Compresses an image file from a given path to ensure it is under 1MB
  /// and formatted as a JPEG for API efficiency in low-data environments.
  static Future<File?> compressImageForUpload(String filePath) async {
    final File imageFile = File(filePath);
    
    if (!await imageFile.exists()) {
      return null;
    }

    // Read the image bytes
    final bytes = await imageFile.readAsBytes();
    
    // Decode image
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return null;

    // Resize image if it's too large (Target max width/height 1200px)
    int targetWidth = originalImage.width;
    int targetHeight = originalImage.height;
    
    if (targetWidth > 1200 || targetHeight > 1200) {
      if (targetWidth > targetHeight) {
        targetHeight = (targetHeight * 1200 / targetWidth).round();
        targetWidth = 1200;
      } else {
        targetWidth = (targetWidth * 1200 / targetHeight).round();
        targetHeight = 1200;
      }
      originalImage = img.copyResize(originalImage, width: targetWidth, height: targetHeight);
    }

    // Compress as JPEG
    // In a low data mode scenario, quality of 70 is usually a good balance between visibility and size.
    final compressedBytes = img.encodeJpg(originalImage, quality: 70);

    // Save compressed bytes back to a temporary file
    final String tempPath = filePath.replaceAll(RegExp(r'\..+$'), '_compressed.jpg');
    final File compressedFile = File(tempPath);
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }
}
