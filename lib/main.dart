import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/service/crashlytics_service.dart';
import 'package:tuncforwork/service/analytics_service.dart';
import 'package:tuncforwork/views/screens/auth/auth_service.dart';
import 'package:tuncforwork/views/screens/auth/auth_wrapper.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';
import 'package:tuncforwork/views/screens/auth/controller/user_controller.dart';
import 'firebase_options.dart';
import 'package:tuncforwork/theme/modern_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();

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
          // Analytics observer'ı sadece release modunda aktif et (performans için)
          navigatorObservers: kReleaseMode ? [analyticsService.observer] : [],
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
    Get.put(ErrorHandler(), permanent: true);
    Get.put(AuthService(), permanent: true);
    // 🔕 Push Notification System kaldırıldı (performans için)

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

    // PERFORMANS OPTİMİZASYONU:
    // Debug modunda Firebase servislerini başlatma (build performansını artırır)
    if (kReleaseMode) {
      // Sadece Release/Profile modunda tüm servisleri etkinleştir
      log('Initializing Crashlytics (Release mode)...');
      await crashlyticsService.initialize();
      log('Crashlytics initialized successfully');

      log('Initializing Analytics (Release mode)...');
      await analyticsService.initialize();
      log('Analytics initialized successfully');
    } else {
      log('⚡ DEBUG MODE: Firebase Analytics ve Crashlytics devre dışı (performans için)');
    }

    // Firebase Messaging kaldırıldı (performans için)
  } catch (e, stack) {
    log('Error initializing app: $e\n$stack');
    if (kReleaseMode) {
      await crashlyticsService.logError(e, stack,
          reason: 'App initialization failed', fatal: true);
    }
  }
}

//  Notification sistem devre dışı (performans için)
// requestNotificationPermission() fonksiyonu artık gerekli değil
