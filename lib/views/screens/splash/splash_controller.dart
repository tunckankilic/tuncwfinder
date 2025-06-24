import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncforwork/views/screens/auth/pages/login_screen.dart';
import 'package:tuncforwork/views/screens/home/home_screen.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash ekranını göster

    if (_auth.currentUser != null) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }
}
