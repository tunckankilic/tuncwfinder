import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:get/get.dart';

// class RouteGenerator {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case SplashScreen.routeName:
//         return MaterialPageRoute(
//           builder: (_) => const SplashScreen(),
//         );
//       case LoginScreen.routeName:
//         return MaterialPageRoute(
//             settings: settings,
//             builder: (_) {
//               return const LoginScreen();
//             });
//       case RegistrationScreen.routeName:
//         return MaterialPageRoute(
//             settings: settings,
//             builder: (_) {
//               return const RegistrationScreen();
//             });
//       case HomeScreen.routeName:
//         return MaterialPageRoute(
//             settings: settings,
//             builder: (_) {
//               return const HomeScreen();
//             });
//       case UserDetails.routeName:
//         var userID = settings.arguments as String;
//         return MaterialPageRoute(
//             settings: settings,
//             builder: (_) {
//               return UserDetails();
//             });
//       default:
//         return _errorRoute();
//     }
//   }

//   static Route<dynamic> _errorRoute() {
//     return MaterialPageRoute(
//       builder: (_) {
//         return const Center(
//           child: Text("Error Page"),
//         );
//       },
//     );
//   }
// }
import 'package:get/get.dart';
import 'package:tuncforwork/views/screens/screens.dart';
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
      page: () => UserDetails(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => UserDetailsController());
      }),
      arguments: {'userId': FirebaseAuth.instance.currentUser?.uid ?? ''},
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
