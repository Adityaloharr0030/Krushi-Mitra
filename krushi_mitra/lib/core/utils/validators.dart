class Validators {
  Validators._();

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6) {
      return 'Enter the 6-digit OTP';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateLandArea(String? value) {
    if (value == null || value.isEmpty) return null; // Optional
    final area = double.tryParse(value);
    if (area == null) return 'Enter a valid number';
    if (area <= 0 || area > 99999) return 'Enter a valid land area';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePh(String? value) {
    if (value == null || value.isEmpty) return null;
    final ph = double.tryParse(value);
    if (ph == null) return 'Enter a valid pH value';
    if (ph < 0 || ph > 14) return 'pH must be between 0 and 14';
    return null;
  }

  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid $fieldName';
    if (num < 0) return '$fieldName cannot be negative';
    return null;
  }
}
