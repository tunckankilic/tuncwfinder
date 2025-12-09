import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/views/screens/auth/pages/screens.dart';
import 'package:tuncforwork/views/screens/swipe/mixins/swipe_filter_mixin.dart';

class ProfileController extends GetxController with SwipeFilterMixin {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);
  List<Person> get allUsersProfileList => usersProfileList.value;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final String currentUserId;

  @override
  void onInit() {
    super.onInit();
    currentUserId = _auth.currentUser?.uid ?? '';
    _initializeProfileStream();
  }

  Future<void> _initializeProfileStream() async {
    Query query = _firestore
        .collection("users")
        .where("uid", isNotEqualTo: _auth.currentUser!.uid);

    if (chosenGender.value.isNotEmpty &&
        chosenCountry.value.isNotEmpty &&
        chosenAge.value.isNotEmpty) {
      query = query
          .where("gender", isEqualTo: chosenGender.value.toLowerCase())
          .where("country", isEqualTo: chosenCountry.value)
          .where("age", isGreaterThanOrEqualTo: int.parse(chosenAge.value));
    }

    usersProfileList.bindStream(query.snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) {
            try {
              return Person.fromDataSnapshot(doc);
            } catch (e) {
              log('Error parsing user document ${doc.id}: $e');
              return null;
            }
          })
          .where((person) => person != null)
          .cast<Person>()
          .toList();
    }));
  }

  Future<void> signOut() async {
    await _auth.signOut();
    Get.offAllNamed(LoginScreen.routeName);
  }

  Future<void> toggleFavorite(
      {required String toUserID, required String senderName}) async {
    await _toggleInteraction(
      toUserID: toUserID,
      senderName: senderName,
      interactionType: "favorite",
      notificationType: "Favorite",
    );
  }

  Future<void> toggleView(
      {required String toUserId, required String senderName}) async {
    await _toggleInteraction(
      toUserID: toUserId,
      senderName: senderName,
      interactionType: "view",
      notificationType: "View",
    );
  }

  Future<void> toggleLike(
      {required String toUserId, required String senderName}) async {
    await _toggleInteraction(
      toUserID: toUserId,
      senderName: senderName,
      interactionType: "like",
      notificationType: "Like",
    );
  }

  Future<void> _toggleInteraction({
    required String toUserID,
    required String senderName,
    required String interactionType,
    required String notificationType,
  }) async {
    final receivedRef = _firestore
        .collection("users")
        .doc(toUserID)
        .collection("${interactionType}Received")
        .doc(currentUserId);
    final sentRef = _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("${interactionType}Sent")
        .doc(toUserID);

    final exists = await receivedRef.get().then((doc) => doc.exists);

    if (exists) {
      await Future.wait([receivedRef.delete(), sentRef.delete()]);
    } else {
      await Future.wait([receivedRef.set({}), sentRef.set({})]);
      await sendNotificationToUser(toUserID, notificationType, senderName);
    }

    update();
  }

  // Notification sistemi kaldırıldı (performans için)
  // Bildirimler artık gönderilmiyor, sadece Firestore'a kaydediliyor
  Future<void> sendNotificationToUser(
      String receiverID, String featureType, String senderName) async {
    try {
      if (currentUserId.isEmpty) {
        log('Current user ID is empty');
        return;
      }

      // Bildirim sistemi kaldırıldı - sadece log tutuyoruz
      log(' Notification disabled: $featureType from $senderName to $receiverID');
      log(' Push notification system removed for better performance');

      // İleride tekrar aktif etmek isterseniz:
      // 1. firebase_messaging ve cloud_functions paketlerini geri ekleyin
      // 2. PushNotificationSystem sınıfını geri ekleyin
      // 3. Bu fonksiyonu eski haline getirin
    } catch (e) {
      log('Error in notification placeholder: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser?.uid).delete();
      await _auth.currentUser?.delete();
      // await logout();
      Get.snackbar('Success', 'Account deleted successfully');
    } catch (error) {
      Get.snackbar('Error', 'Failed to delete account: ${error.toString()}');
    }
  }
}

class SocialMediaErrorHandler {
  static String handleError(dynamic error) {
    if (error is FirebaseAuthException) {
      return 'Kimlik doğrulama hatası: ${error.message}';
    } else if (error is FirebaseException) {
      return 'Firebase hatası: ${error.message}';
    } else {
      return 'Beklenmeyen bir hata oluştu: $error';
    }
  }
}
