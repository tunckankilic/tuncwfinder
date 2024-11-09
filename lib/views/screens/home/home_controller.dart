import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_controller.dart';
import 'package:tuncforwork/views/screens/profile/controller/profile_controllers.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_bindings.dart';
import 'package:tuncforwork/views/screens/favoritesent/fsfr_controller.dart';
import 'package:tuncforwork/views/screens/viewsent/vsvr_controller.dart';

class HomeController extends GetxController {
  RxInt screenIndex = 0.obs;
  late final PushNotificationSystem notificationSystem;
  late final FsfrController fsfrController;
  late final VsvrController vsvrController;
  late final ProfileController profileController;
  late final LslrController lslrController;
  late final UserDetailsController userDetailsController;

  final List<GetPage> tabScreensList = [
    GetPage(
      name: '/swipe',
      page: () => const SwipeScreen(),
      binding: SwipeBindings(),
    ),
    GetPage(
      name: '/favorites',
      page: () => const FavoriteSendFavoriteReceived(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => FsfrController());
      }),
    ),
    GetPage(
      name: '/likes',
      page: () => const LikeSentLikeReceived(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LslrController());
      }),
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
        Get.lazyPut(() => UserDetailsController(userId: userId), tag: userId);
      }),
    ),
  ];

  Widget get currentScreen => tabScreensList[screenIndex.value].page();

  @override
  void onInit() {
    super.onInit();
    notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    fsfrController = Get.put(FsfrController());
    lslrController = Get.put(LslrController());
    profileController = Get.put(ProfileController());
  }

  void changeScreen(int index) {
    screenIndex.value = index;
    if (index == 1) {
      // Favorites screen
      fsfrController.getFavoriteListKeys();
    }
  }
}
