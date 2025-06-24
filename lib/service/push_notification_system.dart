import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PushNotificationSystem extends GetxController {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 1), () {
      _initializeNotifications();
    });
  }

  // initialize metodunu ekleyelim
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      log('Initializing push notification system...');

      // iOS için özel yapılandırma
      if (Platform.isIOS) {
        await _setupIOSNotifications();
      }

      // İzinleri kontrol et ve token üret
      await _setupNotifications();

      _isInitialized = true;
    } catch (e, stack) {
      log('Error initializing push notification system: $e\n$stack');
      // Hata durumunda bile bildirimleri dinlemeye başla
      _setupNotificationListeners();
      rethrow;
    }
  }

  Future<void> generateDeviceRegistrationToken() async {
    try {
      log('Generating device registration token...');

      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        log('APNS Token: $apnsToken');

        // Simülatör kontrolü
        if (apnsToken ==
            '66616B652D61706E732D746F6B656E2D666F722D73696D756C61746F72') {
          log('Running on simulator, skipping FCM token generation');
          return;
        }
      }

      final token = await _messaging.getToken();
      log('FCM Token: $token');

      if (token != null) {
        final userId = currentUserId;
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .update({
            "userDeviceToken": token,
          });
          log('Device token successfully updated in Firestore');
        }
      }
    } catch (e, stack) {
      log('Error generating token: $e');
      log('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      if (_isInitialized) return;

      log('Initializing push notification system...');

      // iOS için özel yapılandırma
      if (Platform.isIOS) {
        await _setupIOSNotifications();
      }

      // İzinleri kontrol et ve token üret
      await _setupNotifications();
    } catch (e, stack) {
      log('Error initializing push notification system: $e\n$stack');
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
      log('iOS notification settings configured');
    } catch (e) {
      log('Error setting up iOS notifications: $e');
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

      log('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await _generateTokenWithFallback();
        _setupNotificationListeners();
        _isInitialized = true;
      }
    } catch (e, stack) {
      log('Error in _setupNotifications: $e\n$stack');
      // Hata durumunda bildirimleri yine de dinlemeye başla
      _setupNotificationListeners();
    }
  }

  Future<void> _generateTokenWithFallback() async {
    try {
      log('Attempting to generate device token...');

      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        log('APNS Token: $apnsToken');

        // Simülatör kontrolü
        if (apnsToken ==
            '66616B652D61706E732D746F6B656E2D666F722D73696D756C61746F72') {
          log('Running on simulator, skipping FCM token generation');
          return;
        }
      }

      final token = await _messaging.getToken();
      if (token != null) {
        await _updateTokenInFirestore(token);
      }
    } catch (e) {
      log('Error generating token: $e');
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
        log('Device token successfully updated in Firestore');
      }
    } catch (e) {
      log('Error updating token in Firestore: $e');
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

      log('Notification listeners set up successfully');
    } catch (e) {
      log('Error setting up notification listeners: $e');
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
        log('Sender ID is null in notification data');
      }
    } catch (e) {
      log('Error handling notification message: $e');
    }
  }

  Future<void> openAppAndShowNotificationData(
      String? receiverID, String? senderID, BuildContext context) async {
    if (senderID == null) {
      log('Sender ID is null');
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(senderID)
          .get();

      if (!context.mounted) {
        log('Context is no longer mounted');
        return;
      }

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        await _showNotificationDialog(context, data, senderID);
      } else {
        log('User data not found for sender ID: $senderID');
      }
    } catch (e) {
      log('Error fetching user data: $e');
    }
  }

  Future<void> _showNotificationDialog(BuildContext context,
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
      builder: (context) => notificationDialogBox(
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

  Future<void> sendNotification({
    required String userDeviceToken,
    required String title,
    required String body,
    required NotificationType type,
    required NotificationChannel channel,
    Map<String, dynamic>? additionalData,
    String? groupKey,
    bool isScheduled = false,
    DateTime? scheduledTime,
  }) async {
    try {
      final notification = PushNotification(
        title: title,
        body: body,
        channel: channel.name,
        category: type.name,
        data: {
          ...?additionalData,
          'notification_type': type.name,
          'channel': channel.name,
        },
        groupKey: groupKey,
        isScheduled: isScheduled,
        scheduledTime: scheduledTime,
      );

      await notification.send([userDeviceToken]);

      log('Notification sent successfully');
    } catch (e) {
      log('Error sending notification: $e');
      rethrow;
    }
  }

  Future<void> sendEventNotification({
    required String userDeviceToken,
    required String eventTitle,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? eventData,
    DateTime? scheduledTime,
  }) async {
    try {
      await sendNotification(
        userDeviceToken: userDeviceToken,
        title: 'Event: $eventTitle',
        body: message,
        type: type,
        channel: NotificationChannel.events,
        additionalData: eventData,
        isScheduled: scheduledTime != null,
        scheduledTime: scheduledTime,
      );
    } catch (e) {
      log('Error sending event notification: $e');
      rethrow;
    }
  }

  Future<void> sendInteractionNotification({
    required String userDeviceToken,
    required String senderName,
    required NotificationType type,
    required String receiverId,
    required String senderId,
  }) async {
    try {
      String title;
      String body;

      switch (type) {
        case NotificationType.like:
          title = 'New Like';
          body = 'You have received a new like from $senderName';
          break;
        case NotificationType.view:
          title = 'Profile View';
          body = '$senderName viewed your profile';
          break;
        case NotificationType.favorite:
          title = 'New Favorite';
          body = '$senderName added you to favorites';
          break;
        default:
          throw 'Invalid interaction type';
      }

      await sendNotification(
        userDeviceToken: userDeviceToken,
        title: title,
        body: body,
        type: type,
        channel: NotificationChannel.matches,
        additionalData: {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          'userID': receiverId,
          'senderID': senderId,
        },
      );
    } catch (e) {
      log('Error sending interaction notification: $e');
      rethrow;
    }
  }
}

class PushNotification {
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String channel;
  final String category;
  final String priority;
  final String? groupKey;
  final bool groupSummary;
  final bool isScheduled;
  final DateTime? scheduledTime;

  PushNotification({
    required this.title,
    required this.body,
    this.data,
    this.channel = 'default',
    this.category = 'general',
    this.priority = 'high',
    this.groupKey,
    this.groupSummary = false,
    this.isScheduled = false,
    this.scheduledTime,
  });

  Map<String, dynamic> toMap() => {
        'notification': {
          'title': title,
          'body': body,
          'android_channel_id': channel,
          'priority': priority,
          if (groupKey != null) 'android_group': groupKey,
          if (groupSummary) 'android_group_summary': true,
        },
        'data': {
          ...?data,
          'category': category,
          if (groupKey != null) 'group_key': groupKey,
          if (isScheduled && scheduledTime != null)
            'scheduled_time': scheduledTime!.toIso8601String(),
        },
      };

  Future<void> send(List<String> tokens, {int maxRetries = 3}) async {
    if (tokens.isEmpty) {
      log('No tokens provided for notification');
      return;
    }

    if (isScheduled &&
        scheduledTime != null &&
        scheduledTime!.isBefore(DateTime.now())) {
      log('Scheduled time is in the past');
      return;
    }

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
        final serverKey = dotenv.env['FCM_SERVER_TOKEN'];

        if (serverKey == null) {
          throw 'FCM Server Token is not configured';
        }

        // Tokenleri gruplar halinde gönder (maksimum 500 token)
        for (var i = 0; i < tokens.length; i += 500) {
          final batch = tokens.sublist(
              i, i + 500 > tokens.length ? tokens.length : i + 500);

          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'key=$serverKey',
            },
            body: json.encode({
              ...toMap(),
              'registration_ids': batch,
            }),
          );

          if (response.statusCode == 200) {
            final result = json.decode(response.body);
            _handleFCMResponse(result, batch);
          } else {
            throw 'FCM request failed with status: ${response.statusCode}';
          }
        }
        return;
      } catch (e) {
        attempts++;
        log('Notification attempt $attempts failed: $e');
        if (attempts == maxRetries) {
          log('Max retries reached for notification');
          rethrow;
        }
        // Exponential backoff
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
  }

  void _handleFCMResponse(Map<String, dynamic> result, List<String> tokens) {
    final success = result['success'] ?? 0;
    final failure = result['failure'] ?? 0;
    final results = result['results'] as List<dynamic>? ?? [];

    log('FCM Response - Success: $success, Failure: $failure');

    if (failure > 0) {
      // Token sorunlarını işle
      for (var i = 0; i < results.length; i++) {
        final error = results[i]['error'];
        if (error != null) {
          log('Token ${tokens[i]} failed: $error');
          if (error == 'NotRegistered') {
            _handleInvalidToken(tokens[i]);
          }
        }
      }
    }
  }

  Future<void> _handleInvalidToken(String token) async {
    try {
      // Geçersiz tokeni Firestore'dan temizle
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userDeviceToken', isEqualTo: token)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          'userDeviceToken': FieldValue.delete(),
        });
        log('Removed invalid token for user: ${doc.id}');
      }
    } catch (e) {
      log('Error handling invalid token: $e');
    }
  }
}

// Bildirim kanalları için enum
enum NotificationChannel { general, events, matches, messages, system }

// Bildirim kategorileri için enum
enum NotificationType {
  like,
  view,
  favorite,
  eventInvite,
  eventReminder,
  newMessage,
  systemUpdate
}
