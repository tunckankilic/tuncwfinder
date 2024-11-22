import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/service/push_notification_system.dart';
import 'package:tuncforwork/views/screens/auth/controller/user_controller.dart';
import 'package:tuncforwork/views/screens/favoritesent/fsfr_controller.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_controller.dart';
import 'package:tuncforwork/views/screens/profile/controller/profile_controllers.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_bindings.dart';
import 'package:tuncforwork/views/screens/viewsent/vsvr_controller.dart';

class HomeController extends GetxController {
  static HomeController instance = Get.find();
  final RxBool isInitialized = false.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers
  PushNotificationSystem? notificationSystem;
  FsfrController? fsfrController;
  VsvrController? vsvrController;
  LslrController? lslrController;
  ProfileController? profileController;

  // Rx variables
  final RxInt screenIndex = 0.obs;
  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

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
        final userId = Get.arguments?['userId'] as String? ??
            FirebaseAuth.instance.currentUser?.uid ??
            '';
        return UserDetails(userId: userId);
      },
      binding: BindingsBuilder(() {
        final userId = Get.arguments?['userId'] as String? ??
            FirebaseAuth.instance.currentUser?.uid ??
            '';
        Get.lazyPut(() => UserDetailsController(userId: userId), tag: userId);
      }),
    ),
  ];

  Widget get currentScreen => tabScreensList[screenIndex.value].page();

  ///*************************************************************************

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      isLoading.value = true;

      // Core servisleri initialize et
      notificationSystem = Get.find<PushNotificationSystem>();
      await notificationSystem?.initialize();

      // User verisinin yüklenmesini bekle
      await _waitForUserData();

      // Controller'ları initialize et
      await initializeControllers();

      isInitialized.value = true;
    } catch (e) {
      log('Error in _initializeApp: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _waitForUserData() async {
    final userController = Get.find<UserController>();
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return userController.currentUser.value == null;
    });
  }

  Future<void> initializeControllers() async {
    try {
      // LslrController'ı öncelikli olarak başlat
      lslrController = await Get.putAsync<LslrController>(() async {
        final controller = LslrController();
        controller.onInit();
        return controller;
      }, permanent: true);

      // Diğer controller'ları başlat
      fsfrController = await Get.putAsync<FsfrController>(() async {
        final controller = FsfrController();
        controller.onInit();
        return controller;
      }, permanent: true);

      profileController = await Get.putAsync<ProfileController>(() async {
        final controller = ProfileController();
        controller.onInit();
        return controller;
      }, permanent: true);

      log('All controllers initialized successfully');
    } catch (e) {
      log('Error initializing controllers: $e');
      rethrow;
    }
  }

  Future<void> refreshCurrentScreen(int index) async {
    try {
      if (!isInitialized.value) {
        await _waitForControllers();
      }

      isLoading.value = true;

      switch (index) {
        case 1: // Favorites
          if (fsfrController != null) {
            await fsfrController!.getFavoriteListKeys();
          }
          break;
        case 2: // Likes
          if (lslrController != null) {
            await lslrController!.getLikedListKeys();
          }
          break;
      }
    } catch (e) {
      log('Error refreshing screen $index: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _waitForControllers() async {
    int retryCount = 0;
    while (!isInitialized.value && retryCount < 3) {
      await Future.delayed(Duration(milliseconds: 500));
      retryCount++;
    }
  }

  void changeScreen(int index) {
    screenIndex.value = index;
    refreshCurrentScreen(index);
  }

  @override
  void onClose() {
    // Controller'ları temizle
    fsfrController = null;
    vsvrController = null;
    lslrController = null;
    profileController = null;
    super.onClose();
  }
}
