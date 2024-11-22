import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/models/person.dart' as pM;
import 'package:tuncforwork/service/service.dart';

class UserController extends GetxController {
  final Rx<pM.Person?> currentUser = Rx<pM.Person?>(null);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _userSubscription;

  @override
  void onInit() {
    super.onInit();
    ever(currentUser, (_) {
      print('Current user updated: ${currentUser.value?.toString()}');
    });
  }

  void initialize(String uid) {
    _userSubscription?.cancel();
    _userSubscription =
        _firestore.collection('users').doc(uid).snapshots().listen(
      (docSnapshot) {
        try {
          if (docSnapshot.exists) {
            currentUser.value = pM.Person.fromDataSnapshot(docSnapshot);
            print('User data updated from stream');
          }
        } catch (e) {
          print('Error updating user data from stream: $e');
        }
      },
      onError: (error) {
        print('Error in user stream: $error');
      },
    );
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }
}
