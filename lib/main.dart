import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/auth/controller/auth_bindings.dart';
import 'package:tuncwfinder/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncwfinder/views/screens/home/home_bindings.dart';
import 'package:tuncwfinder/views/screens/home/home_controller.dart';
import 'package:tuncwfinder/views/screens/screens.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No need to call initializeApp() here if it's called in main already
  log("Handling a background message: ${message.messageId}");
  // Implement your background message handling logic here
}

void main() async {
  await initializeApp();
  runApp(const MyApp());
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await requestNotificationPermission();
  await setupFCM();
}

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.request();
  log('Notification permission status: $status');
}

Future<void> setupFCM() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log("Foreground message received: ${message.messageId}");
    // Implement your foreground message handling logic here
    // You might want to use a local notification plugin to show the notification
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    log("App opened from background state: ${message.messageId}");
    // Implement navigation or other logic when the app is opened from a notification
  });

  String? token = await FirebaseMessaging.instance.getToken();
  log("FCM Token: $token");
  // TODO: Send this token to your server
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TuncWFinder',
      debugShowCheckedModeBanner: false,
      theme: ElegantTheme.themeData,
      initialBinding: InitialBindings(),
      onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings),
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? HomeScreen.routeName
          : LoginScreen.routeName,
    );
  }
}

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(PushNotificationSystem()); // Assuming you have this controller
    FirebaseAuth.instance.currentUser != null
        ? Get.lazyPut(() => HomeController())
        : Get.lazyPut(() => AuthController());
  }
}
