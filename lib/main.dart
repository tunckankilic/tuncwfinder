import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/auth_service.dart';
import 'package:tuncforwork/views/screens/auth/auth_wrapper.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuncforwork/views/screens/auth/controller/user_controller.dart';
import 'firebase_options.dart';

void main() async {
  await initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return GetMaterialApp(
          title: 'TuncForWork',
          debugShowCheckedModeBanner: false,
          theme: ElegantTheme.themeData,
          initialBinding: InitialBindings(),
          home: AuthenticationWrapper(),
        );
      },
    );
  }
}

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put(AuthService(), permanent: true);
    Get.put(PushNotificationSystem(), permanent: true);

    // Core Controllers - sadece bunları yükle
    Get.put(UserController(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}

Future<void> initializeApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    log('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('Firebase initialized successfully');

    if (Platform.isIOS) {
      try {
        await FirebaseMessaging.instance.setAutoInitEnabled(true);
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        log('Initial APNS token: $apnsToken');
      } catch (e) {
        log('Error setting up iOS messaging: $e');
      }
    }
  } catch (e, stack) {
    log('Error initializing app: $e\n$stack');
    // Firebase başlatılamazsa bile uygulamanın çalışmasına izin ver
  }
}

Future<void> requestNotificationPermission() async {
  try {
    // Permission handler ile izin isteme
    final status = await Permission.notification.request();
    log('Notification permission status: $status');

    // Firebase Messaging izinleri
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    log('Firebase Messaging permission status: ${settings.authorizationStatus}');
  } catch (e) {
    log('Error requesting notification permissions: $e');
  }
}
