class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  // Phone validation (basic)
  static bool isValidPhone(String phone) {
    // Accepts phone numbers with at least 8 digits
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanedPhone.length >= 8;
  }

  // Check if string is not empty
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  // Check if number is in valid range
  static bool isInRange(int value, int min, int max) {
    return value >= min && value <= max;
  }

  // Validate star rating (1-5)
  static bool isValidStarRating(int value) {
    return isInRange(value, 1, 5);
  }

  // Validate score (1-10)
  static bool isValidScore(int value) {
    return isInRange(value, 1, 10);
  }
}
