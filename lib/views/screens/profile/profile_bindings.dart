import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';

class ProfileBindings extends Bindings {
  final String userId;

  ProfileBindings({required this.userId});

  @override
  void dependencies() {
    Get.lazyPut(() => AccountSettingsController());
  }
}
