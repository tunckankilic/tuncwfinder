import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/favoritesent/fsfr_controller.dart';
import 'package:tuncforwork/views/screens/home/home_controller.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_controller.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';
import 'package:tuncforwork/views/screens/profile/controller/profile_controllers.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/views/screens/swipe/swipe_controller.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    // Core controllers
    Get.put(HomeController(), permanent: true);
    Get.put(LslrController(), permanent: true);
    Get.put(FsfrController(), permanent: true);
    Get.put(SwipeController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    Get.put(AccountSettingsController(), permanent: true);

    // Lazy load user details controller
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Get.lazyPut(() => UserDetailsController(userId: userId), tag: userId);
  }
}
