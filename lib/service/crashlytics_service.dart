import 'dart:developer' as dev_tools;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Service for Firebase Crashlytics integration
/// Handles crash reporting and error logging
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  late FirebaseCrashlytics _crashlytics;
  bool _initialized = false;

  /// Initialize Crashlytics
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable Crashlytics collection
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = _crashlytics.recordFlutterFatalError;

      // Catch errors outside of Flutter
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      _initialized = true;
      dev_tools.log('Crashlytics initialized successfully');
    } catch (e, stackTrace) {
      dev_tools.log('Failed to initialize Crashlytics: $e');
      dev_tools.log('Stack trace: $stackTrace');
    }
  }

  /// Log a non-fatal error
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Iterable<Object>? information,
    bool fatal = false,
  }) async {
    if (!_initialized) {
      dev_tools.log('Crashlytics not initialized, skipping error log');
      return;
    }

    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        information: information?.cast<Object>() ?? [],
        fatal: fatal,
      );

      dev_tools.log('Error logged to Crashlytics: $error');
    } catch (e) {
      dev_tools.log('Failed to log error to Crashlytics: $e');
    }
  }

  /// Log a message to Crashlytics
  Future<void> logMessage(String message) async {
    if (!_initialized) return;

    try {
      await _crashlytics.log(message);
    } catch (e) {
      dev_tools.log('Failed to log message to Crashlytics: $e');
    }
  }

  /// Set user identifier
  Future<void> setUserId(String userId) async {
    if (!_initialized) return;

    try {
      await _crashlytics.setUserIdentifier(userId);
      dev_tools.log('User ID set in Crashlytics: $userId');
    } catch (e) {
      dev_tools.log('Failed to set user ID in Crashlytics: $e');
    }
  }

  /// Set custom key-value pairs
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_initialized) return;

    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      dev_tools.log('Failed to set custom key in Crashlytics: $e');
    }
  }

  /// Set multiple custom keys at once
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    if (!_initialized) return;

    try {
      for (var entry in keys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
    } catch (e) {
      dev_tools.log('Failed to set custom keys in Crashlytics: $e');
    }
  }

  /// Force a crash (for testing purposes only)
  void forceCrash() {
    if (!_initialized) return;
    _crashlytics.crash();
  }

  /// Enable/disable crash collection
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    if (!_initialized) return;

    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      dev_tools
          .log('Crashlytics collection ${enabled ? "enabled" : "disabled"}');
    } catch (e) {
      dev_tools.log('Failed to set Crashlytics collection: $e');
    }
  }

  /// Check if Crashlytics is initialized
  bool get isInitialized => _initialized;
}

/// Global instance for easy access
final crashlyticsService = CrashlyticsService();
