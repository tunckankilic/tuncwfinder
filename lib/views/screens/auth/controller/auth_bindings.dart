import 'package:get/get.dart';
import 'package:tuncwfinder/views/screens/auth/controller/auth_controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AuthController(),
    );
  }
}
