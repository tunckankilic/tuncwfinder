import 'package:flutter/material.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case LoginScreen.routeName:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) {
              return const LoginScreen();
            });
      case RegistrationScreen.routeName:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) {
              return const RegistrationScreen();
            });
      case HomeScreen.routeName:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) {
              return const HomeScreen();
            });
      case UserDetails.routeName:
        var userID = settings.arguments as String;
        return MaterialPageRoute(
            settings: settings,
            builder: (_) {
              return UserDetails(userId: userID);
            });
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return const Center(
          child: Text("Error Page"),
        );
      },
    );
  }
}
