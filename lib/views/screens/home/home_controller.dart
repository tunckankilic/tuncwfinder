import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/models/person.dart' as pM;
import 'package:tuncforwork/service/push_notification_system.dart';
import 'package:tuncforwork/views/screens/favoritesent/fsfr_controller.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_controller.dart';
import 'package:tuncforwork/views/screens/profile/controller/profile_controllers.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_bindings.dart';
import 'package:tuncforwork/views/screens/viewsent/vsvr_controller.dart';

class HomeController extends GetxController {
  static HomeController instance = Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers
  late final PushNotificationSystem notificationSystem;
  late final FsfrController fsfrController;
  late final VsvrController vsvrController;
  late final ProfileController profileController;
  late final LslrController lslrController;
  late final UserDetailsController userDetailsController;

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

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize notification system
      notificationSystem = PushNotificationSystem();
      await notificationSystem.generateDeviceRegistrationToken();

      // Initialize controllers
      fsfrController = Get.put(FsfrController(), permanent: true);
      vsvrController = Get.put(VsvrController(), permanent: true);
      lslrController = Get.put(LslrController(), permanent: true);
      profileController = Get.put(ProfileController(), permanent: true);

      // Set up auth state listener
      _auth.authStateChanges().listen(_onAuthStateChanged);

      // Check current user
      await _checkCurrentUser();
    } catch (e) {
      print('Error in _initializeApp: $e');
      errorMessage.value = 'Error initializing app: $e';
    }
  }

  Future<void> _checkCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        currentUser.value = user;
        await _ensureUserDocument(user.uid);
      }
    } catch (e) {
      print('Error checking current user: $e');
    }
  }

  void _onAuthStateChanged(User? user) async {
    try {
      if (user != null) {
        currentUser.value = user;
        await _ensureUserDocument(user.uid);
      } else {
        currentUser.value = null;
        // Handle logout if needed
        Get.offAllNamed('/login'); // Or your login route
      }
    } catch (e) {
      print('Error in auth state change: $e');
    }
  }

  Future<void> _ensureUserDocument(String uid) async {
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        final userData = pM.Person(
          uid: uid,
          email: currentUser.value?.email ?? '',
          name: currentUser.value?.displayName ?? 'User',
          imageProfile: currentUser.value?.photoURL ?? '',
          publishedDateTime: DateTime.now().millisecondsSinceEpoch,
          age: 0,
          phoneNo: '',
          city: '',
          country: '',
          profileHeading: 'Hey there! I\'m new here.',
          gender: '',
          height: '',
          weight: '',
          bodyType: '',
          drink: '',
          smoke: '',
          martialStatus: '',
          haveChildren: 'No',
          noOfChildren: '',
          profession: '',
          employmentStatus: '',
          income: '',
          livingSituation: '',
          willingToRelocate: '',
          nationality: '',
          education: '',
          languageSpoken: '',
          religion: '',
          ethnicity: '',
        );

        // Create main document
        await docRef.set(userData.toJson());

        // Create subcollections
        final batch = _firestore.batch();

        ['followers', 'following', 'connections', 'matches']
            .forEach((collection) {
          final docRef = _firestore
              .collection('users')
              .doc(uid)
              .collection(collection)
              .doc();
          batch.set(docRef, {'createdAt': FieldValue.serverTimestamp()});
        });

        // Create user settings
        batch.set(_firestore.collection('user_settings').doc(uid), {
          'emailNotifications': true,
          'pushNotifications': true,
          'profileVisibility': 'public',
          'lastUpdated': FieldValue.serverTimestamp(),
          'accountStatus': 'active',
          'isVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await batch.commit();
      }

      // Update online status
      await docRef.update({
        'isOnline': true,
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error ensuring user document: $e');
      errorMessage.value = 'Error setting up user profile: $e';
    }
  }

  void changeScreen(int index) {
    screenIndex.value = index;
    refreshCurrentScreen(index);
  }

  Future<void> refreshCurrentScreen(int index) async {
    try {
      isLoading.value = true;

      switch (index) {
        case 1: // Favorites
          await fsfrController.getFavoriteListKeys();
          break;
        case 2: // Likes
          await lslrController.getLikedListKeys();
          break;
      }
    } catch (e) {
      print('Error refreshing screen $index: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    if (_auth.currentUser != null) {
      _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'isOnline': false,
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
    super.onClose();
  }
}
