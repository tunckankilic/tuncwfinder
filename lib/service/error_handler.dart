import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncforwork/service/snackbar_service.dart';

/// Global Error Handler Service
/// Tüm hata türlerini yakalar ve kullanıcı dostu mesajlar gösterir
class ErrorHandler extends GetxService {
  static ErrorHandler get instance => Get.find();

  // Error tracking için
  final RxList<AppError> errorHistory = <AppError>[].obs;
  final RxInt errorCount = 0.obs;

  /// Firebase Auth hatalarını handle eder
  String handleFirebaseAuthError(FirebaseAuthException error) {
    log('Firebase Auth Error: ${error.code} - ${error.message}');
    errorCount.value++;

    String userMessage;

    switch (error.code) {
      case 'user-not-found':
        userMessage = 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
        break;
      case 'wrong-password':
        userMessage = 'Hatalı şifre girdiniz.';
        break;
      case 'email-already-in-use':
        userMessage = 'Bu e-posta adresi zaten kullanılıyor.';
        break;
      case 'invalid-email':
        userMessage = 'Geçersiz e-posta adresi.';
        break;
      case 'weak-password':
        userMessage = 'Şifreniz çok zayıf. Daha güçlü bir şifre seçin.';
        break;
      case 'user-disabled':
        userMessage = 'Bu hesap devre dışı bırakıldı.';
        break;
      case 'too-many-requests':
        userMessage =
            'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.';
        break;
      case 'operation-not-allowed':
        userMessage = 'Bu işlem şu anda izin verilmiyor.';
        break;
      case 'account-exists-with-different-credential':
        userMessage = 'Bu e-posta adresi farklı bir giriş yöntemiyle kayıtlı.';
        break;
      case 'invalid-credential':
        userMessage = 'Geçersiz kimlik bilgileri.';
        break;
      case 'invalid-verification-code':
        userMessage = 'Geçersiz doğrulama kodu.';
        break;
      case 'invalid-verification-id':
        userMessage = 'Geçersiz doğrulama ID.';
        break;
      case 'network-request-failed':
        userMessage =
            'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin.';
        break;
      default:
        userMessage = 'Bir hata oluştu: ${error.message ?? 'Bilinmeyen hata'}';
    }

    _trackError(AppError(
      type: ErrorType.auth,
      code: error.code,
      message: error.message ?? 'Unknown error',
      userMessage: userMessage,
      timestamp: DateTime.now(),
    ));

    return userMessage;
  }

  /// Firestore hatalarını handle eder
  String handleFirestoreError(FirebaseException error) {
    log('Firestore Error: ${error.code} - ${error.message}');
    errorCount.value++;

    String userMessage;

    switch (error.code) {
      case 'permission-denied':
        userMessage = 'Bu işlem için yetkiniz yok.';
        break;
      case 'not-found':
        userMessage = 'Aradığınız veri bulunamadı.';
        break;
      case 'already-exists':
        userMessage = 'Bu veri zaten mevcut.';
        break;
      case 'resource-exhausted':
        userMessage = 'Sistem meşgul. Lütfen daha sonra tekrar deneyin.';
        break;
      case 'cancelled':
        userMessage = 'İşlem iptal edildi.';
        break;
      case 'unavailable':
        userMessage = 'Servis şu anda kullanılamıyor.';
        break;
      case 'deadline-exceeded':
        userMessage = 'İşlem zaman aşımına uğradı.';
        break;
      default:
        userMessage =
            'Veritabanı hatası: ${error.message ?? 'Bilinmeyen hata'}';
    }

    _trackError(AppError(
      type: ErrorType.firestore,
      code: error.code,
      message: error.message ?? 'Unknown error',
      userMessage: userMessage,
      timestamp: DateTime.now(),
    ));

    return userMessage;
  }

  /// Genel hataları handle eder
  String handleGeneralError(Exception error) {
    log('General Error: $error');
    errorCount.value++;

    String userMessage;

    if (error is FormatException) {
      userMessage = 'Veri format hatası.';
    } else if (error is TypeError) {
      userMessage = 'Veri tipi hatası.';
    } else {
      userMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }

    _trackError(AppError(
      type: ErrorType.general,
      code: 'general-error',
      message: error.toString(),
      userMessage: userMessage,
      timestamp: DateTime.now(),
    ));

    return userMessage;
  }

