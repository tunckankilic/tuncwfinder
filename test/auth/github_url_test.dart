import 'package:flutter_test/flutter_test.dart';
import 'package:tuncforwork/service/validation.dart';

void main() {
  group('GitHub URL Validasyonu', () {
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

    test('Geçersiz GitHub URL\'leri reddedilmeli', () {
      final invalidUrls = [
        'github.com/username', // protokol eksik
        'https://gitlab.com/username', // yanlış domain
        'https://github.com/user/repo', // repo içeren URL
        'https://github.com', // kullanıcı adı eksik
        'https://github.com/', // kullanıcı adı eksik
        'https://github.com/user@name', // geçersiz karakter
      ];

      for (var url in invalidUrls) {
        final result = RegistrationValidator.validateSocialLinks(
          linkedIn: '',
          instagram: '',
          github: url,
          termsAccepted: true,
        );
        expect(result.isValid, false,
            reason: 'GitHub URL geçersiz olmalı: $url');
      }
    });
  });
}
