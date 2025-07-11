import 'package:get/get.dart';
import 'package:tuncforwork/views/screens/splash/splash_controller.dart';

class SplashBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}
