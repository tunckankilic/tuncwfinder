import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/viewsent/vsvr_controller.dart';

class VSVRBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VsvrController());
  }
}
