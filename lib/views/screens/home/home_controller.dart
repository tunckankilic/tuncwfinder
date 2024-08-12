import 'package:flutter/material.dart';
import 'package:tuncdating/service/service.dart';
import 'package:tuncdating/views/screens/screens.dart';
import 'package:tuncdating/views/screens/swipe/swipe_bindings.dart';

class HomeController extends GetxController {
  RxInt screenIndex = 0.obs;
  final PushNotificationSystem notificationSystem = PushNotificationSystem();
  final List<GetPage> tabScreensList = [
    GetPage(
        name: '/swipe', page: () => SwipeScreen(), binding: SwipeBindings()),
    GetPage(name: '/views', page: () => ViewSentViewReceive()),
    GetPage(name: '/favorites', page: () => FavoriteSendFavoriteReceived()),
    GetPage(name: '/likes', page: () => LikeSentLikeReceived()),
    GetPage(name: '/profile', page: () => UserDetails(userId: currentUserId)),
  ];

  Widget get currentScreen => tabScreensList[screenIndex.value].page();

  void changeScreen(int index) {
    screenIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    setupNotifications();
  }

  void setupNotifications() {
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.whenNotificationReceived(Get.context!);
  }
}
