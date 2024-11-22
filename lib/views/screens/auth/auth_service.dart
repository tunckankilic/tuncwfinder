import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncforwork/service/service.dart';

class AuthService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> checkUserBanStatus(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      final userData = userDoc.data() as Map<String, dynamic>?;
      return userData?['isBanned'] ?? false;
    } catch (e) {
      print('Error checking ban status: $e');
      return false;
    }
  }

  // Kullanıcı dokümanını kontrol et ve gerekirse oluştur
  Future<bool> ensureUserDocument(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'isOnline': true,
          'isBanned': false,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Error ensuring user document: $e');
      return false;
    }
  }
}
