import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/favoritesent/fsfr_controller.dart';
import 'package:tuncwfinder/views/screens/home/home_controller.dart';
import 'package:tuncwfinder/views/screens/likesent/lslr_controller.dart';
import 'package:tuncwfinder/views/screens/profile/account_settings/account_settings_controller.dart';
import 'package:tuncwfinder/views/screens/profile/controller/profile_controllers.dart';
import 'package:tuncwfinder/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncwfinder/views/screens/swipe/swipe_controller.dart';
import 'package:tuncwfinder/views/screens/viewsent/vsvr_controller.dart';

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
