import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';

class ProfileBindings extends Bindings {
  final String userId;

  ProfileBindings({required this.userId});

  @override
  void dependencies() {
    // AccountSettingsController'ı önce oluştur ve başlat
    final accountSettingsController = AccountSettingsController();
    Get.put<AccountSettingsController>(
      accountSettingsController,
      permanent: true,
    );

    // UserDetailsController'ı da bağla
    Get.lazyPut<UserDetailsController>(
        () => UserDetailsController(userId: userId),
        tag: userId,
        fenix: true // Controller yeniden kullanılabilir olsun
        );

    // Controller başlatma işlemini gerçekleştir
    accountSettingsController.onInit();
  }
}
