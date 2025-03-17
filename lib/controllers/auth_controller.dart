import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = 'Giriş yapılırken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı profilini güncelle
      await userCredential.user?.updateDisplayName(name);

      // Firestore'a kullanıcı bilgilerini kaydet
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = 'Kayıt olurken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = 'Çıkış yapılırken hata: $e';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar(
        'Başarılı',
        'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Şifre sıfırlama bağlantısı gönderilirken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({String? name, String? photoURL}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (name != null) {
        await user.value?.updateDisplayName(name);
      }

      if (photoURL != null) {
        await user.value?.updatePhotoURL(photoURL);
      }

      // Firestore'da kullanıcı bilgilerini güncelle
      await _firestore.collection('users').doc(user.value?.uid).update({
        if (name != null) 'name': name,
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Başarılı',
        'Profil bilgileri güncellendi',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Profil güncellenirken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
