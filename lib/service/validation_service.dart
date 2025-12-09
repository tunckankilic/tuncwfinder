/// Validation service for user input across the app
/// Provides consistent validation rules and error messages
class ValidationService {
  // Field length constraints
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;
  static const int maxProfileHeadingLength = 100;
  static const int minAge = 18;
  static const int maxAge = 100;
  static const int minHeight = 100; // cm
  static const int maxHeight = 250; // cm
  static const int minWeight = 30; // kg
  static const int maxWeight = 300; // kg
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;

  // Regular expressions
  static final RegExp _nameRegex = RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s\-\.]+$');
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
  static final RegExp _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );
  static final RegExp _instagramUsernameRegex =
      RegExp(r'^[a-zA-Z0-9._]{1,30}$');
  static final RegExp _alphanumericRegex = RegExp(r'^[a-zA-Z0-9\s]+$');

  // Basic Information Validation

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi boş olamaz';
    }

    final trimmed = value.trim();
    if (trimmed.length > 100) {
      return 'E-posta adresi çok uzun';
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Geçerli bir e-posta adresi girin';
    }

    return null;
  }

  /// Validate name (first name, last name)
  static String? validateName(String? value, {String fieldName = 'İsim'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş olamaz';
    }

    final trimmed = value.trim();
    if (trimmed.length < minNameLength) {
      return '$fieldName en az $minNameLength karakter olmalı';
    }

    if (trimmed.length > maxNameLength) {
      return '$fieldName en fazla $maxNameLength karakter olabilir';
    }

    if (!_nameRegex.hasMatch(trimmed)) {
      return '$fieldName sadece harf, boşluk, tire ve nokta içerebilir';
    }

    return null;
  }

  /// Validate age
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Yaş boş olamaz';
    }

    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Geçerli bir yaş girin';
    }

    if (age < minAge) {
      return 'Yaşınız en az $minAge olmalıdır';
    }

    if (age > maxAge) {
      return 'Geçerli bir yaş girin (max $maxAge)';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası boş olamaz';
    }

    final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleaned.length < minPhoneLength || cleaned.length > maxPhoneLength) {
      return 'Telefon numarası $minPhoneLength-$maxPhoneLength rakam olmalı';
    }

    if (!_phoneRegex.hasMatch(cleaned)) {
      return 'Geçerli bir telefon numarası girin';
    }

    return null;
  }

  /// Validate optional phone (can be empty)
  static String? validateOptionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional - no error
    }
    return validatePhone(value);
  }

  /// Validate city name
  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Şehir boş olamaz';
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Şehir adı en az 2 karakter olmalı';
    }

    if (trimmed.length > 50) {
      return 'Şehir adı çok uzun';
    }

    return null;
  }

  /// Validate profile heading/bio
  static String? validateProfileHeading(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmed = value.trim();
    if (trimmed.length > maxProfileHeadingLength) {
      return 'Başlık en fazla $maxProfileHeadingLength karakter olabilir';
    }

    return null;
  }

  /// Validate bio/description
  static String? validateBio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmed = value.trim();
    if (trimmed.length > maxBioLength) {
      return 'Açıklama en fazla $maxBioLength karakter olabilir';
    }

    return null;
  }

  // Physical Information Validation

  /// Validate height (in cm)
  static String? validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final height = int.tryParse(value.trim());
    if (height == null) {
      return 'Geçerli bir boy değeri girin (cm)';
    }

    if (height < minHeight || height > maxHeight) {
      return 'Boy $minHeight-$maxHeight cm arasında olmalı';
    }

    return null;
  }

  /// Validate weight (in kg)
  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final weight = int.tryParse(value.trim());
    if (weight == null) {
      return 'Geçerli bir kilo değeri girin (kg)';
    }

    if (weight < minWeight || weight > maxWeight) {
      return 'Kilo $minWeight-$maxWeight kg arasında olmalı';
    }

    return null;
  }

  // Social Media Validation

  /// Validate Instagram username
  static String? validateInstagramUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmed = value.trim().replaceAll('@', '');

    if (trimmed.length > 30) {
      return 'Instagram kullanıcı adı çok uzun';
    }

    if (!_instagramUsernameRegex.hasMatch(trimmed)) {
      return 'Geçerli bir Instagram kullanıcı adı girin';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value, {String fieldName = 'URL'}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmed = value.trim();

    if (!_urlRegex.hasMatch(trimmed)) {
      return 'Geçerli bir $fieldName girin (http:// veya https:// ile başlamalı)';
    }

    return null;
  }

  // Dropdown/Selection Validation

  /// Validate dropdown selection
  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName seçimi yapılmalı';
    }
    return null;
  }

  /// Validate optional dropdown (can be empty)
  static String? validateOptionalDropdown(String? value) {
    return null; // Always valid for optional dropdowns
  }

  // Password Validation (for authentication)

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş olamaz';
    }

    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalı';
    }

    if (value.length > 50) {
      return 'Şifre çok uzun';
    }

    // Check for at least one letter and one number
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Şifre en az bir harf içermelidir';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Şifre en az bir rakam içermelidir';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı boş olamaz';
    }

    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }

    return null;
  }

  // Generic Validation

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş olamaz';
    }
    return null;
  }

  /// Validate alphanumeric field
  static String? validateAlphanumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }

    if (!_alphanumericRegex.hasMatch(value.trim())) {
      return '$fieldName sadece harf ve rakam içerebilir';
    }

    return null;
  }

  /// Sanitize string input (remove dangerous characters)
  static String sanitize(String input) {
    // Remove potential XSS characters
    return input
        .trim()
        .replaceAll(RegExp(r'[<>]'), '')
        .replaceAll(RegExp(r'[\n\r]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Check if string contains profanity (basic check)
  static bool containsProfanity(String text) {
    // Basic profanity check - expand this list as needed
    final profanityWords = [
      // Add Turkish and English profanity words here
      // This is just a placeholder
    ];

    final lowerText = text.toLowerCase();
    return profanityWords.any((word) => lowerText.contains(word));
  }
}
