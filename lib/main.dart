import 'dart:developer';
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
  const MyApp({Key? key}) : super(key: key);

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
          onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return HomeScreen();
              } else {
                return LoginScreen(); // or whatever your auth screen is
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
    Get.put(PushNotificationSystem(), permanent: true);
    Get.put(AuthController());
  }
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
