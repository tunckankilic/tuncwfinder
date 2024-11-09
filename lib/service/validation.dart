class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone);
  }

  static bool isValidAge(String age) {
    int? ageNum = int.tryParse(age);
    return ageNum != null && ageNum >= 18 && ageNum <= 100;
  }

  static bool isValidHeight(String height) {
    double? heightNum = double.tryParse(height);
    return heightNum != null && heightNum > 0 && heightNum < 300;
  }

  static bool isValidWeight(String weight) {
    double? weightNum = double.tryParse(weight);
    return weightNum != null && weightNum > 0 && weightNum < 500;
  }

  static bool isValidUrl(String url) {
    if (url.isEmpty) return true;
    return Uri.tryParse(url)?.isAbsolute ?? false;
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
