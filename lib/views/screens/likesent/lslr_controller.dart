import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/service/service.dart';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LslrController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isLikeSentClicked = true.obs;
  RxList<String> likeSentList = <String>[].obs;
  RxList<String> likeReceivedList = <String>[].obs;
  RxList likedList = [].obs;
  RxBool isLoading = true.obs;

  StreamSubscription? _authSubscription;
  StreamSubscription? _likeSentSubscription;
  StreamSubscription? _likeReceivedSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeController();

    // Listen for changes in the selected tab
    ever(isLikeSentClicked, (_) => getLikedListKeys());
  }

  Future<void> _initializeController() async {
    try {
      // Listen to auth state changes
      _authSubscription = _auth.authStateChanges().listen((user) {
        if (user != null) {
          // User is logged in, start listening to like data
          _setupLikeListeners(user.uid);
          getLikedListKeys(); // Initial load
        } else {
          // User logged out, clear data
          _clearData();
        }
      });
    } catch (e) {
      log('Error in _initializeController: $e');
    }
  }

  void _setupLikeListeners(String userId) {
    // Cancel existing subscriptions
    _likeSentSubscription?.cancel();
    _likeReceivedSubscription?.cancel();

    // Listen to likeSent collection changes
    _likeSentSubscription = _firestore
        .collection("users")
        .doc(userId)
        .collection("likeSent")
        .snapshots()
        .listen((snapshot) {
      if (isLikeSentClicked.value) {
        getLikedListKeys();
      }
    });

    // Listen to likeReceived collection changes
    _likeReceivedSubscription = _firestore
        .collection("users")
        .doc(userId)
        .collection("likeReceived")
        .snapshots()
        .listen((snapshot) {
      if (!isLikeSentClicked.value) {
        getLikedListKeys();
      }
    });
  }

  Future<void> getLikedListKeys() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      isLoading.value = true;
      likedList.clear();

      final QuerySnapshot likeSnapshot;
      if (isLikeSentClicked.value) {
        likeSnapshot = await _firestore
            .collection("users")
            .doc(userId)
            .collection("likeSent")
            .get();

        likeSentList.value = likeSnapshot.docs.map((doc) => doc.id).toList();
        await _fetchUserData(likeSentList);
      } else {
        likeSnapshot = await _firestore
            .collection("users")
            .doc(userId)
            .collection("likeReceived")
            .get();

        likeReceivedList.value =
            likeSnapshot.docs.map((doc) => doc.id).toList();
        await _fetchUserData(likeReceivedList);
      }
    } catch (e) {
      log("Error in getLikedListKeys: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchUserData(RxList<String> userIds) async {
    try {
      if (userIds.isEmpty) return;

      final QuerySnapshot usersSnapshot = await _firestore
          .collection("users")
          .where("uid", whereIn: userIds)
          .get();

      likedList.value = usersSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      log("Error fetching user data: $e");
    }
  }

  void toggleLikeList(bool isSent) {
    isLikeSentClicked.value = isSent;
  }

  void _clearData() {
    likeSentList.clear();
    likeReceivedList.clear();
    likedList.clear();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _likeSentSubscription?.cancel();
    _likeReceivedSubscription?.cancel();
    super.onClose();
  }
}
