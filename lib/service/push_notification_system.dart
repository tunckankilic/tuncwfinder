import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncdating/service/global.dart';
import 'package:tuncdating/views/screens/screens.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //Notication Status ( Arrived - Received )
  Future whenNotificationReceived(BuildContext context) async {
    //1. Terminated
    //When the app is completely closed and opened directly from the push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //Open app and Show Notification Details
        openAppAndShowNotificationData(
            userId: remoteMessage.data["userId"],
            senderId: remoteMessage.data["senderId"],
            context: context);
      }
    });

    //2. Foreground
    //When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //Open app and Show Notification Details
        openAppAndShowNotificationData(
            userId: remoteMessage.data["userId"],
            senderId: remoteMessage.data["senderId"],
            context: context);
      }
    });

    //3. Background
    //When the app is in the background and opened directly from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //Open app and Show Notification Details
        openAppAndShowNotificationData(
            userId: remoteMessage.data["userId"],
            senderId: remoteMessage.data["senderId"],
            context: context);
      }
    });
  }

  void openAppAndShowNotificationData({
    required userId,
    required senderId,
    required BuildContext context,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(senderId)
        .get()
        .then((snapshot) {
      String profileImage = snapshot.data()!["imageProfile"].toString();
      String name = snapshot.data()!["name"].toString();
      String age = snapshot.data()!["age"].toString();
      String city = snapshot.data()!["city"].toString();
      String country = snapshot.data()!["country"].toString();
      String profession = snapshot.data()!["profession"].toString();
      showDialog(
          context: context,
          builder: (context) {
            return notificationDialogBox(
              senderId,
              profileImage,
              name,
              age,
              city,
              country,
              profession,
              context,
            );
          });
    });
  }

  Future generateDeviceRegistrationToken() async {
    String? deviceToken = await messaging.getToken();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .update({
      "userDeviceToken": deviceToken,
    });
  }
}

Widget notificationDialogBox(senderId, profileImage, name, age, city, country,
    profession, BuildContext context) {
  return Dialog(
    child: GridTile(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: SizedBox(
          height: 300,
          child: Card(
            color: Colors.red,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(profileImage), fit: BoxFit.cover),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      infoColumn(name, age, context, city, country),
                      const Spacer(),
                      navigationButtons(senderId),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Column infoColumn(name, age, BuildContext context, city, country) {
  return Column(
    children: [
      Text(
        "$name *** $age",
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(
        height: 8,
      ),
      Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(
            width: 2,
          ),
          Expanded(
            child: Text(
              "$city *** $country",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    ],
  );
}

Row navigationButtons(senderId) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Center(
        child: ElevatedButton(
          onPressed: () {
            Get.back();
            Get.toNamed(UserDetails.routeName, arguments: senderId);
          },
          child: const Text("View Profile"),
        ),
      ),
      Center(
        child: ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("Back"),
        ),
      ),
    ],
  );
}
