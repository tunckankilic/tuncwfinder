import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncdating/models/person.dart';
import 'package:tuncdating/service/global.dart';
import 'package:http/http.dart' as http;
import 'package:tuncdating/views/screens/auth/pages/screens.dart';

class ProfileController extends GetxController {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);
  List<Person> get allUsersProfileList => usersProfileList.value;
  getResults() {
    onInit();
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  @override
  void onInit() {
    super.onInit();

    if (chosenGender == null || chosenCountry == null || chosenAge == null) {
      usersProfileList.bindStream(FirebaseFirestore.instance
          .collection("users")
          .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .map((QuerySnapshot queryDataSnapshot) {
        List<Person> profilesList = [];

        for (var eachProfile in queryDataSnapshot.docs) {
          profilesList.add(Person.fromDataSnapshot(eachProfile));
        }
        return profilesList;
      }));
    } else {
      usersProfileList.bindStream(FirebaseFirestore.instance
          .collection("users")
          .where("gender", isEqualTo: chosenGender.toString().toLowerCase())
          .where("country", isEqualTo: chosenCountry.toString())
          .where("age", isGreaterThanOrEqualTo: int.parse(chosenAge.toString()))
          .snapshots()
          .map((QuerySnapshot queryDataSnapshot) {
        List<Person> profilesList = [];

        for (var eachProfile in queryDataSnapshot.docs) {
          profilesList.add(Person.fromDataSnapshot(eachProfile));
        }
        return profilesList;
      }));
    }
  }

  favoriteSentAndFavoriteReceived(
      {required String toUserID, required String senderName}) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection("favoriteReceived")
        .doc(currentUserId)
        .get();

    //remove the favorite from database
    if (document.exists) {
      //remove currentUserId from the favoriteReceived list of that profile person [toUserID]
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(currentUserId)
          .delete();

      //remove profile person [toUserID] from the favoriteSent list of the currentUser
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("favoriteSent")
          .doc(toUserID)
          .delete();
    } else //mark as favorite //add favorite in database
    {
      //add currentUserId to the favoriteReceived list of that profile person [toUserID]
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(currentUserId)
          .set({});

      //add profile person [toUserID] to the favoriteSent list of the currentUser
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("favoriteSent")
          .doc(toUserID)
          .set({});

      //send notification
      sendNotificationToUser(toUserID, "Favorite", senderName);
    }

    update();
  }

  viewSentAndViewReceived(
      {required String toUserId, required String senderName}) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserId)
        .collection("viewReceived")
        .doc(currentUserId)
        .get();

    //remove the likes from database
    if (document.exists) {
      //remove currentUserId from the favoriteReceived list of that profile person [toUserID]
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserId)
          .collection("viewReceived")
          .doc(currentUserId)
          .delete();

      //remove profile person [toUserID] from the likeSent list of the currentUser
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("viewSent")
          .doc(toUserId)
          .delete();
    } else //mark as Liked //add Liked in database
    {
      //add currentUserId to the likeReceived list of that profile person [toUserID]
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserId)
          .collection("viewReceived")
          .doc(currentUserId)
          .set({});

      //add profile person [toUserID] to the likeSent list of the currentUser
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("viewSent")
          .doc(toUserId)
          .set({});

      //send notification
      sendNotificationToUser(toUserId, "Viewe", senderName);
    }

    update();
  }

  likeSentAndLikeReceived(
      {required String toUserId, required String senderName}) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserId)
        .collection("likeReceived")
        .doc(currentUserId)
        .get();

    //remove the likes from database
    if (document.exists) {
      //remove currentUserId from the favoriteReceived list of that profile person [toUserID]
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserId)
          .collection("likeReceived")
          .doc(currentUserId)
          .delete();

      //remove profile person [toUserID] from the likeSent list of the currentUser
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("likeSent")
          .doc(toUserId)
          .delete();
    } else //mark as Liked //add Liked in database
    {
      //add currentUserId to the likeReceived list of that profile person [toUserID]
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserId)
          .collection("likeReceived")
          .doc(currentUserId)
          .set({});

      //add profile person [toUserID] to the likeSent list of the currentUser
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("likeSent")
          .doc(toUserId)
          .set({});

      //send notification
      sendNotificationToUser(toUserId, "Like", senderName);
    }

    update();
  }

  sendNotificationToUser(receiverID, featureType, senderName) async {
    String userDeviceToken = "";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(receiverID)
        .get()
        .then((snapshot) {
      if (snapshot.data()!["userDeviceToken"] != null) {
        userDeviceToken = snapshot.data()!["userDeviceToken"].toString();
      }
    });

    notificationFormat(
      userDeviceToken,
      receiverID,
      featureType,
      senderName,
    );
  }

  notificationFormat(
    userDeviceToken,
    receiverID,
    featureType,
    senderName,
  ) {
    Map<String, String> headerNotification = {
      "Content-Type": "application/json",
      "Authorization": fcmServerToken,
    };

    Map bodyNotification = {
      "body":
          "you have received a new $featureType from $senderName. Click to see.",
      "title": "New $featureType",
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "userID": receiverID,
      "senderID": currentUserId,
    };

    Map notificationOfficialFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": userDeviceToken,
    };

    http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(notificationOfficialFormat),
    );
  }
}
