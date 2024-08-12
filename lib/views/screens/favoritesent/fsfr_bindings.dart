import 'package:tuncdating/service/service.dart';
import 'package:tuncdating/views/screens/favoritesent/fsfr_controller.dart';

class FsfrBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FsfrController());
  }
}
