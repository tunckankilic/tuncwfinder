import 'package:tuncdating/service/service.dart';
import 'package:tuncdating/views/screens/viewsent/vsvr_controller.dart';

class VSVRBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VsvrController());
  }
}
