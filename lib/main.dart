import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_bindings.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncforwork/views/screens/home/home_bindings.dart';
import 'package:tuncforwork/views/screens/home/home_controller.dart';
import 'package:tuncforwork/views/screens/screens.dart';
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
}

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.request();
  log('Notification permission status: $status');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TuncForWork',
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
    Get.put(AuthController());
    FirebaseAuth.instance.currentUser != null ? HomeBindings() : AuthBindings();
  }
}
