import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/favoritesent/fsfr_controller.dart';

class FsfrBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FsfrController());
  }
}
