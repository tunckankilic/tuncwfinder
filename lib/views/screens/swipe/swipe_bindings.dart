import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/swipe/swipe_controller.dart';

class SwipeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SwipeController());
  }
}
