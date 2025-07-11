import 'package:flutter_test/flutter_test.dart';
import 'package:tuncforwork/service/validation.dart';

void main() {
  group('Yaş Validasyonu', () {
    test('Geçerli yaşlar kabul edilmeli', () {
      final validAges = ['18', '25', '50', '99'];

      for (var age in validAges) {
        final result = RegistrationValidator.validatePersonalInfo(
          age: age,
          gender: 'Male',
          phone: '+905555555555',
          country: 'Turkey',
          city: 'Istanbul',
          profileHeading: 'Test Profile',
        );
        expect(result.isValid, true, reason: 'Yaş geçerli olmalı: $age');
      }
    });

    test('Geçersiz yaşlar reddedilmeli', () {
      final invalidAges = ['17', '0', '-1', '150', 'abc'];

      for (var age in invalidAges) {
        final result = RegistrationValidator.validatePersonalInfo(
          age: age,
          gender: 'Male',
          phone: '+905555555555',
          country: 'Turkey',
          city: 'Istanbul',
          profileHeading: 'Test Profile',
        );
        expect(result.isValid, false, reason: 'Yaş geçersiz olmalı: $age');
      }
    });
  });

  group('Telefon Numarası Validasyonu', () {
    test('Geçerli telefon numaraları kabul edilmeli', () {
      final validPhones = [
        '+905555555555',
        '+905555555555',
        '05555555555',
      ];

      for (var phone in validPhones) {
        final result = RegistrationValidator.validatePersonalInfo(
          age: '25',
          gender: 'Male',
          phone: phone,
          country: 'Turkey',
          city: 'Istanbul',
          profileHeading: 'Test Profile',
        );
        expect(result.isValid, true,
            reason: 'Telefon numarası geçerli olmalı: $phone');
      }
    });

    test('Geçersiz telefon numaraları reddedilmeli', () {
      final invalidPhones = [
        '555555',
        'abc123',
        '+90',
        '',
      ];

      for (var phone in invalidPhones) {
        final result = RegistrationValidator.validatePersonalInfo(
          age: '25',
          gender: 'Male',
          phone: phone,
          country: 'Turkey',
          city: 'Istanbul',
          profileHeading: 'Test Profile',
        );
        expect(result.isValid, false,
            reason: 'Telefon numarası geçersiz olmalı: $phone');
      }
    });
  });

  group('Profil Başlığı Validasyonu', () {
    test('Geçerli profil başlıkları kabul edilmeli', () {
      final validHeadings = [
        'Flutter Dev',
        'Senior Dev',
        'Mobile Dev',
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
        'A' * 31, // Çok uzun
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

  group('Konum Validasyonu', () {
    test('Geçerli konum bilgileri kabul edilmeli', () {
      final validLocations = [
        {'country': 'Turkey', 'city': 'Istanbul'},
        {'country': 'USA', 'city': 'New York'},
        {'country': 'Germany', 'city': 'Berlin'},
      ];

      for (var location in validLocations) {
        final result = RegistrationValidator.validatePersonalInfo(
          age: '25',
          gender: 'Male',
          phone: '+905555555555',
          country: location['country']!,
          city: location['city']!,
          profileHeading: 'Test Profile',
        );
        expect(result.isValid, true,
            reason:
                'Konum geçerli olmalı: ${location['country']} - ${location['city']}');
      }
    });

    test('Geçersiz konum bilgileri reddedilmeli', () {
      final invalidLocations = [
        {'country': '', 'city': 'Istanbul'},
        {'country': 'Turkey', 'city': ''},
        {'country': '', 'city': ''},
      ];

      for (var location in invalidLocations) {
        final result = RegistrationValidator.validatePersonalInfo(
          age: '25',
          gender: 'Male',
          phone: '+905555555555',
          country: location['country']!,
          city: location['city']!,
          profileHeading: 'Test Profile',
        );
        expect(result.isValid, false,
            reason:
                'Konum geçersiz olmalı: ${location['country']} - ${location['city']}');
      }
    });
  });
}
