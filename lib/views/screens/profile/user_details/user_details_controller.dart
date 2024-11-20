import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_bindings.dart';
import 'package:tuncforwork/views/screens/auth/pages/screens.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/pages/account_info_settings.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/pages/photo_settings_screen.dart';
import 'package:tuncforwork/views/screens/profile/profile_bindings.dart';

class UserDetailsController extends GetxController {
  final String userId;

  UserDetailsController({required this.userId});

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

  Future<void> retrieveUserInfo(String userId) async {
    try {
      isLoading.value = true;
      DocumentSnapshot snapshot =
          await _firestore.collection("users").doc(userId).get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          name.value = data['name'] as String? ?? '';
          age.value = (data['age'] as int?)?.toString() ?? '';
          phoneNo.value = data['phoneNo'] as String? ?? '';
          city.value = data['city'] as String? ?? '';
          country.value = data['country'] as String? ?? '';
          profileHeading.value = data['profileHeading'] as String? ?? '';
          lookingForInaPartner.value =
              data['lookingForInaPartner'] as String? ?? '';
          gender.value = data['gender'] as String? ?? '';

          height.value = data['height'] as String? ?? '';
          weight.value = data['weight'] as String? ?? '';
          bodyType.value = data['bodyType'] as String? ?? '';

          drink.value = data['drink'] as String? ?? '';
          smoke.value = data['smoke'] as String? ?? '';
          martialStatus.value = data['martialStatus'] as String? ?? '';
          haveChildren.value = data['haveChildren'] as String? ?? '';
          noOfChildren.value = data['noOfChildren'] as String? ?? '';
          profession.value = data['profession'] as String? ?? '';
          employmentStatus.value = data['employmentStatus'] as String? ?? '';
          income.value = data['income'] as String? ?? '';
          livingSituation.value = data['livingSituation'] as String? ?? '';
          willingToRelocate.value = data['willingToRelocate'] as String? ?? '';
          relationshipYouAreLookingFor.value =
              data['relationshipYouAreLookingFor'] as String? ?? '';

          nationality.value = data['nationality'] as String? ?? '';
          education.value = data['education'] as String? ?? '';
          languageSpoken.value = data['languageSpoken'] as String? ?? '';
          religion.value = data['religion'] as String? ?? '';
          ethnicity.value = data['ethnicity'] as String? ?? '';

          linkedInUrl.value = data['linkedInUrl'] as String? ?? '';
          instagramUrl.value = data['instagramUrl'] as String? ?? '';
          githubUrl.value = data['githubUrl'] as String? ?? '';

          imageUrls.value = [
            data['urlImage1'] as String?,
            data['urlImage2'] as String?,
            data['urlImage3'] as String?,
            data['urlImage4'] as String?,
            data['urlImage5'] as String?,
          ]
              .where((url) => url != null && url.isNotEmpty)
              .map((url) => url!)
              .toList();

          log("User data retrieved successfully for user: $userId");
        } else {
          log("User data is null for user: $userId");
        }
      } else {
        log("User document does not exist for user: $userId");
      }
    } catch (e) {
      log("Error retrieving user info for user $userId: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void checkIfMainProfile() {
    isMainProfilePage.value = userId == FirebaseAuth.instance.currentUser?.uid;
    log("Is main profile page: ${isMainProfilePage.value}");
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
                  () => ProfileInfoScreen(),
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

        // 1. Delete user data from Firestore
        await _deleteUserData(uid);

        // 2. Delete user account
        await user.delete();

        // 3. Sign out the user
        await FirebaseAuth.instance.signOut();
        Get.offAllNamed(LoginScreen.routeName);
      } else {
        log('User is not signed in.');
        Get.snackbar('Error', 'User is not signed in.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        log('This operation requires recent authentication. Please log in again.');
        Get.snackbar('Error', 'Please log in again to delete your account.');
      } else {
        log('Account deletion error: ${e.message}');
        Get.snackbar('Error', 'Failed to delete account: ${e.message}');
      }
    } catch (e) {
      log('Unexpected error occurred: $e');
      Get.snackbar('Error', 'An unexpected error occurred.');
    }
  }

  Future<void> _deleteUserData(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      QuerySnapshot cardSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in cardSnapshot.docs) {
        await doc.reference.delete();
      }
      log('User data deleted successfully for user: $uid');
    } catch (e) {
      log('Error deleting user data: $e');
      rethrow; // Re-throw the error to be caught in the calling function
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (userId.isNotEmpty) {
      retrieveUserInfo(userId);
      checkIfMainProfile();
    } else {
      log('User ID is missing');
      Get.snackbar('Error', 'User ID is missing');
      Get.back();
    }
  }
}
