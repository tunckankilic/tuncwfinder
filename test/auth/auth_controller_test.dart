import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncforwork/service/validation.dart';

class MockAuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneNoController = TextEditingController();
}

void main() {
  late MockAuthController authController;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    authController = MockAuthController();
    Get.put(authController);
  });

  tearDown(() {
    Get.reset();
  });

  group('Şifre Validasyonu', () {
    test('Geçerli şifre doğru şekilde validate edilmeli', () {
      const validPassword = 'Test123!@#';
      final strength = PasswordValidator.validatePassword(validPassword);

      expect(strength.isValid, true);
      expect(strength.score, 100);
    });

    test('Zayıf şifre reddedilmeli', () {
      const weakPassword = 'test';
      final strength = PasswordValidator.validatePassword(weakPassword);

      expect(strength.isValid, false);
      expect(strength.score < 60, true);
    });

    test('Şifre gereksinimleri kontrol edilmeli', () {
      const password = 'Test123!@#';
      final strength = PasswordValidator.validatePassword(password);

      for (var req in strength.requirements) {
        expect(req.isMet, true);
      }
    });
  });

  group('Email Validasyonu', () {
    test('Geçerli email kabul edilmeli', () {
      const validEmail = 'test@example.com';
      authController.emailController.text = validEmail;

      final result = RegistrationValidator.validateStartPage(
        profileImage: null,
        name: 'Test User',
        email: validEmail,
        password: 'Test123!@#',
        confirmPassword: 'Test123!@#',
      );

      expect(result.isValid, true);
    });

    test('Geçersiz email reddedilmeli', () {
      const invalidEmail = 'invalid-email';
      authController.emailController.text = invalidEmail;

      final result = RegistrationValidator.validateStartPage(
        profileImage: null,
        name: 'Test User',
        email: invalidEmail,
        password: 'Test123!@#',
        confirmPassword: 'Test123!@#',
      );

      expect(result.isValid, false);
    });
  });

  group('Form Validasyonu', () {
    test('Tüm alanlar dolu olduğunda form geçerli olmalı', () {
      authController.nameController.text = 'Test User';
      authController.emailController.text = 'test@example.com';
      authController.passwordController.text = 'Test123!@#';
      authController.confirmPasswordController.text = 'Test123!@#';
      authController.ageController.text = '25';
      authController.phoneNoController.text = '+905555555555';

      final result = RegistrationValidator.validatePersonalInfo(
        age: authController.ageController.text,
        gender: 'Male',
        phone: authController.phoneNoController.text,
        country: 'Turkey',
        city: 'Istanbul',
        profileHeading: 'Test Profile',
      );

      expect(result.isValid, true);
    });

    test('Eksik alan olduğunda form geçersiz olmalı', () {
      final result = RegistrationValidator.validatePersonalInfo(
        age: '',
        gender: '',
        phone: '',
        country: '',
        city: '',
        profileHeading: '',
      );

      expect(result.isValid, false);
    });
  });
}
