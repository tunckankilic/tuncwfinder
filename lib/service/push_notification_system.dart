import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class PushNotificationSystem extends GetxController {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 1), () {
      _initializeNotifications();
    });
  }

  Future<void> generateDeviceRegistrationToken() async {
    try {
      print('Generating device registration token...');

      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        print('APNS Token: $apnsToken');

        // Simülatör kontrolü
        if (apnsToken ==
            '66616B652D61706E732D746F6B656E2D666F722D73696D756C61746F72') {
          print('Running on simulator, skipping FCM token generation');
          return;
        }
      }

      final token = await _messaging.getToken();
      print('FCM Token: $token');

      if (token != null) {
        final userId = currentUserId;
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .update({
            "userDeviceToken": token,
          });
          print('Device token successfully updated in Firestore');
        }
      }
    } catch (e, stack) {
      print('Error generating token: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      if (_isInitialized) return;

      print('Initializing push notification system...');

      // iOS için özel yapılandırma
      if (Platform.isIOS) {
        await _setupIOSNotifications();
      }

      // İzinleri kontrol et ve token üret
      await _setupNotifications();
    } catch (e, stack) {
      print('Error initializing push notification system: $e\n$stack');
      // Hata durumunda bile bildirimleri dinlemeye başla
      _setupNotificationListeners();
    }
  }

  Future<void> _setupIOSNotifications() async {
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // APNs settings
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      print('iOS notification settings configured');
    } catch (e) {
      print('Error setting up iOS notifications: $e');
    }
  }

  Future<void> _setupNotifications() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await _generateTokenWithFallback();
        _setupNotificationListeners();
        _isInitialized = true;
      }
    } catch (e, stack) {
      print('Error in _setupNotifications: $e\n$stack');
      // Hata durumunda bildirimleri yine de dinlemeye başla
      _setupNotificationListeners();
    }
  }

  Future<void> _generateTokenWithFallback() async {
    try {
      print('Attempting to generate device token...');

      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        print('APNS Token: $apnsToken');

        // Simülatör kontrolü
        if (apnsToken ==
            '66616B652D61706E732D746F6B656E2D666F722D73696D756C61746F72') {
          print('Running on simulator, skipping FCM token generation');
          return;
        }
      }

      final token = await _messaging.getToken();
      if (token != null) {
        await _updateTokenInFirestore(token);
      }
    } catch (e) {
      print('Error generating token: $e');
      // Token üretimi başarısız olsa bile devam et
    }
  }

  Future<void> _updateTokenInFirestore(String token) async {
    try {
      final userId = currentUserId;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .update({
          "userDeviceToken": token,
        });
        print('Device token successfully updated in Firestore');
      }
    } catch (e) {
      print('Error updating token in Firestore: $e');
    }
  }

  void _setupNotificationListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        whenNotificationReceived(Get.context!);
      }
    });
  }

  Future<void> whenNotificationReceived(BuildContext context) async {
    try {
      // 1. Terminated State
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        await _handleNotificationMessage(initialMessage, context);
      }

      // 2. Foreground State
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        await _handleNotificationMessage(message, context);
      });

      // 3. Background State
      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        await _handleNotificationMessage(message, context);
      });

      print('Notification listeners set up successfully');
    } catch (e) {
      print('Error setting up notification listeners: $e');
    }
  }

  Future<void> _handleNotificationMessage(
      RemoteMessage message, BuildContext context) async {
    try {
      final userID = message.data["userID"];
      final senderID = message.data["senderID"];

      if (senderID != null) {
        await openAppAndShowNotificationData(userID, senderID, context);
      } else {
        print('Sender ID is null in notification data');
      }
    } catch (e) {
      print('Error handling notification message: $e');
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

      if (!context.mounted) {
        print('Context is no longer mounted');
        return;
      }

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        await _showNotificationDiaprint(context, data, senderID);
      } else {
        print('User data not found for sender ID: $senderID');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _showNotificationDiaprint(BuildContext context,
      Map<String, dynamic> userData, String senderID) async {
    if (!context.mounted) return;

    final String profileImage = userData["imageProfile"] ?? "";
    final String name = userData["name"] ?? "";
    final String age = userData["age"]?.toString() ?? "";
    final String city = userData["city"] ?? "";
    final String country = userData["country"] ?? "";
    final String profession = userData["profession"] ?? "";

    showDialog(
      context: context,
      builder: (context) => notificationDiaprintBox(
        senderID,
        profileImage,
        name,
        age,
        city,
        country,
        profession,
        context,
      ),
    );
  }

  Widget notificationDiaprintBox(
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
                                Get.to(() => UserDetails(
                                      userId: senderID,
                                    ));
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
}
