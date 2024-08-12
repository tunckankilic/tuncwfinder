import 'package:tuncdating/service/service.dart';
import 'package:tuncdating/views/screens/likesent/lslr_controller.dart';

class LslrBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LslrController());
  }
}
