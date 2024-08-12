import 'package:flutter/material.dart';
import 'package:tuncdating/views/screens/screens.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
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
      case SplashScreen.routeName:
        return MaterialPageRoute(
            settings: settings,
            builder: (_) {
              return const SplashScreen();
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
