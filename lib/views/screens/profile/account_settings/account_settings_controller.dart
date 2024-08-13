import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tuncwfinder/service/service.dart';
import 'package:tuncwfinder/views/screens/screens.dart';

class AccountSettingsController extends GetxController {
  RxBool uploading = false.obs;
  RxBool next = false.obs;
  RxList<File> images = <File>[].obs;
  RxList<String> urlsList = <String>[].obs;
  RxDouble uploadProgress = 0.0.obs;

  // Personal Info
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneNoController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final profileHeadingController = TextEditingController();
  final lookingForInaPartnerController = TextEditingController();
  final genderController = TextEditingController();

  // Appearance
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final bodyTypeController = TextEditingController();

  // Life style
  final drinkController = TextEditingController();
  final smokeController = TextEditingController();
  final martialStatusController = TextEditingController();
  final haveChildrenController = TextEditingController();
  final noOfChildrenController = TextEditingController();
  final professionController = TextEditingController();
  final employmentStatusController = TextEditingController();
  final incomeController = TextEditingController();
  final livingSituationController = TextEditingController();
  final willingToRelocateController = TextEditingController();
  final relationshipYouAreLookingForController = TextEditingController();

  // Background - Cultural Values
  final nationalityController = TextEditingController();
  final educationController = TextEditingController();
  final languageSpokenController = TextEditingController();
  final religionController = TextEditingController();
  final ethnicityController = TextEditingController();

