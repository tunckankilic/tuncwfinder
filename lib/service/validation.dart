import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({required this.isValid, this.errorMessage});
}

class RegistrationValidator {
  // Start Page validation
  static ValidationResult validateStartPage({
    required File? profileImage,
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
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
    if (email.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Email is required',
      );
    }

    if (!GetUtils.isEmail(email.trim())) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid email address',
      );
    }

    // Password Validation
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password is required',
      );
    }

    final passwordStrength = PasswordValidator.validatePassword(password);
    if (!passwordStrength.isValid) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password does not meet requirements',
      );
    }

    // Confirm Password Validation
    if (confirmPassword.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please confirm your password',
      );
    }

    if (password != confirmPassword) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Passwords do not match',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Personal Info validation
  static ValidationResult validatePersonalInfo({
    required String age,
    required String gender,
    required String phone,
    required String country,
    required String city,
    required String profileHeading,
  }) {
    // Age Validation
    if (age.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Age is required',
      );
    }

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
    if (phone.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Phone number is required',
      );
    }

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

  static ValidationResult validateAppearance({
    required String height,
    required String weight,
    required String bodyType,
  }) {
    // Height Validation
    if (height.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Height is required',
      );
    }

    double? heightNum = double.tryParse(height.trim());
    if (heightNum == null || heightNum < 100 || heightNum > 250) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid height between 100cm and 250cm',
      );
    }

    // Weight Validation
    if (weight.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Weight is required',
      );
    }

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

  // Lifestyle validasyonu
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
    // Drinking Habits
    if (drink.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your drinking habits',
      );
    }

    // Smoking Habits
    if (smoke.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your smoking habits',
      );
    }

    // Marital Status
    if (maritalStatus.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your marital status',
      );
    }

    // Children Information
    if (haveChildren.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please specify if you have children',
      );
    }

    if (haveChildren == 'Yes') {
      if (numberOfChildren.trim().isEmpty) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Please specify number of children',
        );
      }

      int? childrenNum = int.tryParse(numberOfChildren.trim());
      if (childrenNum == null || childrenNum < 0 || childrenNum > 20) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Please enter a valid number of children (0-20)',
        );
      }
    }

    // Professional Information
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

    // Living Situation
    if (livingSituation.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your living situation',
      );
    }

    // Relationship Status
    if (relationshipStatus.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your relationship status',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Background validasyonu
  static ValidationResult validateBackground({
    required String nationality,
    required String education,
    required String language,
    required String religion,
    required String ethnicity,
  }) {
    // Nationality
    if (nationality.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your nationality',
      );
    }

    // Education
    if (education.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your education level',
      );
    }

    // Language
    if (language.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your language(s)',
      );
    }

    // Religion
    if (religion.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your religion',
      );
    }

    // Ethnicity
    if (ethnicity.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select your ethnicity',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Social Links validasyonu
  static ValidationResult validateSocialLinks({
    required String linkedIn,
    required String instagram,
    required String github,
    required bool termsAccepted,
  }) {
    // LinkedIn Validation (Optional)
    if (linkedIn.isNotEmpty) {
      final linkedInPattern = RegExp(
        r'^https?:\/\/(www\.)?linkedin\.com\/(in|pub)\/[A-Za-z0-9_-]+\/?$',
      );
      if (!linkedInPattern.hasMatch(linkedIn.trim())) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Please enter a valid LinkedIn profile URL',
        );
      }
    }

    // Instagram Validation (Optional)
    if (instagram.isNotEmpty) {
      final instagramPattern = RegExp(r'^@?[A-Za-z0-9_.]+$');
      if (!instagramPattern.hasMatch(instagram.trim())) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Please enter a valid Instagram handle',
        );
      }
    }

    // GitHub Validation (Optional)
    if (github.isNotEmpty) {
      final githubPattern = RegExp(
        r'^https?:\/\/(www\.)?github\.com\/[A-Za-z0-9_-]+\/?$',
      );
      if (!githubPattern.hasMatch(github.trim())) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Please enter a valid GitHub profile URL',
        );
      }
    }

    // Terms and Conditions
    if (!termsAccepted) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please accept the terms and conditions',
      );
    }

    return ValidationResult(isValid: true);
  }

  // Helper method for URL validation
  static bool isValidUrl(String url) {
    if (url.isEmpty) return true; // Optional fields
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  // Helper method for numeric validation
  static bool isValidNumber(String value,
      {double min = 0, double max = double.infinity}) {
    try {
      final number = double.parse(value);
      return number >= min && number <= max;
    } catch (e) {
      return false;
    }
  }
}

