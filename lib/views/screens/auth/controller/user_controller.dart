import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/service.dart';

class UserController extends GetxController {
  final Rx<Person?> currentUser = Rx<Person?>(null);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _userSubscription;
  final RxBool isLoading = true.obs;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void onInit() {
    super.onInit();
    // Auth state'i dinle
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _initializeUserStream(user.uid);
      } else {
        currentUser.value = null;
        isLoading.value = false;
      }
    });
  }

  Future<void> _initializeUserStream(String uid) async {
    try {
      isLoading.value = true;
      await _userSubscription?.cancel();

      // İlk document okuması
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        try {
          currentUser.value = Person.fromDataSnapshot(doc);
          print('Initial user data loaded');
          _retryCount = 0; // Başarılı olunca retry sayısını sıfırla
        } catch (e) {
          print('Error parsing initial user data: $e');
          _handleRetry(uid);
          return;
        }
      } else if (_retryCount < _maxRetries) {
        await Future.delayed(Duration(milliseconds: 500 * (_retryCount + 1)));
        _retryCount++;
        print('Retrying user data load, attempt $_retryCount');
        await _initializeUserStream(uid);
        return;
      }

      // Stream'i başlat
      _userSubscription =
          _firestore.collection('users').doc(uid).snapshots().listen(
        (docSnapshot) async {
          if (docSnapshot.exists) {
            try {
              currentUser.value = Person.fromDataSnapshot(docSnapshot);
              print('User data updated from stream');
            } catch (e) {
              print('Error parsing stream data: $e');
            }
          } else {
            print('Document does not exist in stream for uid: $uid');
            _handleRetry(uid);
          }
        },
        onError: (error) {
          print('Error in user stream: $error');
          isLoading.value = false;
        },
      );
    } catch (e) {
      print('Error initializing user stream: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleRetry(String uid) async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      await Future.delayed(Duration(milliseconds: 500 * _retryCount));
      print('Retrying user data load, attempt $_retryCount');
      await _initializeUserStream(uid);
    } else {
      print('Max retries reached for user data load');
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }

  Future<Map<String, dynamic>> checkUserStatus(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        await initializeUserStream(uid);
      }
      return {
        'exists': userDoc.exists,
        'isBanned': userDoc.data()?['isBanned'] ?? false,
      };
    } catch (e) {
      print('Error checking user status: $e');
      return {'exists': false, 'isBanned': false};
    }
  }

  Future<void> initializeUserStream(String uid) async {
    try {
      isLoading.value = true;

      // Önce mevcut subscription'ı iptal et
      await _userSubscription?.cancel();

      // Önce dokümanı bir kez oku
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        try {
          currentUser.value = Person.fromDataSnapshot(docSnapshot);
          print('Initial user data loaded');
        } catch (e) {
          print('Error parsing initial user data: $e');
        }
      }

      // Sonra stream'i başlat
      _userSubscription =
          _firestore.collection('users').doc(uid).snapshots().listen(
        (docSnapshot) {
          if (docSnapshot.exists) {
            try {
              currentUser.value = Person.fromDataSnapshot(docSnapshot);
              print('User data updated from stream');
            } catch (e) {
              print('Error parsing stream data: $e');
            }
          } else {
            print('Document does not exist in stream for uid: $uid');
          }
        },
        onError: (error) {
          print('Error in user stream: $error');
          isLoading.value = false;
        },
      );
    } catch (e) {
      print('Error initializing user stream: $e');
      isLoading.value = false;
    }
  }
}
