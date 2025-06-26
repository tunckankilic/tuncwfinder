import 'package:flutter_test/flutter_test.dart';
import 'package:tuncforwork/service/validation.dart';

void main() {
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
      final result = RegistrationValidator.validatePersonalInfo(
        age: '25',
        gender: 'Male',
        phone: '+905555555555',
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

  group('Profil Başlığı Validasyonu', () {
    test('Geçerli profil başlıkları kabul edilmeli', () {
      final validHeadings = [
        'Flutter Dev',
        'Senior Dev',
        'Mobile Expert',
      ];

      for (var heading in validHeadings) {
        final result = RegistrationValidator.validatePersonalInfo(
          age: '25',
          gender: 'Male',
          phone: '+905555555555',
          country: 'Turkey',
          city: 'Istanbul',
          profileHeading: heading,
        );
        expect(result.isValid, true,
            reason: 'Profil başlığı geçerli olmalı: $heading');
      }
    });

    test('Geçersiz profil başlıkları reddedilmeli', () {
      final invalidHeadings = [
        '',
        'Hi',
        'A' * 5, // Çok kısa
        'A' * 50, // Çok uzun
      ];

      for (var heading in invalidHeadings) {
        final result = RegistrationValidator.validatePersonalInfo(
          age: '25',
          gender: 'Male',
          phone: '+905555555555',
          country: 'Turkey',
          city: 'Istanbul',
          profileHeading: heading,
        );
        expect(result.isValid, false,
            reason: 'Profil başlığı geçersiz olmalı: $heading');
      }
    });
  });

  group('Sosyal Medya Validasyonu', () {
    test('Geçerli LinkedIn URL\'leri kabul edilmeli', () {
      final validUrls = [
        'https://www.linkedin.com/in/username',
        'https://linkedin.com/in/user-name',
        'http://www.linkedin.com/in/user123',
      ];

      for (var url in validUrls) {
        final result = RegistrationValidator.validateSocialLinks(
          linkedIn: url,
          instagram: '',
          github: '',
          termsAccepted: true,
        );
        expect(result.isValid, true,
            reason: 'LinkedIn URL geçerli olmalı: $url');
      }
    });

    test('Geçerli Instagram kullanıcı adları kabul edilmeli', () {
      final validHandles = [
        '@username',
        'username',
        'user_name',
        'user.name',
      ];

      for (var handle in validHandles) {
        final result = RegistrationValidator.validateSocialLinks(
          linkedIn: '',
          instagram: handle,
          github: '',
          termsAccepted: true,
        );
        expect(result.isValid, true,
            reason: 'Instagram kullanıcı adı geçerli olmalı: $handle');
      }
    });

    test('Geçerli GitHub URL\'leri kabul edilmeli', () {
      final validUrls = [
        'https://github.com/username',
        'https://www.github.com/user-name',
        'http://github.com/user123',
      ];

      for (var url in validUrls) {
        final result = RegistrationValidator.validateSocialLinks(
          linkedIn: '',
          instagram: '',
          github: url,
          termsAccepted: true,
        );
        expect(result.isValid, true, reason: 'GitHub URL geçerli olmalı: $url');
      }
    });
  });
}
