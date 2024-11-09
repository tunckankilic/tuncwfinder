import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';

class SwipeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SwipeController());
  }
}
