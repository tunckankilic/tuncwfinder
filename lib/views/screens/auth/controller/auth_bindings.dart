import 'package:get/get.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AuthController(),
    );
  }
}
