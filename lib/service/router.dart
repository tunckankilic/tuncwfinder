import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/views/screens/auth/pages/forgot_password.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_bindings.dart';
import 'package:tuncforwork/views/screens/favoritesent/fsfr_bindings.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_bindings.dart';

class AppRoutes {
  static const String splash = AppStrings.routeSplash;
  static const String login = AppStrings.routeLogin;
  static const String home = AppStrings.routeHome;
  static const String userDetails = '/user/:id';
  static const String fpass = AppStrings.routeForgotPassword;
  static const String swipe = AppStrings.routeSwipe;
  static const String favorites = AppStrings.routeFavorites;
  static const String likes = AppStrings.routeLikes;
  static const String eventList = AppStrings.routeEventList;
  static const String community = AppStrings.routeCommunity;

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
      name: RegistrationScreen.routeName,
      page: () => const RegistrationScreen(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: fpass,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppStrings.routeProfile,
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

    
    GetPage(
      name: AppStrings.routeSwipe,
      page: () => const SwipeScreen(),
      binding: SwipeBindings(),
    ),
    GetPage(
      name: AppStrings.routeFavorites,
      page: () => const FavoriteSendFavoriteReceived(),
      binding: FsfrBindings(),
    ),
    GetPage(
      name: AppStrings.routeLikes,
      page: () => const LikeSentLikeReceived(),
      binding: LslrBindings(),
    ),

  ];

  static String getInitialRoute() {
    // Logic to determine initial route
    return splash;
  }

  static GetPage unknownRoute = GetPage(
    name: AppStrings.routeNotFound,
    page: () => Scaffold(
      appBar: AppBar(title: Text(AppStrings.errorTitle)),
      body: Center(child: Text(AppStrings.errorPageNotFound)),
    ),
  );
}
