import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/constants/firestore_constants.dart';

/// Service to handle user blocking operations efficiently
/// Fixes N+1 query problem by batching blocked user checks
class UserBlockingService {
  static final UserBlockingService _instance = UserBlockingService._internal();
  factory UserBlockingService() => _instance;
  UserBlockingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for blocked users to reduce repeated queries
  final Map<String, Set<String>> _blockedUsersCache = {};
  final Map<String, Set<String>> _blockedByUsersCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// Get all users blocked by the current user (optimized - single query)
  Future<Set<String>> getBlockedUserIds(String currentUserId) async {
    try {
      // Check cache first
      if (_isCacheValid(currentUserId, _blockedUsersCache)) {
        log('Using cached blocked users for $currentUserId');
        return _blockedUsersCache[currentUserId]!;
      }

      log('Fetching blocked users for $currentUserId');
      final snapshot = await _firestore
          .collection(FirestoreConstants.users)
          .doc(currentUserId)
          .collection(FirestoreConstants.blockedUsers)
          .get();

      final blockedIds = snapshot.docs.map((doc) => doc.id).toSet();

      // Update cache
      _blockedUsersCache[currentUserId] = blockedIds;
      _cacheTimestamps['blocked_$currentUserId'] = DateTime.now();

      log('Found ${blockedIds.length} blocked users');
      return blockedIds;
    } catch (e, stackTrace) {
      log('Error fetching blocked users: $e');
      log('Stack trace: $stackTrace');
      return {};
    }
  }

  /// Get all users that have blocked the current user (optimized with workaround)
  /// Note: This requires a "blockedBy" collection or we need collectionGroup query
  Future<Set<String>> getUsersThatBlockedMe(String currentUserId) async {
    try {
      // Check cache first
      if (_isCacheValid(currentUserId, _blockedByUsersCache)) {
        log('Using cached blockedBy users for $currentUserId');
        return _blockedByUsersCache[currentUserId]!;
      }

      log('Fetching users that blocked $currentUserId');

      // Option 1: Use collectionGroup query (requires composite index)
      // This is more efficient but needs proper indexing
      try {
        final snapshot = await _firestore
            .collectionGroup(FirestoreConstants.blockedUsers)
            .where(FieldPath.documentId, isEqualTo: currentUserId)
            .get();

        final blockedByIds =
            snapshot.docs.map((doc) => doc.reference.parent.parent!.id).toSet();

        // Update cache
        _blockedByUsersCache[currentUserId] = blockedByIds;
        _cacheTimestamps['blockedBy_$currentUserId'] = DateTime.now();

        log('Found ${blockedByIds.length} users that blocked me');
        return blockedByIds;
      } catch (indexError) {
        log('CollectionGroup query failed (may need index): $indexError');
        // Fallback: Return empty set (will be checked individually if needed)
        // In production, create a "blockedBy" collection when blocking
        return {};
      }
    } catch (e, stackTrace) {
      log('Error fetching users that blocked me: $e');
      log('Stack trace: $stackTrace');
      return {};
    }
  }

  /// Check if cache is still valid
  bool _isCacheValid(String userId, Map<String, Set<String>> cache) {
    if (!cache.containsKey(userId)) return false;

    final cacheKey =
        cache == _blockedUsersCache ? 'blocked_$userId' : 'blockedBy_$userId';

    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  /// Check if a specific user is blocked (uses cache)
  Future<bool> isUserBlocked(String currentUserId, String targetUserId) async {
    final blockedUsers = await getBlockedUserIds(currentUserId);
    return blockedUsers.contains(targetUserId);
  }

  /// Check if current user is blocked by target user (uses cache)
  Future<bool> hasUserBlockedMe(
      String currentUserId, String targetUserId) async {
    final usersWhoBlockedMe = await getUsersThatBlockedMe(currentUserId);
    return usersWhoBlockedMe.contains(targetUserId);
  }

  /// Block a user
  Future<void> blockUser(String currentUserId, String targetUserId,
      {String? reason}) async {
    try {
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(currentUserId)
          .collection(FirestoreConstants.blockedUsers)
          .doc(targetUserId)
          .set({
        'blockedAt': FieldValue.serverTimestamp(),
        'reason': reason ?? 'No reason provided',
      });

      // Also create reverse reference for efficient queries
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(targetUserId)
          .collection('blockedBy')
          .doc(currentUserId)
          .set({
        'blockedAt': FieldValue.serverTimestamp(),
      });

      // Clear cache
      _blockedUsersCache.remove(currentUserId);
      _blockedByUsersCache.remove(targetUserId);
      _cacheTimestamps.remove('blocked_$currentUserId');
      _cacheTimestamps.remove('blockedBy_$targetUserId');

      log('Successfully blocked user: $targetUserId');
    } catch (e, stackTrace) {
      log('Error blocking user: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Unblock a user
  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(currentUserId)
          .collection(FirestoreConstants.blockedUsers)
          .doc(targetUserId)
          .delete();

      // Remove reverse reference
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(targetUserId)
          .collection('blockedBy')
          .doc(currentUserId)
          .delete();

      // Clear cache
      _blockedUsersCache.remove(currentUserId);
      _blockedByUsersCache.remove(targetUserId);
      _cacheTimestamps.remove('blocked_$currentUserId');
      _cacheTimestamps.remove('blockedBy_$targetUserId');

      log('Successfully unblocked user: $targetUserId');
    } catch (e, stackTrace) {
      log('Error unblocking user: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Clear all caches (call on logout)
  void clearCache() {
    _blockedUsersCache.clear();
    _blockedByUsersCache.clear();
    _cacheTimestamps.clear();
    log('User blocking cache cleared');
  }
}

/// Global instance for easy access
final userBlockingService = UserBlockingService();
