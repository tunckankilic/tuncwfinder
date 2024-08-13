import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/viewsent/vsvr_controller.dart';

class VSVRBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VsvrController());
  }
}
