import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/service/user_blocking_service.dart';

/// SwipeController için action mantığını içerir (like, dislike, favorite, block)
mixin SwipeActionMixin on GetxController {
  final RxBool _isProcessing = false.obs;
  final Map<String, DateTime> _lastBlockTimes = {};
  final Set<String> _processedUserIds = <String>{};
  final Set<String> _swipedUserIds = <String>{};

  RxBool get isProcessing => _isProcessing;
  Set<String> get processedUserIds => _processedUserIds;
  Set<String> get swipedUserIds => _swipedUserIds;

  String get currentUserId;
  String get senderNameValue;

  /// İşlenmiş kullanıcıları yükler
  Future<void> loadProcessedUsers() async {
    try {
      final processedDocs = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("processedUsers")
          .get();

      for (var doc in processedDocs.docs) {
        _processedUserIds.add(doc.id);
      }

      log("Loaded ${_processedUserIds.length} processed users");
    } catch (e) {
      log("Error loading processed users: $e");
    }
  }

  /// Kullanıcıyı işlenmiş olarak işaretler
  Future<void> markUserAsProcessed(String userId, String action) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("processedUsers")
          .doc(userId)
          .set({
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
        'processedAt': DateTime.now().millisecondsSinceEpoch,
      });

      _processedUserIds.add(userId);
      _swipedUserIds.add(userId);
    } catch (e) {
      log("Error marking user as processed: $e");
    }
  }

  /// Like action
  Future<void> likeAction(String userId) async {
    if (_isProcessing.value) return;

    try {
      _isProcessing.value = true;

      // Like sent
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("likeSent")
          .doc(userId)
          .set({});

      // Like received
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("likeReceived")
          .doc(currentUserId)
          .set({"name": senderNameValue});

      // Mark as processed
      await markUserAsProcessed(userId, 'like');

      log('Like sent to $userId');
    } catch (e) {
      log('Error in likeAction: $e');
    } finally {
      _isProcessing.value = false;
    }
  }

  /// Dislike action
  Future<void> dislikeAction(String userId) async {
    if (_isProcessing.value) return;

    try {
      _isProcessing.value = true;

      // Mark as processed (no other action needed for dislike)
      await markUserAsProcessed(userId, 'dislike');

      log('Dislike processed for $userId');
    } catch (e) {
      log('Error in dislikeAction: $e');
    } finally {
      _isProcessing.value = false;
    }
  }

  /// Favorite action
  Future<void> favoriteAction(String userId) async {
    if (_isProcessing.value) return;

    try {
      _isProcessing.value = true;

      // Favorite sent
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("favoriteSent")
          .doc(userId)
          .set({});

      // Favorite received
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("favoriteReceived")
          .doc(currentUserId)
          .set({"name": senderNameValue});

      // Mark as processed
      await markUserAsProcessed(userId, 'favorite');

      log('Favorite sent to $userId');
    } catch (e) {
      log('Error in favoriteAction: $e');
    } finally {
      _isProcessing.value = false;
    }
  }

  /// Block action (now uses UserBlockingService for efficiency)
  Future<void> blockUser(String userId, String reason) async {
    if (_isProcessing.value) return;

    // Rate limiting check
    if (_lastBlockTimes.containsKey(userId)) {
      final lastTime = _lastBlockTimes[userId]!;
      final now = DateTime.now();
      if (now.difference(lastTime).inMinutes < 5) {
        Get.snackbar(
          'Uyarı',
          'Bu kullanıcıyı çok yakın zamanda engellediniz.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    try {
      _isProcessing.value = true;

      // Use UserBlockingService for optimized blocking with cache management
      await userBlockingService.blockUser(currentUserId, userId,
          reason: reason);

      // Mark as processed
      await markUserAsProcessed(userId, 'block');

      // Update rate limiting
      _lastBlockTimes[userId] = DateTime.now();

      log('User $userId blocked via UserBlockingService');

      Get.snackbar(
        'Başarılı',
        'Kullanıcı engellendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      log('Error in blockUser: $e');
      Get.snackbar(
        'Hata',
        'Kullanıcı engellenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  /// Report user
  Future<void> reportUser(
    String userId,
    String reportReason,
    String? additionalInfo,
  ) async {
    if (_isProcessing.value) return;

    try {
      _isProcessing.value = true;

      await FirebaseFirestore.instance.collection("reports").add({
        'reporterId': currentUserId,
        'reportedUserId': userId,
        'reason': reportReason,
        'additionalInfo': additionalInfo ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      log('User $userId reported');

      Get.snackbar(
        'Başarılı',
        'Kullanıcı rapor edildi. İncelenecektir.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      log('Error in reportUser: $e');
      Get.snackbar(
        'Hata',
        'Rapor gönderilirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  /// Batch swipe işlemleri
  Future<void> processBatchSwipe(
    List<Map<String, dynamic>> swipeActions,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection("users");

      for (var action in swipeActions) {
        final String targetUserId = action['userId'];
        final String actionType = action['action'];
        final String senderName = action['senderName'];

        // Mark as processed
        batch.set(
          userRef
              .doc(currentUserId)
              .collection("processedUsers")
              .doc(targetUserId),
          {
            'action': actionType,
            'timestamp': FieldValue.serverTimestamp(),
            'processedAt': DateTime.now().millisecondsSinceEpoch,
          },
        );

        // Process action
        switch (actionType) {
          case 'like':
            batch.set(
              userRef
                  .doc(currentUserId)
                  .collection("likeSent")
                  .doc(targetUserId),
              {'timestamp': FieldValue.serverTimestamp()},
            );
            batch.set(
              userRef
                  .doc(targetUserId)
                  .collection("likeReceived")
                  .doc(currentUserId),
              {
                'name': senderName,
                'timestamp': FieldValue.serverTimestamp(),
              },
            );
            break;

          case 'favorite':
            batch.set(
              userRef
                  .doc(currentUserId)
                  .collection("favoriteSent")
                  .doc(targetUserId),
              {'timestamp': FieldValue.serverTimestamp()},
            );
            batch.set(
              userRef
                  .doc(targetUserId)
                  .collection("favoriteReceived")
                  .doc(currentUserId),
              {
                'name': senderName,
                'timestamp': FieldValue.serverTimestamp(),
              },
            );
            break;

          case 'dislike':
            // No additional action needed
            break;
        }

        _processedUserIds.add(targetUserId);
        _swipedUserIds.add(targetUserId);
      }

      await batch.commit();
      log("Batch swipe processed: ${swipeActions.length} actions");
    } catch (e) {
      log("Error in batch swipe: $e");
      rethrow;
    }
  }
}
