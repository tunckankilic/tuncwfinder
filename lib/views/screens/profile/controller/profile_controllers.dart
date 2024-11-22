import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:http/http.dart' as http;
import 'package:tuncforwork/views/screens/auth/pages/screens.dart';

class ProfileController extends GetxController {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);
  List<Person> get allUsersProfileList => usersProfileList.value;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeProfileStream();
  }

  Future<void> _initializeProfileStream() async {
    Query query = _firestore
        .collection("users")
        .where("uid", isNotEqualTo: _auth.currentUser!.uid);

    if (chosenGender != null && chosenCountry != null && chosenAge != null) {
      query = query
          .where("gender", isEqualTo: chosenGender.toString().toLowerCase())
          .where("country", isEqualTo: chosenCountry)
          .where("age",
              isGreaterThanOrEqualTo: int.parse(chosenAge.toString()));
    }

    usersProfileList.bindStream(query.snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Person.fromDataSnapshot(doc))
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

  Future<void> sendNotificationToUser(
      String receiverID, String featureType, String senderName) async {
    final userDeviceToken = await _firestore
        .collection("users")
        .doc(receiverID)
        .get()
        .then((snapshot) => snapshot.data()?["userDeviceToken"] as String?);

    if (userDeviceToken != null) {
      await _sendNotification(
          userDeviceToken, receiverID, featureType, senderName);
    }
  }

  Future<void> _sendNotification(String userDeviceToken, String receiverID,
      String featureType, String senderName) async {
    final url = Uri.parse("https://fcm.googleapis.com/fcm/send");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "key=$fcmServerToken",
    };

    final body = jsonEncode({
      "notification": {
        "body":
            "You have received a new $featureType from $senderName. Click to see.",
        "title": "New $featureType",
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "userID": receiverID,
        "senderID": currentUserId,
      },
      "priority": "high",
      "to": userDeviceToken,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode != 200) {
        log('Failed to send notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error sending notification: $e');
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