  /// Network hatalarını handle eder
  String handleNetworkError() {
    log('Network Error');
    errorCount.value++;

    const userMessage = 'İnternet bağlantınızı kontrol edin.';

    _trackError(AppError(
      type: ErrorType.network,
      code: 'network-error',
      message: 'Network connection failed',
      userMessage: userMessage,
      timestamp: DateTime.now(),
    ));

    return userMessage;
  }

  /// Hata mesajını kullanıcıya gösterir
  void showError(String message, {Duration? duration}) {
    if (Get.context != null && Get.context!.mounted) {
      SnackbarService.showError(
        Get.context!,
        message,
        title: 'Hata',
        duration: duration ?? const Duration(seconds: 4),
      );
    }
  }

  /// Başarı mesajını kullanıcıya gösterir
  void showSuccess(String message, {Duration? duration}) {
    if (Get.context != null && Get.context!.mounted) {
      SnackbarService.showSuccess(
        Get.context!,
        message,
        duration: duration ?? const Duration(seconds: 3),
      );
    }
  }

  /// Uyarı mesajını kullanıcıya gösterir
  void showWarning(String message, {Duration? duration}) {
    if (Get.context != null && Get.context!.mounted) {
      SnackbarService.showWarning(
        Get.context!,
        message,
        duration: duration ?? const Duration(seconds: 3),
      );
    }
  }

  /// Bilgi mesajını kullanıcıya gösterir
  void showInfo(String message, {Duration? duration}) {
    if (Get.context != null && Get.context!.mounted) {
      SnackbarService.showInfo(
        Get.context!,
        message,
        duration: duration ?? const Duration(seconds: 3),
      );
    }
  }

  /// Loading dialog gösterir
  void showLoading({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            hideLoading();
          }
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Loading dialog'u kapatır
  void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Hata geçmişini temizler
  void clearErrorHistory() {
    errorHistory.clear();
    errorCount.value = 0;
  }

  /// Hata geçmişini döndürür
  List<AppError> getErrorHistory() {
    return errorHistory.toList();
  }

  /// Son hataları döndürür
  List<AppError> getRecentErrors({int count = 10}) {
    if (errorHistory.length <= count) {
      return errorHistory.toList();
    }
    return errorHistory.sublist(errorHistory.length - count);
  }

  // Private methods

  void _trackError(AppError error) {
    errorHistory.add(error);

    // Sadece son 100 hatayı tut
    if (errorHistory.length > 100) {
      errorHistory.removeAt(0);
    }
  }

  /// Try-catch wrapper - async fonksiyonlar için
  Future<T?> tryAsync<T>({
    required Future<T> Function() operation,
    String? errorMessage,
    bool showErrorToUser = true,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } on FirebaseAuthException catch (e) {
      final message = handleFirebaseAuthError(e);
      if (showErrorToUser) showError(errorMessage ?? message);
      return defaultValue;
    } on FirebaseException catch (e) {
      final message = handleFirestoreError(e);
      if (showErrorToUser) showError(errorMessage ?? message);
      return defaultValue;
    } catch (e) {
      final message = handleGeneralError(e as Exception);
      if (showErrorToUser) showError(errorMessage ?? message);
      return defaultValue;
    }
  }

  /// Try-catch wrapper - sync fonksiyonlar için
  T? trySync<T>({
    required T Function() operation,
    String? errorMessage,
    bool showErrorToUser = true,
    T? defaultValue,
  }) {
    try {
      return operation();
    } on FirebaseAuthException catch (e) {
      final message = handleFirebaseAuthError(e);
      if (showErrorToUser) showError(errorMessage ?? message);
      return defaultValue;
    } on FirebaseException catch (e) {
      final message = handleFirestoreError(e);
      if (showErrorToUser) showError(errorMessage ?? message);
      return defaultValue;
    } catch (e) {
      final message = handleGeneralError(e as Exception);
      if (showErrorToUser) showError(errorMessage ?? message);
      return defaultValue;
    }
  }
}

/// Hata türleri
enum ErrorType {
  auth,
  firestore,
  network,
  general,
  validation,
}

/// Hata modeli
class AppError {
  final ErrorType type;
  final String code;
  final String message;
  final String userMessage;
  final DateTime timestamp;
  final String? stackTrace;

  AppError({
    required this.type,
    required this.code,
    required this.message,
    required this.userMessage,
    required this.timestamp,
    this.stackTrace,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'code': code,
      'message': message,
      'userMessage': userMessage,
      'timestamp': timestamp.toIso8601String(),
      'stackTrace': stackTrace,
    };
  }

  @override
  String toString() {
    return 'AppError(type: $type, code: $code, message: $message, timestamp: $timestamp)';
  }
}
