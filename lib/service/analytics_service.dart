import 'dart:developer';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for Firebase Analytics integration
/// Handles event tracking and user properties
/// GDPR/KVKK compliant - no PII (Personal Identifiable Information) sent
///
/// ⚡ PERFORMANS: Debug modunda devre dışı, sadece release modunda çalışır
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;
  bool _initialized = false;

  /// Initialize Analytics (sadece release modunda)
  Future<void> initialize() async {
    if (_initialized) return;

    // Debug modunda analytics'i başlatma (performans için)
    if (!kReleaseMode) {
      log('⚡ Analytics devre dışı (DEBUG mode)');
      return;
    }

    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);

      // Enable analytics collection (sadece release)
      await _analytics.setAnalyticsCollectionEnabled(true);

      _initialized = true;
      log('Analytics initialized successfully (RELEASE mode)');
    } catch (e) {
      log('Failed to initialize Analytics: $e');
    }
  }

  /// Get analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer => _observer;

  /// Hash user ID for privacy (GDPR/KVKK compliant)
  String _hashUserId(String userId) {
    final bytes = utf8.encode(userId);
    final hash = sha256.convert(bytes);
    // Return first 16 chars of hash for analytics (sufficient for uniqueness)
    return hash.toString().substring(0, 16);
  }

  /// Sanitize parameters to remove any PII
  Map<String, Object>? _sanitizeParameters(Map<String, dynamic>? params) {
    if (params == null) return null;

    final sanitized = <String, Object>{};

    for (var entry in params.entries) {
      final key = entry.key;
      final value = entry.value;

      // Hash any user IDs
      if (key.contains('user') || key.contains('User') || key.contains('id')) {
        if (value is String && value.isNotEmpty && value != 'unknown') {
          sanitized[key] = _hashUserId(value);
        } else {
          sanitized[key] = 'unknown';
        }
      }
      // Remove any potential email addresses
      else if (value is String && value.contains('@')) {
        sanitized[key] = 'redacted_email';
      }
      // Remove phone numbers (simple check)
      else if (value is String && RegExp(r'^\+?[0-9]{10,}$').hasMatch(value)) {
        sanitized[key] = 'redacted_phone';
      }
      // Keep safe values
      else if (value is String || value is num || value is bool) {
        sanitized[key] = value as Object;
      }
    }

    return sanitized;
  }

  /// Log a custom event (PII-safe)
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    // Debug modunda event loglamayı atla
    if (!kReleaseMode || !_initialized) {
      return;
    }

    try {
      // Sanitize parameters before sending
      final sanitizedParams = _sanitizeParameters(parameters);

      await _analytics.logEvent(
        name: name,
        parameters: sanitizedParams,
      );

      log('Event logged: $name (parameters sanitized for privacy)');
    } catch (e) {
      log('Failed to log event: $e');
    }
  }

  // User Authentication Events

  /// Log sign up event
  Future<void> logSignUp({String? signUpMethod}) async {
    await logEvent(
      name: 'sign_up',
      parameters: {'method': signUpMethod ?? 'email'},
    );
  }

  /// Log login event
  Future<void> logLogin({String? loginMethod}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': loginMethod ?? 'email'},
    );
  }

  /// Log logout event
  Future<void> logLogout() async {
    await logEvent(name: 'logout');
  }

  // Swipe Events (GDPR compliant - user IDs are hashed)

  /// Log swipe right (like) event
  Future<void> logSwipeRight({String? targetUserId}) async {
    await logEvent(
      name: 'swipe_right',
      parameters: {
        'target_user_hash': targetUserId ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log swipe left (dislike) event
  Future<void> logSwipeLeft({String? targetUserId}) async {
    await logEvent(
      name: 'swipe_left',
      parameters: {
        'target_user_hash': targetUserId ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log super like event
  Future<void> logSuperLike({String? targetUserId}) async {
    await logEvent(
      name: 'super_like',
      parameters: {
        'target_user_hash': targetUserId ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log match event
  Future<void> logMatch({String? matchedUserId}) async {
    await logEvent(
      name: 'match',
      parameters: {
        'matched_user_hash': matchedUserId ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Profile Events (GDPR compliant)

  /// Log profile view event
  Future<void> logProfileView({String? viewedUserId}) async {
    await logEvent(
      name: 'profile_view',
      parameters: {
        'viewed_user_hash': viewedUserId ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log profile edit event
  Future<void> logProfileEdit({String? editType}) async {
    await logEvent(
      name: 'profile_edit',
      parameters: {'edit_type': editType ?? 'general'},
    );
  }

  /// Log photo upload event
  Future<void> logPhotoUpload() async {
    await logEvent(name: 'photo_upload');
  }

  // Filter Events

  /// Log filter apply event
  Future<void> logFilterApply({int? filterCount}) async {
    await logEvent(
      name: 'filter_apply',
      parameters: {'filter_count': filterCount ?? 0},
    );
  }

  /// Log filter reset event
  Future<void> logFilterReset() async {
    await logEvent(name: 'filter_reset');
  }

  // Social Events (GDPR compliant)

  /// Log WhatsApp chat initiation
  Future<void> logWhatsAppChat({String? targetUserId}) async {
    await logEvent(
      name: 'whatsapp_chat',
      parameters: {
        'target_user_hash': targetUserId ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log LinkedIn profile view
  Future<void> logLinkedInView({String? targetUserId}) async {
    await logEvent(
      name: 'linkedin_view',
      parameters: {
        'target_user_hash': targetUserId ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log Instagram profile view
  Future<void> logInstagramView({String? targetUserId}) async {
    await logEvent(
      name: 'instagram_view',
      parameters: {
        'target_user_hash': targetUserId ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Report/Block Events (GDPR compliant)

  /// Log report user event (user ID is hashed)
  Future<void> logReportUser({
    String? reportedUserId,
    String? reportReason,
  }) async {
    await logEvent(
      name: 'report_user',
      parameters: {
        'reported_user_hash': reportedUserId ?? 'unknown',
        'reason': reportReason ?? 'other',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log block user event (user ID is hashed)
  Future<void> logBlockUser({String? blockedUserId}) async {
    await logEvent(
      name: 'block_user',
      parameters: {
        'blocked_user_hash': blockedUserId ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  // Search/Discovery Events

  /// Log search event
  Future<void> logSearch({String? searchQuery}) async {
    await logEvent(
      name: 'search',
      parameters: {'search_term': searchQuery ?? ''},
    );
  }

  // Screen View Events

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    // Debug modunda screen view loglamayı atla
    if (!kReleaseMode || !_initialized) return;

    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // User Properties (GDPR compliant)

  /// Set user ID (hashed for privacy)
  Future<void> setUserId(String userId) async {
    if (!kReleaseMode || !_initialized) return;

    try {
      // Hash the user ID before setting it in Analytics
      final hashedId = _hashUserId(userId);
      await _analytics.setUserId(id: hashedId);
      log('Hashed user ID set in Analytics');
    } catch (e) {
      log('Failed to set user ID: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!kReleaseMode || !_initialized) return;

    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      log('Failed to set user property: $e');
    }
  }

  /// Set user properties (demographic info)
  Future<void> setUserProperties({
    String? gender,
    int? age,
    String? country,
    String? profession,
  }) async {
    if (gender != null) {
      await setUserProperty(name: 'gender', value: gender);
    }
    if (age != null) {
      await setUserProperty(name: 'age', value: age.toString());
    }
    if (country != null) {
      await setUserProperty(name: 'country', value: country);
    }
    if (profession != null) {
      await setUserProperty(name: 'profession', value: profession);
    }
  }

  /// Enable/disable analytics collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    if (!kReleaseMode || !_initialized) return;

    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      log('Analytics collection ${enabled ? "enabled" : "disabled"}');
    } catch (e) {
      log('Failed to set analytics collection: $e');
    }
  }

  /// Reset analytics data
  Future<void> resetAnalyticsData() async {
    if (!kReleaseMode || !_initialized) return;

    try {
      await _analytics.resetAnalyticsData();
      log('Analytics data reset');
    } catch (e) {
      log('Failed to reset analytics data: $e');
    }
  }

  /// Check if Analytics is initialized
  bool get isInitialized => _initialized;
}

/// Global instance for easy access
final analyticsService = AnalyticsService();
