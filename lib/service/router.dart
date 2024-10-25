import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String userDetails = '/user/:id';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: register,
      page: () => const RegistrationScreen(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: '/profile',
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final userId = arguments?['userId'] as String? ??
            FirebaseAuth.instance.currentUser?.uid ??
            '';
        return UserDetails(userId: userId);
      },
      binding: BindingsBuilder(() {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final userId = arguments?['userId'] as String? ??
            FirebaseAuth.instance.currentUser?.uid ??
            '';
        Get.lazyPut(
          () => UserDetailsController(userId: userId),
          tag: userId,
        );
      }),
    ),
  ];

  static String getInitialRoute() {
    // Logic to determine initial route
    return splash;
  }

  static GetPage unknownRoute = GetPage(
    name: '/not-found',
    page: () => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Error: Page not found')),
    ),
  );
}
