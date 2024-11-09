import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:permission_handler/permission_handler.dart';
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
          getPages: AppRoutes.routes,
          unknownRoute: AppRoutes.unknownRoute,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const HomeScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
        );
      },
    );
  }
}

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Push Notification System'i bağla
    final pushNotificationSystem =
        Get.put(PushNotificationSystem(), permanent: true);

    // Auth Controller'ı bağla
    Get.put(AuthController());

    // Token üretimini gecikmeli olarak başlat
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        await pushNotificationSystem.generateDeviceRegistrationToken();
      } catch (e, stack) {
        log('Error in initial token generation: $e');
        log('Stack trace: $stack');
      }
    });
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
    print('Notification permission status: $status');

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
    print(
        'Firebase Messaging permission status: ${settings.authorizationStatus}');
  } catch (e) {
    print('Error requesting notification permissions: $e');
  }
}
