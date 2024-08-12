import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncdating/service/global.dart';
import 'package:tuncdating/views/screens/auth/controller/auth_bindings.dart';
import 'package:tuncdating/views/screens/auth/pages/screens.dart';
import 'package:tuncdating/views/screens/profile/account_settings/account_settings.dart';

class UserDetailsController extends GetxController {
  final String? userId;
  UserDetailsController({this.userId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  @override
  void onInit() {
    super.onInit();
    retrieveUserInfo();
  }

  Future<void> retrieveUserInfo() async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection("users")
          .doc(userId ?? currentUserId)
          .get();

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
    }
  }

  bool isCurrentUser() {
    return userId == currentUserId;
  }

  void navigateToAccountSettings() {
    Get.to(() => AccountSettings());
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Get.offAll(
      () => const LoginScreen(),
      binding: AuthBindings(),
    );
  }
}
