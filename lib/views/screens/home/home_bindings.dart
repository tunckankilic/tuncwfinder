import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/favoritesent/fsfr_controller.dart';
import 'package:tuncforwork/views/screens/home/home_controller.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_controller.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';
import 'package:tuncforwork/views/screens/profile/controller/profile_controllers.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';
import 'package:tuncforwork/views/screens/viewsent/vsvr_controller.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SwipeController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => FsfrController());
    Get.lazyPut(() => LslrController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => VsvrController());
    Get.lazyPut(() => UserDetailsController());
    Get.lazyPut(() => AccountSettingsController());
  }
}
