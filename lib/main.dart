import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/auth_service.dart';
import 'package:tuncforwork/views/screens/auth/auth_wrapper.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuncforwork/views/screens/auth/controller/user_controller.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/theme/modern_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();

  // .env.prod dosyasını yükle
  try {
    await dotenv.load(fileName: '.env.prod');
  } catch (e) {
    print(
        'Warning: .env.prod file not found. Continuing without environment variables.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: ModernTheme.themeData,
          themeMode: ThemeMode.light,
          defaultTransition: Transition.cupertino,
          home: const AuthenticationWrapper(),
          getPages: AppRoutes.routes,
          unknownRoute: AppRoutes.unknownRoute,
          initialBinding: InitialBindings(),
          builder: (context, widget) {
            ScreenUtil.init(context);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget!,
            );
          },
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

    // Core Controllers - permanent olarak yükle
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
