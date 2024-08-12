import 'package:get/get.dart';
import 'package:tuncdating/views/screens/auth/controller/auth_controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AuthController(),
    );
  }
}
