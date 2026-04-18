import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class AppHelpers {
  AppHelpers._();

  /// Format number as Indian currency
  static String formatCurrency(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format date to readable string
  static String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  /// Format date for Mandi (DD-MM-YYYY)
  static String formatMandiDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// Get current season (Kharif / Rabi / Zaid)
  static String getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 6 && month <= 10) return 'Kharif (खरीफ)';
    if (month >= 11 || month <= 2) return 'Rabi (रबी)';
    return 'Zaid (जायद)';
  }

  /// Get greeting based on time of day
  static String getTimeGreeting(String language) {
    final hour = DateTime.now().hour;
    if (language == 'hi') {
      if (hour < 12) return 'सुप्रभात';
      if (hour < 17) return 'नमस्ते';
      return 'शुभ संध्या';
    } else if (language == 'mr') {
      if (hour < 12) return 'शुभ सकाळ';
      if (hour < 17) return 'नमस्कार';
      return 'शुभ संध्याकाळ';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 17) return 'Good Afternoon';
      return 'Good Evening';
    }
  }

  /// Compress image for API upload
  static Future<Uint8List> compressImage(File imageFile, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) return bytes;

    final resized = img.copyResize(
      originalImage,
      width: originalImage.width > maxWidth ? maxWidth : null,
      height: originalImage.height > maxHeight ? maxHeight : null,
    );
    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  /// Show snackbar helper
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  /// Get weather icon from condition
  static IconData getWeatherIcon(String condition) {
    final cond = condition.toLowerCase();
    if (cond.contains('rain')) return Icons.grain_rounded;
    if (cond.contains('cloud')) return Icons.cloud_rounded;
    if (cond.contains('sun') || cond.contains('clear')) return Icons.wb_sunny_rounded;
    if (cond.contains('storm') || cond.contains('thunder')) return Icons.thunderstorm_rounded;
    if (cond.contains('snow') || cond.contains('hail')) return Icons.ac_unit_rounded;
    if (cond.contains('mist') || cond.contains('fog')) return Icons.blur_on_rounded;
    return Icons.wb_sunny_rounded;
  }

  /// Get disease severity color
  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low': return const Color(0xFF388E3C);
      case 'medium': return const Color(0xFFF57F17);
      case 'high': return const Color(0xFFD32F2F);
      case 'severe': return const Color(0xFF7B1FA2);
      default: return const Color(0xFF388E3C);
    }
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Indian number format (lakhs, crores)
  static String formatIndianNumber(num num) {
    if (num >= 10000000) return '${(num / 10000000).toStringAsFixed(1)} Cr';
    if (num >= 100000) return '${(num / 100000).toStringAsFixed(1)} L';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)} K';
    return num.toString();
  }
}
