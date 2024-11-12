import 'dart:io';

import 'package:flutter/material.dart';

import 'service.dart';

// Create a ValidationResult class to handle validation outcomes
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({required this.isValid, this.errorMessage});
}

class RegistrationValidator {
  // Page 1: Personal Information Validation
  static ValidationResult validatePersonalInfo({
    required File? profileImage,
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String age,
    required String gender,
    required String phone,
    required String country,
    required String city,
    required String profileHeading,
  }) {
    // Profile Image Check
    if (profileImage == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select a profile picture',
      );
    }

    // Name Validation
    if (name.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Name is required',
      );
    }

    if (name.trim().length < 2) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Name must be at least 2 characters long',
      );
    }

    // Email Validation
    if (!GetUtils.isEmail(email.trim())) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid email address',
      );
    }

    // Password Validation
    final passwordStrength = PasswordValidator.validatePassword(password);
    if (!passwordStrength.isValid) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password does not meet requirements',
      );
    }

    // Confirm Password Validation
    if (password != confirmPassword) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Passwords do not match',
      );
    }

    // Age Validation
    int? ageNum = int.tryParse(age.trim());
    if (ageNum == null || ageNum < 18 || ageNum > 100) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid age between 18 and 100',
      );
    }

    // Gender Validation
    if (gender.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your gender',
      );
    }

    // Phone Validation
    if (!GetUtils.isPhoneNumber(phone.trim())) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid phone number',
      );
    }

    // Location Validation
    if (country.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your country',
      );
    }

    if (city.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter your city',
      );
    }

    // Profile Heading Validation
    if (profileHeading.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a profile heading',
      );
    }

    if (profileHeading.trim().length < 10) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Profile heading must be at least 10 characters long',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Page 2: Appearance Validation
  static ValidationResult validateAppearance({
    required String height,
    required String weight,
    required String bodyType,
  }) {
    // Height Validation
    double? heightNum = double.tryParse(height.trim());
    if (heightNum == null || heightNum < 100 || heightNum > 250) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid height between 100cm and 250cm',
      );
    }

    // Weight Validation
    double? weightNum = double.tryParse(weight.trim());
    if (weightNum == null || weightNum < 30 || weightNum > 300) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid weight between 30kg and 300kg',
      );
    }

    // Body Type Validation
    if (bodyType.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your body type',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Page 3: Lifestyle Validation
  static ValidationResult validateLifestyle({
    required String drink,
    required String smoke,
    required String maritalStatus,
    required String haveChildren,
    required String numberOfChildren,
    required String profession,
    required String employmentStatus,
    required String income,
    required String livingSituation,
    required String relationshipStatus,
  }) {
    // Habits Validation
    if (drink.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your drinking habits',
      );
    }

    if (smoke.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your smoking habits',
      );
    }

    // Status Validations
    if (maritalStatus.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your marital status',
      );
    }

    // Children Validation
    if (haveChildren.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please specify if you have children',
      );
    }

    if (haveChildren == 'Yes' && numberOfChildren.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please specify number of children',
      );
    }

    // Professional Info Validation
    if (profession.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your profession',
      );
    }

    if (employmentStatus.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your employment status',
      );
    }

    // Income Validation
    if (income.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter your income',
      );
    }

    double? incomeNum =
        double.tryParse(income.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (incomeNum == null || incomeNum < 0) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid income amount',
      );
    }

    // Living Situation Validation
    if (livingSituation.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your living situation',
      );
    }

    // Relationship Status Validation
    if (relationshipStatus.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your relationship status',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Page 4: Background Validation
  static ValidationResult validateBackground({
    required String nationality,
    required String education,
    required String language,
    required String religion,
    required String ethnicity,
  }) {
    // Nationality Validation
    if (nationality.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your nationality',
      );
    }

    // Education Validation
    if (education.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your education level',
      );
    }

    // Language Validation
    if (language.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select languages spoken',
      );
    }

    // Religion Validation
    if (religion.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your religion',
      );
    }

    // Ethnicity Validation
    if (ethnicity.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your ethnicity',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Page 5: Social Media Links Validation (Optional fields with URL validation)
  static ValidationResult validateSocialLinks({
    required String linkedIn,
    required String instagram,
    required String github,
    required bool termsAccepted,
  }) {
    // URL validation for optional social media links
    if (linkedIn.isNotEmpty && !GetUtils.isURL(linkedIn)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid LinkedIn URL',
      );
    }

    if (instagram.isNotEmpty && !GetUtils.isURL(instagram)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid Instagram URL',
      );
    }

    if (github.isNotEmpty && !GetUtils.isURL(github)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid GitHub URL',
      );
    }

    // Terms acceptance validation
    if (!termsAccepted) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please accept the terms and conditions',
      );
    }

    return ValidationResult(isValid: true);
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
