import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';

class ProfileBindings extends Bindings {
  final String userId;

  ProfileBindings({required this.userId});

  @override
  void dependencies() {
    Get.lazyPut(() => AccountSettingsController());
  }
}
