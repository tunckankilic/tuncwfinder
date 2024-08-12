import 'package:tuncdating/service/service.dart';
import 'package:tuncdating/views/screens/profile/account_settings/account_settings_controller.dart';
import 'package:tuncdating/views/screens/profile/user_details/user_details_controller.dart';

class ProfileBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserDetailsController());
    Get.lazyPut(() => AccountSettingsController());
  }
}