  // Connections
  final instagramController = TextEditingController();
  final linkedInController = TextEditingController();
  final gitHubController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    retrieveUserData();
  }

  void retrieveUserData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .get();

    if (snapshot.exists) {
      var data = snapshot.data()!;
      // Personal Info
      nameController.text = data['name'] ?? '';
      ageController.text = data['age']?.toString() ?? '';
      phoneNoController.text = data['phoneNo'] ?? '';
      cityController.text = data['city'] ?? '';
      countryController.text = data['country'] ?? '';
      profileHeadingController.text = data['profileHeading'] ?? '';
      lookingForInaPartnerController.text = data['lookingForInaPartner'] ?? '';
      genderController.text = data['gender'] ?? '';

      // Appearance
      heightController.text = data['height'] ?? '';
      weightController.text = data['weight'] ?? '';
      bodyTypeController.text = data['bodyType'] ?? '';

      // Life style
      drinkController.text = data['drink'] ?? '';
      smokeController.text = data['smoke'] ?? '';
      martialStatusController.text = data['martialStatus'] ?? '';
      haveChildrenController.text = data['haveChildren'] ?? '';
      noOfChildrenController.text = data['noOfChildren'] ?? '';
      professionController.text = data['profession'] ?? '';
      employmentStatusController.text = data['employmentStatus'] ?? '';
      incomeController.text = data['income'] ?? '';
      livingSituationController.text = data['livingSituation'] ?? '';
      willingToRelocateController.text = data['willingToRelocate'] ?? '';
      relationshipYouAreLookingForController.text =
          data['relationshipYouAreLookingFor'] ?? '';

      // Background - Cultural Values
      nationalityController.text = data['nationality'] ?? '';
      educationController.text = data['education'] ?? '';
      languageSpokenController.text = data['languageSpoken'] ?? '';
      religionController.text = data['religion'] ?? '';
      ethnicityController.text = data['ethnicity'] ?? '';

      // Connections
      instagramController.text = data['instagram'] ?? '';
      linkedInController.text = data['linkedIn'] ?? '';
      gitHubController.text = data['github'] ?? '';
    }
  }

  Future<void> updateUserDataToFirestore() async {
    if (allFieldsValid()) {
      uploading.value = true;
      await uploadImages();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .update({
        // Personal Info
        'name': nameController.text,
        'age': int.parse(ageController.text),
        'phoneNo': phoneNoController.text,
        'city': cityController.text,
        'country': countryController.text,
        'profileHeading': profileHeadingController.text,
        'lookingForInaPartner': lookingForInaPartnerController.text,
        'gender': genderController.text,

        // Appearance
        'height': heightController.text,
        'weight': weightController.text,
        'bodyType': bodyTypeController.text,

        // Life style
        'drink': drinkController.text,
        'smoke': smokeController.text,
        'martialStatus': martialStatusController.text,
        'haveChildren': haveChildrenController.text,
        'noOfChildren': noOfChildrenController.text,
        'profession': professionController.text,
        'employmentStatus': employmentStatusController.text,
        'income': incomeController.text,
        'livingSituation': livingSituationController.text,
        'willingToRelocate': willingToRelocateController.text,
        'relationshipYouAreLookingFor':
            relationshipYouAreLookingForController.text,

        // Background - Cultural Values
        'nationality': nationalityController.text,
        'education': educationController.text,
        'languageSpoken': languageSpokenController.text,
        'religion': religionController.text,
        'ethnicity': ethnicityController.text,

        // Connections
        'instagram': instagramController.text,
        'linkedIn': linkedInController.text,
        'github': gitHubController.text,

        // Images
        'urlImage1': urlsList.isNotEmpty ? urlsList[0] : '',
        'urlImage2': urlsList.length > 1 ? urlsList[1] : '',
        'urlImage3': urlsList.length > 2 ? urlsList[2] : '',
        'urlImage4': urlsList.length > 3 ? urlsList[3] : '',
        'urlImage5': urlsList.length > 4 ? urlsList[4] : '',
      });

      Get.snackbar("Updated", "Your account has been updated successfully.");
      Get.offAll(() => const HomeScreen());

      uploading.value = false;
      images.clear();
      urlsList.clear();
    } else {
      Get.snackbar("Error", "Please fill all required fields");
    }
  }

  bool allFieldsValid() {
    return nameController.text.isNotEmpty &&
        ageController.text.isNotEmpty &&
        phoneNoController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        countryController.text.isNotEmpty &&
        profileHeadingController.text.isNotEmpty &&
        lookingForInaPartnerController.text.isNotEmpty &&
        genderController.text.isNotEmpty &&
        heightController.text.isNotEmpty &&
        weightController.text.isNotEmpty &&
        bodyTypeController.text.isNotEmpty &&
        drinkController.text.isNotEmpty &&
        smokeController.text.isNotEmpty &&
        martialStatusController.text.isNotEmpty &&
        haveChildrenController.text.isNotEmpty &&
        noOfChildrenController.text.isNotEmpty &&
        professionController.text.isNotEmpty &&
        employmentStatusController.text.isNotEmpty &&
        incomeController.text.isNotEmpty &&
        livingSituationController.text.isNotEmpty &&
        willingToRelocateController.text.isNotEmpty &&
        relationshipYouAreLookingForController.text.isNotEmpty &&
        nationalityController.text.isNotEmpty &&
        educationController.text.isNotEmpty &&
        languageSpokenController.text.isNotEmpty &&
        religionController.text.isNotEmpty &&
        ethnicityController.text.isNotEmpty;
  }

  Future<void> chooseImage() async {
    if (images.length < 5) {
      XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        images.add(File(pickedFile.path));
      }
    } else {
      Get.snackbar("Maximum Images", "You can only select up to 5 images");
    }
  }

  Future<void> uploadImages() async {
    for (var i = 0; i < images.length; i++) {
      var img = images[i];
      uploadProgress.value = i / images.length;

      var refImages = FirebaseStorage.instance
          .ref()
          .child("images/${DateTime.now().millisecondsSinceEpoch}.jpg");
      await refImages.putFile(img);
      var downloadUrl = await refImages.getDownloadURL();
      urlsList.add(downloadUrl);
    }
  }

  @override
  void onClose() {
    // Dispose all controllers
    nameController.dispose();
    ageController.dispose();
    phoneNoController.dispose();
    cityController.dispose();
    countryController.dispose();
    profileHeadingController.dispose();
    lookingForInaPartnerController.dispose();
    genderController.dispose();
    heightController.dispose();
    weightController.dispose();
    bodyTypeController.dispose();
    drinkController.dispose();
    smokeController.dispose();
    martialStatusController.dispose();
    haveChildrenController.dispose();
    noOfChildrenController.dispose();
    professionController.dispose();
    employmentStatusController.dispose();
    incomeController.dispose();
    livingSituationController.dispose();
    willingToRelocateController.dispose();
    relationshipYouAreLookingForController.dispose();
    nationalityController.dispose();
    educationController.dispose();
    languageSpokenController.dispose();
    religionController.dispose();
    ethnicityController.dispose();
    instagramController.dispose();
    linkedInController.dispose();
    gitHubController.dispose();

    super.onClose();
  }
}
