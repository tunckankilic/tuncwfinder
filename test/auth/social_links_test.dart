import 'package:flutter_test/flutter_test.dart';
import 'package:tuncforwork/service/validation.dart';

void main() {
  group('LinkedIn URL Validasyonu', () {
    test('Geçerli LinkedIn URL\'leri kabul edilmeli', () {
      const validUrls = [
        'https://www.linkedin.com/in/username',
        'https://linkedin.com/in/user-name',
        'http://www.linkedin.com/in/user123',
      ];

      for (var url in validUrls) {
        final result = RegistrationValidator.validateSocialLinks(
          instagram: '',
          linkedInUrl: url,
          termsAccepted: true,
        );
        expect(result.isValid, true, reason: 'URL geçerli olmalı: $url');
      }
    });

    test('Geçersiz LinkedIn URL\'leri reddedilmeli', () {
      const invalidUrls = [
        'linkedin.com/username',
        'https://facebook.com/username',
        'https://linkedin.com/company/name',
      ];

      for (var url in invalidUrls) {
        final result = RegistrationValidator.validateSocialLinks(
          instagram: '',
          linkedInUrl: url,
          termsAccepted: true,
        );
        expect(result.isValid, false, reason: 'URL geçersiz olmalı: $url');
      }
    });
  });

  group('Instagram Kullanıcı Adı Validasyonu', () {
    test('Geçerli Instagram kullanıcı adları kabul edilmeli', () {
      final validHandles = [
        '@username',
        'username123',
        'user_name',
        'user.name',
      ];

      for (var handle in validHandles) {
        final result = RegistrationValidator.validateSocialLinks(
          instagram: handle,
          termsAccepted: true,
        );
        expect(result.isValid, true,
            reason: 'Kullanıcı adı geçerli olmalı: $handle');
      }
    });

    test('Geçersiz Instagram kullanıcı adları reddedilmeli', () {
      final invalidHandles = [
        'a', // çok kısa
        'user name', // boşluk içeren
        'user@name', // @ işareti içeren
        'user!name', // özel karakter içeren
      ];

      for (var handle in invalidHandles) {
        final result = RegistrationValidator.validateSocialLinks(
          instagram: handle,
          termsAccepted: true,
        );
        expect(result.isValid, false,
            reason: 'Kullanıcı adı geçersiz olmalı: $handle');
      }
    });
  });

  group('GitHub URL Validasyonu', () {
    test('Geçerli GitHub URL\'leri kabul edilmeli', () {
      const validUrls = [
        'https://github.com/username',
        'https://www.github.com/user-name',
        'http://github.com/user123',
      ];

      for (var url in validUrls) {
        final result = RegistrationValidator.validateSocialLinks(
          instagram: '',
          githubUrl: url,
          termsAccepted: true,
        );
        expect(result.isValid, true, reason: 'URL geçerli olmalı: $url');
      }
    });

    test('Geçersiz GitHub URL\'leri reddedilmeli', () {
      const invalidUrls = [
        'github.com/username',
        'https://gitlab.com/username',
        'https://github.com/org/repo',
      ];

      for (var url in invalidUrls) {
        final result = RegistrationValidator.validateSocialLinks(
          instagram: '',
          githubUrl: url,
          termsAccepted: true,
        );
        expect(result.isValid, false, reason: 'URL geçersiz olmalı: $url');
      }
    });
  });
}
