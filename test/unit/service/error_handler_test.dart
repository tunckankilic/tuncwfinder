import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncforwork/service/error_handler.dart';

void main() {
  late ErrorHandler errorHandler;

  setUp(() {
    // GetX'i test için initialize et
    Get.testMode = true;
    errorHandler = ErrorHandler();
  });

  tearDown(() {
    Get.reset();
  });

  group('ErrorHandler - Firebase Auth Errors', () {
    test('handleFirebaseAuthError - user not found', () {
      // Arrange
      final error = FirebaseAuthException(
        code: 'user-not-found',
        message: 'User not found',
      );

      // Act
      final result = errorHandler.handleFirebaseAuthError(error);

      // Assert
      expect(result, 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.');
      expect(errorHandler.errorCount.value, 1);
      expect(errorHandler.errorHistory.length, 1);
      expect(errorHandler.errorHistory.first.code, 'user-not-found');
      expect(errorHandler.errorHistory.first.type, ErrorType.auth);
    });

    test('handleFirebaseAuthError - wrong password', () {
      // Arrange
      final error = FirebaseAuthException(
        code: 'wrong-password',
        message: 'Wrong password',
      );

      // Act
      final result = errorHandler.handleFirebaseAuthError(error);

      // Assert
      expect(result, 'Hatalı şifre girdiniz.');
      expect(errorHandler.errorCount.value, 1);
    });

    test('handleFirebaseAuthError - email already in use', () {
      // Arrange
      final error = FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Email in use',
      );

      // Act
      final result = errorHandler.handleFirebaseAuthError(error);

      // Assert
      expect(result, 'Bu e-posta adresi zaten kullanılıyor.');
    });

    test('handleFirebaseAuthError - weak password', () {
      // Arrange
      final error = FirebaseAuthException(
        code: 'weak-password',
        message: 'Weak password',
      );

      // Act
      final result = errorHandler.handleFirebaseAuthError(error);

      // Assert
      expect(result, 'Şifreniz çok zayıf. Daha güçlü bir şifre seçin.');
    });

    test('handleFirebaseAuthError - network error', () {
      // Arrange
      final error = FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Network failed',
      );

      // Act
      final result = errorHandler.handleFirebaseAuthError(error);

      // Assert
      expect(
          result, 'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.');
    });

    test('handleFirebaseAuthError - unknown error', () {
      // Arrange
      final error = FirebaseAuthException(
        code: 'unknown-error',
        message: 'Some unknown error',
      );

      // Act
      final result = errorHandler.handleFirebaseAuthError(error);

      // Assert
      expect(result, 'Bir hata oluştu: Some unknown error');
    });
  });

  group('ErrorHandler - General Errors', () {
    test('handleGeneralError - FormatException', () {
      // Arrange
      final error = FormatException('Invalid format');

      // Act
      final result = errorHandler.handleGeneralError(error);

      // Assert
      expect(result, 'Veri format hatası.');
      expect(errorHandler.errorCount.value, 1);
    });

    test('handleGeneralError - TypeError', () {
      // Arrange
      final error = Exception('TypeError');

      // Act
      final result = errorHandler.handleGeneralError(error);

      // Assert
      expect(result, 'Veri tipi hatası.');
    });
  });

  group('ErrorHandler - Error History', () {
    test('tracks multiple errors', () {
      // Arrange & Act
      errorHandler.handleGeneralError(FormatException('Error 1'));
      errorHandler.handleGeneralError(FormatException('Error 2'));
      errorHandler.handleGeneralError(FormatException('Error 3'));

      // Assert
      expect(errorHandler.errorHistory.length, 3);
      expect(errorHandler.errorCount.value, 3);
    });

    test('limits error history to 100 items', () {
      // Arrange & Act
      for (int i = 0; i < 110; i++) {
        errorHandler.handleGeneralError(FormatException('Error $i'));
      }

      // Assert
      expect(errorHandler.errorHistory.length, 100);
      expect(errorHandler.errorCount.value, 110);
    });

    test('clearErrorHistory works', () {
      // Arrange
      errorHandler.handleGeneralError(FormatException('Error 1'));
      errorHandler.handleGeneralError(FormatException('Error 2'));

      // Act
      errorHandler.clearErrorHistory();

      // Assert
      expect(errorHandler.errorHistory.length, 0);
      expect(errorHandler.errorCount.value, 0);
    });

    test('getRecentErrors returns last N errors', () {
      // Arrange
      for (int i = 0; i < 20; i++) {
        errorHandler.handleGeneralError(FormatException('Error $i'));
      }

      // Act
      final recentErrors = errorHandler.getRecentErrors(count: 5);

      // Assert
      expect(recentErrors.length, 5);
    });
  });

  group('ErrorHandler - Try Wrapper', () {
    test('tryAsync - success case', () async {
      // Arrange
      Future<int> successOperation() async => 42;

      // Act
      final result = await errorHandler.tryAsync(
        operation: successOperation,
        showErrorToUser: false,
      );

      // Assert
      expect(result, 42);
      expect(errorHandler.errorCount.value, 0);
    });

    test('tryAsync - failure case with default value', () async {
      // Arrange
      Future<int> failureOperation() async =>
          throw FormatException('Test error');

      // Act
      final result = await errorHandler.tryAsync(
        operation: failureOperation,
        showErrorToUser: false,
        defaultValue: 0,
      );

      // Assert
      expect(result, 0);
      expect(errorHandler.errorCount.value, 1);
    });

    test('trySync - success case', () {
      // Arrange
      int successOperation() => 42;

      // Act
      final result = errorHandler.trySync(
        operation: successOperation,
        showErrorToUser: false,
      );

      // Assert
      expect(result, 42);
      expect(errorHandler.errorCount.value, 0);
    });

    test('trySync - failure case with default value', () {
      // Arrange
      int failureOperation() => throw FormatException('Test error');

      // Act
      final result = errorHandler.trySync(
        operation: failureOperation,
        showErrorToUser: false,
        defaultValue: 0,
      );

      // Assert
      expect(result, 0);
      expect(errorHandler.errorCount.value, 1);
    });
  });
}
