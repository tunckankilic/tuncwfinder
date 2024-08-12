import 'package:tuncdating/service/service.dart';
import 'package:tuncdating/views/screens/swipe/swipe_controller.dart';

class SwipeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SwipeController());
  }
}
