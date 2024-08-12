import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncdating/service/service.dart';
import 'package:tuncdating/views/screens/auth/controller/auth_bindings.dart';
import 'package:tuncdating/views/screens/home/home_bindings.dart';
import 'package:tuncdating/views/screens/screens.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';

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
  final status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TuncDating',
      debugShowCheckedModeBanner: false,
      theme: ElegantTheme.themeData,
      initialBinding: FirebaseAuth.instance.currentUser != null
          ? HomeBindings()
          : AuthBindings(),
      onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings),
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? HomeScreen.routeName
          : LoginScreen.routeName,
    );
  }
}
