import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_controller.dart';

class LslrBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LslrController());
  }
}