// Password valdation classes
class PasswordValidator {
  static const int minLength = 8;

  static PasswordStrength validatePassword(String password) {
    final requirements = <PasswordRequirement>[
      PasswordRequirement(
        'At least $minLength characters',
        password.length >= minLength,
        Icons.label,
      ),
      PasswordRequirement(
        'Uppercase letter (A-Z)',
        password.contains(RegExp(r'[A-Z]')),
        Icons.text_fields,
      ),
      PasswordRequirement(
        'Lowercase letter (a-z)',
        password.contains(RegExp(r'[a-z]')),
        Icons.text_fields_outlined,
      ),
      PasswordRequirement(
        'Number (0-9)',
        password.contains(RegExp(r'[0-9]')),
        Icons.numbers,
      ),
      PasswordRequirement(
        'Special character (!@#\$%^&*)',
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
        Icons.star,
      ),
    ];

    final failedRequirements = requirements.where((req) => !req.isMet).toList();

    return PasswordStrength(
      isValid: failedRequirements.isEmpty,
      requirements: requirements,
      failedRequirements: failedRequirements,
      score: _calculateScore(requirements),
    );
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
    if (score < 40) return 'Weak';
    if (score < 60) return 'Medium';
    if (score < 80) return 'Good';
    return 'Strong';
  }
}

extension ValidationHandling on AuthController {
  void handleValidation({
    required ValidationResult result,
    VoidCallback? onSuccess,
  }) {
    if (result.isValid) {
      onSuccess?.call();
    } else {
      Get.snackbar(
        'Error',
        result.errorMessage ?? 'Please check your inputs',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    }
  }

  void validateAndProceed() {
    ValidationResult? validationResult;

    switch (currentPage.value) {
      case 0: // Start Page
        validationResult = RegistrationValidator.validateStartPage(
          profileImage: pickedImage.value,
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
        );
        break;

      case 1: // Personal Info
        validationResult = RegistrationValidator.validatePersonalInfo(
          age: ageController.text,
          gender: genderController.text,
          phone: phoneNoController.text,
          country: countryController.text,
          city: cityController.text,
          profileHeading: profileHeadingController.text,
        );
        break;

      case 2: // Appearance
        validationResult = RegistrationValidator.validateAppearance(
          height: heightController.text,
          weight: weightController.text,
          bodyType: bodyTypeController.text,
        );
        break;

      case 3: // Lifestyle
        validationResult = RegistrationValidator.validateLifestyle(
          drink: drinkController.text,
          smoke: smokeController.text,
          maritalStatus: martialStatusController.text,
          haveChildren: childrenSelection.value,
          numberOfChildren: noOfChildrenController.text,
          profession: professionController.text,
          employmentStatus: employmentStatusController.text,
          income: incomeController.text,
          livingSituation: livingSituationController.text,
          relationshipStatus: relationshipSelection.value,
        );
        break;

      case 4: // Background
        validationResult = RegistrationValidator.validateBackground(
          nationality: nationalityController.text,
          education: educationController.text,
          language: languageSpokenController.text,
          religion: religionController.text,
          ethnicity: ethnicityController.text,
        );
        break;

      case 5: // Social Links
        validationResult = RegistrationValidator.validateSocialLinks(
          linkedIn: linkedInController.text,
          instagram: instagramController.text,
          github: githubController.text,
          termsAccepted: termsAccepted.value,
        );
        break;

      default:
        validationResult = ValidationResult(isValid: true);
    }

    handleValidation(
      result: validationResult,
      onSuccess: () {
        if (currentPage.value < 5) {
          pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          currentPage.value++;
        }
      },
    );
  }
}

// Validasyon için kullanılacak bazı helper extension'lar
extension StringValidationExtension on String {
  bool get isValidLinkedInUrl => RegExp(
        r'^https?:\/\/(www\.)?linkedin\.com\/(in|pub)\/[A-Za-z0-9_-]+\/?$',
      ).hasMatch(this);

  bool get isValidInstagramHandle =>
      RegExp(r'^@?[A-Za-z0-9_.]+$').hasMatch(this);

  bool get isValidGithubUrl => RegExp(
        r'^https?:\/\/(www\.)?github\.com\/[A-Za-z0-9_-]+\/?$',
      ).hasMatch(this);

  bool get isValidNumber {
    try {
      double.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }
}
