import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class PushNotificationSystem extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      whenNotificationReceived(Get.context!);
    });
  }

  Future<void> whenNotificationReceived(BuildContext context) async {
    try {
      // 1. Terminated
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        await openAppAndShowNotificationData(
          initialMessage.data["userID"],
          initialMessage.data["senderID"],
          context,
        );
      }

      // 2. Foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        await openAppAndShowNotificationData(
          message.data["userID"],
          message.data["senderID"],
          context,
        );
      });

      // 3. Background
      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        await openAppAndShowNotificationData(
          message.data["userID"],
          message.data["senderID"],
          context,
        );
      });
    } catch (e) {
      print('Error in whenNotificationReceived: $e');
      // You might want to show an error message to the user here
    }
  }

  Future<void> openAppAndShowNotificationData(
      String? receiverID, String? senderID, BuildContext context) async {
    if (senderID == null) {
      print('Sender ID is null');
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(senderID)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        String profileImage = data["imageProfile"] ?? "";
        String name = data["name"] ?? "";
        String age = data["age"]?.toString() ?? "";
        String city = data["city"] ?? "";
        String country = data["country"] ?? "";
        String profession = data["profession"] ?? "";

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return notificationDialogBox(
                senderID,
                profileImage,
                name,
                age,
                city,
                country,
                profession,
                context,
              );
            },
          );
        }
      } else {
        print('User data not found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // You might want to show an error message to the user here
    }
  }

  Widget notificationDialogBox(
      String senderID,
      String profileImage,
      String name,
      String age,
      String city,
      String country,
      String profession,
      BuildContext context) {
    return Dialog(
      child: GridTile(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: 300,
            child: Card(
              color: Colors.blue.shade200,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: NetworkImage(profileImage),
                  fit: BoxFit.cover,
                )),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$name ● $age",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                "$city, $country",
                                maxLines: 4,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                                Get.to(() => UserDetails(userId: senderID));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text("View Profile"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent),
                              child: const Text("Close"),
                            ),
                          ],
                        ),
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

  Future<void> generateDeviceRegistrationToken() async {
    try {
      String? deviceToken = await messaging.getToken();
      String? userId = currentUserId;

      if (userId != null && deviceToken != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .update({
          "userDeviceToken": deviceToken,
        });
      } else {
        print(
            'User not logged in or device token is null, cannot update device token');
      }
    } catch (e) {
      print('Error generating device registration token: $e');
      // You might want to show an error message to the user here
    }
  }
}
