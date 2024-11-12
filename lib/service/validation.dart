import 'package:flutter/material.dart';

class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  static bool isValidPhone(String phone) {
    // Accept digits, spaces, dashes, and optional + prefix
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone);
  }

  static bool isValidAge(String age) {
    final ageNum = int.tryParse(age);
    return ageNum != null && ageNum >= 18 && ageNum <= 100;
  }

  static bool isValidHeight(String height) {
    final heightNum = double.tryParse(height);
    return heightNum != null && heightNum >= 120 && heightNum <= 220;
  }

  static bool isValidWeight(String weight) {
    final weightNum = double.tryParse(weight);
    return weightNum != null && weightNum >= 30 && weightNum <= 300;
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2 && name.trim().length <= 50;
  }

  static bool isValidUrl(String url) {
    if (url.isEmpty) return true; // Allow empty URLs
    return Uri.tryParse(url)?.isAbsolute ?? false;
  }

  static String? validateRegistrationField(String field, String value) {
    switch (field) {
      case 'email':
        return !isValidEmail(value)
            ? 'Please enter a valid email address'
            : null;
      case 'password':
        return !isValidPassword(value)
            ? 'Password must be at least 8 characters with uppercase, lowercase, number and special character'
            : null;
      case 'phone':
        return !isValidPhone(value)
            ? 'Please enter a valid phone number'
            : null;
      case 'age':
        return !isValidAge(value) ? 'Age must be between 18 and 100' : null;
      case 'height':
        return !isValidHeight(value)
            ? 'Please enter a valid height between 120 and 220 cm'
            : null;
      case 'weight':
        return !isValidWeight(value)
            ? 'Please enter a valid weight between 30 and 300 kg'
            : null;
      case 'name':
        return !isValidName(value)
            ? 'Name must be between 2 and 50 characters'
            : null;
      default:
        return value.isEmpty ? 'This field is required' : null;
    }
  }
}

class ValidationRule {
  final String value;
  final bool Function(String) validator;
  final String errorMessage;

  ValidationRule({
    required this.value,
    required this.validator,
    required this.errorMessage,
  });

  bool isValid() => validator(value.trim());
}

class FormValidationState {
  final Map<String, String?> errors = {};
  bool get isValid => errors.values.every((error) => error == null);

  void validateField(String field, String value) {
    errors[field] = ValidationUtils.validateRegistrationField(field, value);
  }

  void validateAll(Map<String, String> fields) {
    fields.forEach((field, value) {
      validateField(field, value);
    });
  }
}

class PasswordValidator {
  static const int minLength = 8;

  static PasswordStrength validatePassword(String password) {
    final requirements = <PasswordRequirement>[
      PasswordRequirement('En az $minLength karakter',
          password.length >= minLength, Icons.label),
      PasswordRequirement('Büyük harf (A-Z)',
          password.contains(RegExp(r'[A-Z]')), Icons.text_fields),
      PasswordRequirement('Küçük harf (a-z)',
          password.contains(RegExp(r'[a-z]')), Icons.text_fields_outlined),
      PasswordRequirement(
          'Sayı (0-9)', password.contains(RegExp(r'[0-9]')), Icons.numbers),
      PasswordRequirement('Özel karakter (!@#\$%^&*)',
          password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')), Icons.star),
    ];

    final failedRequirements = requirements.where((req) => !req.isMet).toList();

    return PasswordStrength(
        isValid: failedRequirements.isEmpty,
        requirements: requirements,
        failedRequirements: failedRequirements,
        score: _calculateScore(requirements));
  }

  static int _calculateScore(List<PasswordRequirement> requirements) {
    int score = 0;
    for (var req in requirements) {
      if (req.isMet) score += 20;
    }
    return score;
  }
}

class PasswordRequirement {
  final String description;
  final bool isMet;
  final IconData icon;

  PasswordRequirement(this.description, this.isMet, this.icon);
}

class PasswordStrength {
  final bool isValid;
  final List<PasswordRequirement> requirements;
  final List<PasswordRequirement> failedRequirements;
  final int score;

  PasswordStrength({
    required this.isValid,
    required this.requirements,
    required this.failedRequirements,
    required this.score,
  });

  Color get color {
    if (score < 40) return Colors.red;
    if (score < 60) return Colors.orange;
    if (score < 80) return Colors.yellow;
    return Colors.green;
  }

  String get strengthText {
    if (score < 40) return 'Zayıf';
    if (score < 60) return 'Orta';
    if (score < 80) return 'İyi';
    return 'Güçlü';
  }
}
