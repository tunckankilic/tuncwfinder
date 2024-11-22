import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FsfrController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isFavoriteSentClicked = true.obs;
  RxList<String> favoriteSentList = <String>[].obs;
  RxList<String> favoriteReceivedList = <String>[].obs;
  RxList favoritesList = [].obs;
  RxBool isLoading = true.obs;

  StreamSubscription? _authSubscription;
  StreamSubscription? _favoriteSentSubscription;
  StreamSubscription? _favoriteReceivedSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeController();

    // Listen for changes in the selected tab
    ever(isFavoriteSentClicked, (_) => getFavoriteListKeys());
  }

  Future<void> _initializeController() async {
    try {
      // Listen to auth state changes
      _authSubscription = _auth.authStateChanges().listen((user) {
        if (user != null) {
          // User is logged in, start listening to favorite data
          _setupFavoriteListeners(user.uid);
          getFavoriteListKeys(); // Initial load
        } else {
          // User logged out, clear data
          _clearData();
        }
      });
    } catch (e) {
      log('Error in _initializeController: $e');
    }
  }

  void _setupFavoriteListeners(String userId) {
    // Cancel existing subscriptions
    _favoriteSentSubscription?.cancel();
    _favoriteReceivedSubscription?.cancel();

    // Listen to favoriteSent collection changes
    _favoriteSentSubscription = _firestore
        .collection("users")
        .doc(userId)
        .collection("favoriteSent")
        .snapshots()
        .listen((snapshot) {
      if (isFavoriteSentClicked.value) {
        getFavoriteListKeys();
      }
    });

    // Listen to favoriteReceived collection changes
    _favoriteReceivedSubscription = _firestore
        .collection("users")
        .doc(userId)
        .collection("favoriteReceived")
        .snapshots()
        .listen((snapshot) {
      if (!isFavoriteSentClicked.value) {
        getFavoriteListKeys();
      }
    });
  }

  Future<void> getFavoriteListKeys() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      isLoading.value = true;
      favoritesList.clear();

      if (isFavoriteSentClicked.value) {
        await _getFavoriteSent(userId);
      } else {
        await _getFavoriteReceived(userId);
      }

      await _fetchUserData(
        isFavoriteSentClicked.value ? favoriteSentList : favoriteReceivedList,
      );
    } catch (e) {
      log("Error in getFavoriteListKeys: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getFavoriteSent(String userId) async {
    try {
      final snapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection("favoriteSent")
          .get();

      favoriteSentList.value = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      log("Error in _getFavoriteSent: $e");
    }
  }

  Future<void> _getFavoriteReceived(String userId) async {
    try {
      final snapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection("favoriteReceived")
          .get();

      favoriteReceivedList.value = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      log("Error in _getFavoriteReceived: $e");
    }
  }

  Future<void> _fetchUserData(RxList<String> userIds) async {
    try {
      if (userIds.isEmpty) return;

      final QuerySnapshot usersSnapshot = await _firestore
          .collection("users")
          .where("uid", whereIn: userIds)
          .get();

      favoritesList.value = usersSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      log("Error fetching user data: $e");
    }
  }

  void toggleFavoriteList(bool isSent) {
    if (isFavoriteSentClicked.value != isSent) {
      isFavoriteSentClicked.value = isSent;
    }
  }

  void _clearData() {
    favoriteSentList.clear();
    favoriteReceivedList.clear();
    favoritesList.clear();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _favoriteSentSubscription?.cancel();
    _favoriteReceivedSubscription?.cancel();
    super.onClose();
  }
}
