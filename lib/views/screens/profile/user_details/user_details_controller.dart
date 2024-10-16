import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_bindings.dart';
import 'package:tuncforwork/views/screens/auth/pages/screens.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/pages/account_info_settings.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/pages/photo_settings_screen.dart';
import 'package:tuncforwork/views/screens/profile/profile_bindings.dart';

class UserDetailsController extends GetxController {
  late String userId;
  UserDetailsController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  // RxVariables for reactive UI
  RxString name = ''.obs;
  RxString age = ''.obs;
  RxString phoneNo = ''.obs;
  RxString city = ''.obs;
  RxString country = ''.obs;
  RxString profileHeading = ''.obs;
  RxString lookingForInaPartner = ''.obs;
  RxString gender = ''.obs;

  RxString height = ''.obs;
  RxString weight = ''.obs;
  RxString bodyType = ''.obs;

  RxString drink = ''.obs;
  RxString smoke = ''.obs;
  RxString martialStatus = ''.obs;
  RxString haveChildren = ''.obs;
  RxString noOfChildren = ''.obs;
  RxString profession = ''.obs;
  RxString employmentStatus = ''.obs;
  RxString income = ''.obs;
  RxString livingSituation = ''.obs;
  RxString willingToRelocate = ''.obs;
  RxString relationshipYouAreLookingFor = ''.obs;

  RxString nationality = ''.obs;
  RxString education = ''.obs;
  RxString languageSpoken = ''.obs;
  RxString religion = ''.obs;
  RxString ethnicity = ''.obs;

  RxString linkedInUrl = ''.obs;
  RxString instagramUrl = ''.obs;
  RxString githubUrl = ''.obs;

  RxList<String> imageUrls = <String>[].obs;
  final isMainProfilePage = false.obs;
  RxBool isLoading = true.obs;
  @override
  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments?['userId'] ?? FirebaseAuth.instance.currentUser?.uid;
    retrieveUserInfo(userId);
    checkIfMainProfile();
  }

  Future<void> retrieveUserInfo(String userId) async {
    try {
      isLoading.value = true;
      DocumentSnapshot snapshot =
          await _firestore.collection("users").doc(userId).get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;

        name.value = data['name'] ?? '';
        age.value = data['age']?.toString() ?? '';
        phoneNo.value = data['phoneNo'] ?? '';
        city.value = data['city'] ?? '';
        country.value = data['country'] ?? '';
        profileHeading.value = data['profileHeading'] ?? '';
        lookingForInaPartner.value = data['lookingForInaPartner'] ?? '';
        gender.value = data['gender'] ?? '';

        height.value = data['height'] ?? '';
        weight.value = data['weight'] ?? '';
        bodyType.value = data['bodyType'] ?? '';

        drink.value = data['drink'] ?? '';
        smoke.value = data['smoke'] ?? '';
        martialStatus.value = data['martialStatus'] ?? '';
        haveChildren.value = data['haveChildren'] ?? '';
        noOfChildren.value = data['noOfChildren'] ?? '';
        profession.value = data['profession'] ?? '';
        employmentStatus.value = data['employmentStatus'] ?? '';
        income.value = data['income'] ?? '';
        livingSituation.value = data['livingSituation'] ?? '';
        willingToRelocate.value = data['willingToRelocate'] ?? '';
        relationshipYouAreLookingFor.value =
            data['relationshipYouAreLookingFor'] ?? '';

        nationality.value = data['nationality'] ?? '';
        education.value = data['education'] ?? '';
        languageSpoken.value = data['languageSpoken'] ?? '';
        religion.value = data['religion'] ?? '';
        ethnicity.value = data['ethnicity'] ?? '';

        linkedInUrl.value = data['linkedIn'] ?? '';
        instagramUrl.value = data['instagram'] ?? '';
        githubUrl.value = data['github'] ?? '';

        imageUrls.value = [
          data['urlImage1'],
          data['urlImage2'],
          data['urlImage3'],
          data['urlImage4'],
          data['urlImage5'],
        ]
            .where((url) => url != null && url is String && url.isNotEmpty)
            .map((url) => url as String)
            .toList();
      }
    } catch (e) {
      log("Error retrieving user info: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void checkIfMainProfile() {
    isMainProfilePage.value = userId == FirebaseAuth.instance.currentUser?.uid;
  }

  void navigateToAccountSettings() {
    Get.dialog(
      AlertDialog(
        title:
            Text('Profile Settings', style: ElegantTheme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  Icon(Icons.photo_library, color: ElegantTheme.primaryColor),
              title:
                  Text('Edit Photos', style: ElegantTheme.textTheme.bodyLarge),
              onTap: () {
                Get.back();
                Get.to(
                  () => const PhotoSettingsScreen(),
                  binding: ProfileBindings(userId: currentUser!.uid),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: ElegantTheme.primaryColor),
              title: Text('Edit Profile Info',
                  style: ElegantTheme.textTheme.bodyLarge),
              onTap: () {
                Get.back();
                Get.to(
                  () => const ProfileInfoScreen(),
                  binding: ProfileBindings(userId: currentUser!.uid),
                );
              },
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: ElegantTheme.backgroundColor,
      ),
      barrierDismissible: true,
    );
  }

  void updateName(String newName) {
    name.value = newName;
  }

  void updateImageUrls(List<String> newUrls) {
    imageUrls.assignAll(newUrls);
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Get.offAll(
      () => const LoginScreen(),
      binding: AuthBindings(),
    );
  }

  Future<void> deleteAccountAndData(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;

        // 1. Firestore'dan kullanıcıya ait verileri sil
        await _deleteUserData(uid);

        // 2. Kullanıcı hesabını sil
        await user.delete();

        // 3. Kullanıcıyı oturumdan çıkar
        await FirebaseAuth.instance.signOut();
        Get.offAllNamed(LoginScreen.routeName);
      } else {
        print('Kullanıcı oturum açmamış.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
            'Bu işlem için yakın zamanda oturum açılması gerekiyor. Lütfen tekrar oturum açın ve işlemi tekrarlayın.');
      } else {
        print('Hesap silme hatası: ${e.message}');
      }
    } catch (e) {
      print('Beklenmeyen bir hata oluştu: $e');
    }
  }

  Future<void> _deleteUserData(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    QuerySnapshot cardSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: uid)
        .get();

    for (var doc in cardSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
