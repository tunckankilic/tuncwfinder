import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/favoritesent/fsfr_controller.dart';

class FsfrBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FsfrController());
  }
}
