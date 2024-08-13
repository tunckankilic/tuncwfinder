import 'package:flutter/material.dart';
import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/screens.dart';
import 'package:tuncwfinder/views/screens/swipe/swipe_bindings.dart';

class HomeController extends GetxController {
  RxInt screenIndex = 0.obs;
  late final PushNotificationSystem notificationSystem;
  final List<GetPage> tabScreensList = [
    GetPage(
        name: '/swipe',
        page: () => const SwipeScreen(),
        binding: SwipeBindings()),
    GetPage(name: '/views', page: () => ViewSentViewReceive()),
    GetPage(
        name: '/favorites', page: () => const FavoriteSendFavoriteReceived()),
    GetPage(name: '/likes', page: () => const LikeSentLikeReceived()),
    GetPage(name: '/profile', page: () => UserDetails(userId: currentUserId)),
  ];

  Widget get currentScreen => tabScreensList[screenIndex.value].page();

  @override
  void onInit() {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();

    super.onInit();
  }

  void changeScreen(int index) {
    screenIndex.value = index;
  }
}
