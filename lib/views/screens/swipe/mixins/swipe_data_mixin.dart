import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/models/person.dart';

/// SwipeController için data fetching ve cache mantığını içerir
mixin SwipeDataMixin on GetxController {
  RxList<Person> allUsersProfileList = <Person>[].obs;
  RxString senderName = "".obs;

  final Rx<DateTime> _lastQueryTime = DateTime.now().obs;
  final RxInt _queryCount = 0.obs;
  final RxBool _isBatchProcessing = false.obs;
  final RxInt _batchSize = 10.obs;

  String get currentUserId;

  // Public getters
  RxBool get isBatchProcessing => _isBatchProcessing;
  RxInt get batchSize => _batchSize;
  DateTime get lastQueryTime => _lastQueryTime.value;
  int get queryCount => _queryCount.value;

  /// Mevcut kullanıcının verilerini okur
  Future<void> readCurrentUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .get();

      if (snapshot.exists) {
        senderName.value =
            (snapshot.data() as Map<String, dynamic>)['name'] ?? '';
        log('Current user data loaded: ${senderName.value}');
      }
    } catch (e) {
      log("Error reading current user data: $e");
    }
  }

  /// Tüm kullanıcıları getirir (filtrelenmemiş)
  Future<List<Person>> fetchAllUsers({
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      // Rate limiting
      if (!_checkRateLimit()) {
        log('Rate limit exceeded, waiting...');
        await Future.delayed(const Duration(seconds: 2));
      }

      Query query = FirebaseFirestore.instance
          .collection("users")
          .where("uid", isNotEqualTo: currentUserId);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      _updateRateLimit();

      List<Person> users = [];
      for (var doc in querySnapshot.docs) {
        try {
          users.add(Person.fromDataSnapshot(doc));
        } catch (e) {
          log('Error parsing user document ${doc.id}: $e');
        }
      }

      log('Fetched ${users.length} users from Firestore');
      return users;
    } catch (e) {
      log('Error fetching all users: $e');
      return [];
    }
  }

  /// Kullanıcı listesini yeniler
  Future<void> refreshUserList() async {
    try {
      _isBatchProcessing.value = true;

      final users = await fetchAllUsers(limit: _batchSize.value);
      allUsersProfileList.assignAll(users);

      log('User list refreshed: ${users.length} users');
    } catch (e) {
      log('Error refreshing user list: $e');
    } finally {
      _isBatchProcessing.value = false;
    }
  }

  /// Daha fazla kullanıcı yükler (pagination)
  Future<void> loadMoreUsers() async {
    if (_isBatchProcessing.value) return;

    try {
      _isBatchProcessing.value = true;

      DocumentSnapshot? lastDoc;
      if (allUsersProfileList.isNotEmpty) {
        // Son kullanıcının document'ini bul
        final lastUser = allUsersProfileList.last;
        final docSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(lastUser.uid)
            .get();
        lastDoc = docSnapshot;
      }

      final moreUsers = await fetchAllUsers(
        limit: _batchSize.value,
        startAfter: lastDoc,
      );

      if (moreUsers.isNotEmpty) {
        allUsersProfileList.addAll(moreUsers);
        log('Loaded ${moreUsers.length} more users');
      } else {
        log('No more users to load');
      }
    } catch (e) {
      log('Error loading more users: $e');
    } finally {
      _isBatchProcessing.value = false;
    }
  }

  /// Belirli bir kullanıcının detaylarını getirir
  Future<Person?> fetchUserDetails(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();

      if (doc.exists) {
        return Person.fromDataSnapshot(doc);
      }
      return null;
    } catch (e) {
      log('Error fetching user details: $e');
      return null;
    }
  }

  /// Cache'i temizler
  void clearCache() {
    allUsersProfileList.clear();
    _queryCount.value = 0;
    _lastQueryTime.value = DateTime.now();
    log('Cache cleared');
  }

  /// Batch size'ı günceller
  void updateBatchSize(int newSize) {
    if (newSize > 0 && newSize <= 50) {
      _batchSize.value = newSize;
      log('Batch size updated to $newSize');
    }
  }

  // Private helper methods

  /// Rate limiting kontrolü
  bool _checkRateLimit() {
    final now = DateTime.now();
    final timeSinceLastQuery = now.difference(_lastQueryTime.value);

    // Son 10 saniyede 5'ten fazla sorgu yapılmışsa bekle
    if (timeSinceLastQuery.inSeconds < 10 && _queryCount.value >= 5) {
      return false;
    }

    // 10 saniye geçmişse sayacı sıfırla
    if (timeSinceLastQuery.inSeconds >= 10) {
      _queryCount.value = 0;
      _lastQueryTime.value = now;
    }

    return true;
  }

  /// Rate limit sayacını günceller
  void _updateRateLimit() {
    _queryCount.value++;
    if (_queryCount.value == 1) {
      _lastQueryTime.value = DateTime.now();
    }
  }

  /// Kullanıcıyı listeden kaldırır
  void removeUserFromList(String userId) {
    allUsersProfileList.removeWhere((user) => user.uid == userId);
    log('User $userId removed from list');
  }

  /// Belirli kullanıcıları listeden kaldırır
  void removeUsersFromList(List<String> userIds) {
    allUsersProfileList.removeWhere((user) => userIds.contains(user.uid));
    log('${userIds.length} users removed from list');
  }

  /// Kullanıcı listesini filtreler
  List<Person> filterUsers({
    required bool Function(Person) predicate,
  }) {
    return allUsersProfileList.where(predicate).toList();
  }

  /// İstatistik bilgilerini döndürür
  Map<String, dynamic> getStats() {
    return {
      'totalUsers': allUsersProfileList.length,
      'queryCount': _queryCount.value,
      'lastQueryTime': _lastQueryTime.value.toIso8601String(),
      'batchSize': _batchSize.value,
      'isProcessing': _isBatchProcessing.value,
    };
  }
}
