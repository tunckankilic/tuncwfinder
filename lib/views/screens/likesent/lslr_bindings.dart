import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/likesent/lslr_controller.dart';

class LslrBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LslrController());
  }
}
