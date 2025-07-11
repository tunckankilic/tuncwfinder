import 'package:get/get.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';

class ProfileBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AccountSettingsController());
  }
}
