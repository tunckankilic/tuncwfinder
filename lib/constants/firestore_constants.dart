/// Firestore collection names and query constants
class FirestoreConstants {
  // Collection names
  static const String users = 'users';
  static const String likeSent = 'likeSent';
  static const String likeReceived = 'likeReceived';
  static const String favoriteSent = 'favoriteSent';
  static const String favoriteReceived = 'favoriteReceived';
  static const String viewSent = 'viewSent';
  static const String viewReceived = 'viewReceived';
  static const String blockedUsers = 'blockedUsers';
  static const String processedUsers = 'processedUsers';
  static const String reports = 'reports';
  static const String analytics = 'analytics';

  // Query limits - optimized for performance
  static const int defaultUserQueryLimit = 20; // Instead of 100
  static const int maxUserQueryLimit = 50;
  static const int minUserQueryLimit = 10;

  // Rate limiting
  static const int maxQueriesPerInterval = 5;
  static const Duration rateLimitInterval = Duration(seconds: 10);

  // Cache durations
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration profileCacheExpiration = Duration(minutes: 30);
}
