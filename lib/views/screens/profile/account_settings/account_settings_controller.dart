import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class AccountSettingsController extends GetxController {
  // Loading States
  RxBool uploading = false.obs;
  RxBool next = false.obs;
  RxBool isLoading = false.obs;
  RxDouble uploadProgress = 0.0.obs;

  // Image Related
  Rx<File?> pickedImage = Rx<File?>(null);
  RxList<dynamic> images = <dynamic>[].obs;
  RxList<String> urlsList = <String>[].obs;

  // Personal Info Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final phoneNoController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final profileHeadingController = TextEditingController();
  final genderController = TextEditingController();

  // Appearance Controllers
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final bodyTypeController = TextEditingController();

  // Life style Controllers
  final drinkController = TextEditingController();
  final smokeController = TextEditingController();
  final martialStatusController = TextEditingController();
  final noOfChildrenController = TextEditingController();
  final professionController = TextEditingController();
  final employmentStatusController = TextEditingController();
  final incomeController = TextEditingController();
  final livingSituationController = TextEditingController();

  // Background - Cultural Values Controllers
  final nationalityController = TextEditingController();
  final educationController = TextEditingController();
  final languageSpokenController = TextEditingController();
  final religionController = TextEditingController();
  final ethnicityController = TextEditingController();

  // Connections Controllers
  final instagramController = TextEditingController();
  final linkedInController = TextEditingController();
  final gitHubController = TextEditingController();

  // Dropdown Selected Values
  final RxString selectedGender = ''.obs;
  final RxString selectedCountry = ''.obs;
  final RxString selectedBodyType = ''.obs;
  final RxString selectedDrink = ''.obs;
  final RxString selectedSmoke = ''.obs;
  final RxString selectedMaritalStatus = ''.obs;
  final RxString selectedProfession = ''.obs;
  final RxString selectedEmploymentStatus = ''.obs;
  final RxString selectedLivingSituation = ''.obs;
  final RxString selectedNationality = ''.obs;
  final RxString selectedEducation = ''.obs;
  final RxString selectedLanguage = ''.obs;
  final RxString selectedReligion = ''.obs;
  final RxString selectedEthnicity = ''.obs;

  // Checkbox Selection Values
  final childrenSelection = ''.obs;
  final relationshipSelection = ''.obs;

  // Options Lists
  final List<String> childrenOptions = ['Yes', 'No'];
  final List<String> relationshipOptions = [
    'Single',
    'In a relationship',
    'Married',
    'Divorced',
    'Widowed'
  ];

  // Active Navigation Check
  final RxString currentSection = 'personal'.obs;

  final ScrollController scrollController = ScrollController();
  final Map<String, GlobalKey> sectionKeys = {
    'personal': GlobalKey(),
    'appearance': GlobalKey(),
    'lifestyle': GlobalKey(),
    'background': GlobalKey(),
    'connections': GlobalKey(),
  };

  void scrollToSection(String sectionName) {
    currentSection.value = sectionName;

    final key = sectionKeys[sectionName];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    initializeDropdownValues();
    retrieveUserData();
  }

  void initializeDropdownValues() {
    // Set default values for all dropdown controllers
    genderController.text = gender.first;
    selectedGender.value = gender.first;

    countryController.text = countries.first;
    selectedCountry.value = countries.first;

    bodyTypeController.text = bodyTypes.first;
    selectedBodyType.value = bodyTypes.first;

    drinkController.text = drinkingHabits.first;
    selectedDrink.value = drinkingHabits.first;

    smokeController.text = smokingHabits.first;
    selectedSmoke.value = smokingHabits.first;

    martialStatusController.text = maritalStatuses.first;
    selectedMaritalStatus.value = maritalStatuses.first;

    professionController.text = itJobs.first;
    selectedProfession.value = itJobs.first;

    employmentStatusController.text = employmentStatuses.first;
    selectedEmploymentStatus.value = employmentStatuses.first;

    livingSituationController.text = livingSituations.first;
    selectedLivingSituation.value = livingSituations.first;

    nationalityController.text = nationalities.first;
    selectedNationality.value = nationalities.first;

    educationController.text = highSchool.first;
    selectedEducation.value = highSchool.first;

    languageSpokenController.text = languages.first;
    selectedLanguage.value = languages.first;

    religionController.text = religion.first;
    selectedReligion.value = religion.first;

    ethnicityController.text = ethnicities.first;
    selectedEthnicity.value = ethnicities.first;

    childrenSelection.value = childrenOptions.first;
    relationshipSelection.value = relationshipOptions.first;
  }

  // Error handling helper
  void handleError(String message) {
    print(message);
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Load section methods
  void loadPersonalInfo(Map<String, dynamic> data) {
    nameController.text = data['name'] ?? '';
    emailController.text = data['email'] ?? '';
    ageController.text = (data['age'] ?? '').toString();
    phoneNoController.text = data['phoneNo'] ?? '';
    cityController.text = data['city'] ?? '';
    profileHeadingController.text = data['profileHeading'] ?? '';

    String genderData = data['gender'] ?? gender.first;
    selectedGender.value =
        gender.contains(genderData) ? genderData : gender.first;
    genderController.text = selectedGender.value;

    String countryData = data['country'] ?? countries.first;
    selectedCountry.value =
        countries.contains(countryData) ? countryData : countries.first;
    countryController.text = selectedCountry.value;
  }

  void loadAppearanceInfo(Map<String, dynamic> data) {
    heightController.text = data['height'] ?? '';
    weightController.text = data['weight'] ?? '';

    String bodyTypeData = data['bodyType'] ?? bodyTypes.first;
    selectedBodyType.value =
        bodyTypes.contains(bodyTypeData) ? bodyTypeData : bodyTypes.first;
    bodyTypeController.text = selectedBodyType.value;
  }

  void loadLifestyleInfo(Map<String, dynamic> data) {
    String drinkData = data['drink'] ?? drinkingHabits.first;
    selectedDrink.value =
        drinkingHabits.contains(drinkData) ? drinkData : drinkingHabits.first;
    drinkController.text = selectedDrink.value;

    String smokeData = data['smoke'] ?? smokingHabits.first;
    selectedSmoke.value =
        smokingHabits.contains(smokeData) ? smokeData : smokingHabits.first;
    smokeController.text = selectedSmoke.value;

    String martialData = data['martialStatus'] ?? maritalStatuses.first;
    selectedMaritalStatus.value = maritalStatuses.contains(martialData)
        ? martialData
        : maritalStatuses.first;
    martialStatusController.text = selectedMaritalStatus.value;

    childrenSelection.value = data['haveChildren'] ?? childrenOptions.first;
    noOfChildrenController.text = data['noOfChildren'] ?? '0';

    String professionData = data['profession'] ?? itJobs.first;
    selectedProfession.value =
        itJobs.contains(professionData) ? professionData : itJobs.first;
    professionController.text = selectedProfession.value;

    String employmentData =
        data['employmentStatus'] ?? employmentStatuses.first;
    selectedEmploymentStatus.value = employmentStatuses.contains(employmentData)
        ? employmentData
        : employmentStatuses.first;
    employmentStatusController.text = selectedEmploymentStatus.value;

    incomeController.text = data['income'] ?? '';

    String livingSituationData =
        data['livingSituation'] ?? livingSituations.first;
    selectedLivingSituation.value =
        livingSituations.contains(livingSituationData)
            ? livingSituationData
            : livingSituations.first;
    livingSituationController.text = selectedLivingSituation.value;

    relationshipSelection.value =
        data['relationshipStatus'] ?? relationshipOptions.first;
  }

  void loadBackgroundInfo(Map<String, dynamic> data) {
    String nationalityData = data['nationality'] ?? nationalities.first;
    selectedNationality.value = nationalities.contains(nationalityData)
        ? nationalityData
        : nationalities.first;
    nationalityController.text = selectedNationality.value;

    String educationData = data['education'] ?? highSchool.first;
    selectedEducation.value =
        highSchool.contains(educationData) ? educationData : highSchool.first;
    educationController.text = selectedEducation.value;

    String languageData = data['languageSpoken'] ?? languages.first;
    selectedLanguage.value =
        languages.contains(languageData) ? languageData : languages.first;
    languageSpokenController.text = selectedLanguage.value;

    String religionData = data['religion'] ?? religion.first;
    selectedReligion.value =
        religion.contains(religionData) ? religionData : religion.first;
    religionController.text = selectedReligion.value;

    String ethnicityData = data['ethnicity'] ?? ethnicities.first;
    selectedEthnicity.value =
        ethnicities.contains(ethnicityData) ? ethnicityData : ethnicities.first;
    ethnicityController.text = selectedEthnicity.value;
  }

  void loadConnectionsInfo(Map<String, dynamic> data) {
    linkedInController.text = data['linkedIn'] ?? '';
    instagramController.text = data['instagram'] ?? '';
    gitHubController.text = data['github'] ?? '';
  }

  void loadImages(Map<String, dynamic> data) {
    String? profileImageUrl = data['profileImageUrl'];
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      // Handle profile image if needed
    }

    images.clear();
    urlsList.clear();
    for (int i = 1; i <= 5; i++) {
      String? url = data['urlImage$i'];
      if (url != null && url.isNotEmpty) {
        urlsList.add(url);
        images.add(url);
      }
    }
  }

  void retrieveUserData() async {
    try {
      isLoading.value = true;
      var snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data()!;
        loadPersonalInfo(data);
        loadAppearanceInfo(data);
        loadLifestyleInfo(data);
        loadBackgroundInfo(data);
        loadConnectionsInfo(data);
        loadImages(data);
      } else {
        handleError("User document does not exist");
      }
    } catch (e) {
      handleError('Error retrieving user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Image handling methods
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedImage.value = File(pickedFile.path);
    }
  }

  Future<void> captureImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      pickedImage.value = File(pickedFile.path);
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => null);
      return await storageReference.getDownloadURL();
    } catch (e) {
      handleError('Error uploading profile image: $e');
      return null;
    }
  }

  Future<void> uploadImages() async {
    for (var i = 0; i < images.length; i++) {
      var img = images[i];
      uploadProgress.value = i / images.length;

      if (img is File) {
        try {
          var refImages = FirebaseStorage.instance
              .ref()
              .child("images/${DateTime.now().millisecondsSinceEpoch}.jpg");
          await refImages.putFile(img);
          var downloadUrl = await refImages.getDownloadURL();
          urlsList.add(downloadUrl);
        } catch (e) {
          handleError('Error uploading image: $e');
        }
      } else if (img is String) {
        urlsList.add(img);
      }
    }
  }

  void addImage(XFile pickedFile) {
    if (images.length < 5) {
      images.add(File(pickedFile.path));
    } else {
      Get.snackbar("Maximum Images", "You can only select up to 5 images");
    }
  }

  void removeImage(int index) {
    if (index < images.length) {
      if (images[index] is String) {
        urlsList.remove(images[index]);
      }
      images.removeAt(index);
    }
  }

  // Update methods
  void updateChildrenOption(String option) {
    childrenSelection.value = option;
  }

  void updateRelationshipOption(String option) {
    relationshipSelection.value = option;
  }

  Future<void> updateUserDataToFirestore() async {
    try {
      uploading.value = true;
      await uploadImages();

      String? profileImageUrl;
      if (pickedImage.value != null) {
        profileImageUrl = await uploadProfileImage(pickedImage.value!);
      }

      final userData = {
        // Personal Info
        'name': nameController.text,
        'email': emailController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'phoneNo': phoneNoController.text,
        'city': cityController.text,
        'country': countryController.text,
        'profileHeading': profileHeadingController.text,
        'gender': genderController.text,

        // Appearance
        'height': heightController.text,
        'weight': weightController.text,
        'bodyType': bodyTypeController.text,

        // Life style
        'drink': drinkController.text,
        'smoke': smokeController.text,
        'martialStatus': martialStatusController.text,
        'haveChildren': childrenSelection.value,
        'noOfChildren': noOfChildrenController.text,
        'profession': professionController.text,
        'employmentStatus': employmentStatusController.text,
        'income': incomeController.text,
        'livingSituation': livingSituationController.text,
        'relationshipStatus': relationshipSelection.value,

        // Background
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
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'urlImage1': urlsList.isNotEmpty ? urlsList[0] : '',
        'urlImage2': urlsList.length > 1 ? urlsList[1] : '',
        'urlImage3': urlsList.length > 2 ? urlsList[2] : '',
        'urlImage4': urlsList.length > 3 ? urlsList[3] : '',
        'urlImage5': urlsList.length > 4 ? urlsList[4] : '',
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .update(userData);

      Get.snackbar(
        "Success",
        "Your account has been updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      handleError('Error updating user data: $e');
    } finally {
      uploading.value = false;
      images.clear();
      urlsList.clear();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    phoneNoController.dispose();
    cityController.dispose();
    countryController.dispose();
    profileHeadingController.dispose();
    genderController.dispose();
    heightController.dispose();
    weightController.dispose();
    bodyTypeController.dispose();
    drinkController.dispose();
    smokeController.dispose();
    martialStatusController.dispose();
    noOfChildrenController.dispose();
    professionController.dispose();
    employmentStatusController.dispose();
    incomeController.dispose();
    livingSituationController.dispose();
    nationalityController.dispose();
    educationController.dispose();
    languageSpokenController.dispose();
    religionController.dispose();
    ethnicityController.dispose();
    instagramController.dispose();
    linkedInController.dispose();
    gitHubController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
