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

  //notification arrived/received
  Future whenNotificationReceived(BuildContext context) async {
    //1. Terminated
    //When the app is completely closed and opened directly from the push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //open app and show notification data
        openAppAndShowNotificationData(
          remoteMessage.data["userID"],
          remoteMessage.data["senderID"],
          context,
        );
      }
    });

    //2. Foreground
    //When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //open app and show notification data
        openAppAndShowNotificationData(
          remoteMessage.data["userID"],
          remoteMessage.data["senderID"],
          context,
        );
      }
    });

    //3. Background
    //When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //open app and show notification data
        openAppAndShowNotificationData(
          remoteMessage.data["userID"],
          remoteMessage.data["senderID"],
          context,
        );
      }
    });
  }

  openAppAndShowNotificationData(receiverID, senderID, context) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(senderID)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        String profileImage = data["imageProfile"]?.toString() ?? "";
        String name = data["name"]?.toString() ?? "";
        String age = data["age"]?.toString() ?? "";
        String city = data["city"]?.toString() ?? "";
        String country = data["country"]?.toString() ?? "";
        String profession = data["profession"]?.toString() ?? "";

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
    }
  }

  notificationDialogBox(
      senderID, profileImage, name, age, city, country, profession, context) {
    return Get.dialog(
      Dialog(
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
                          //name - age
                          Text(
                            name + " ● " + age.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          //icon - city country location
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
                                  city + ", " + country.toString(),
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

                          // 2 button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();

                                    Get.to(() => UserDetails(userId: senderID));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text("View Profile"),
                                ),
                              ),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
                                  child: const Text("Close"),
                                ),
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
      ),
    );
  }

  Future generateDeviceRegistrationToken() async {
    String? deviceToken = await messaging.getToken();
    String? userId = currentUserId;

    if (userId != null) {
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "userDeviceToken": deviceToken,
      });
    } else {
      print('User not logged in, cannot update device token');
    }
  }
}
