import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkUserBanStatus(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      // Cast the data to Map<String, dynamic>? and then access the field
      final userData = userDoc.data() as Map<String, dynamic>?;
      return userData?['isBanned'] ?? false;
    } catch (e) {
      print('Error checking ban status: $e');
      return false;
    }
  }
}
