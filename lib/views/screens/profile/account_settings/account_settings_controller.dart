import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:tuncforwork/models/work_experience.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:tuncforwork/constants/app_strings.dart';

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

  // Work Experience
  final RxList<WorkExperience> workExperiences = <WorkExperience>[].obs;
  final RxList<String> skills = <String>[].obs;

  // Work Experience Form Controllers
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final skillController = TextEditingController();

  // Dropdown Values
  final RxMap<String, List<String>> dropdownValues =
      <String, List<String>>{}.obs;

  Future<void> loadDropdownValues() async {
    try {
      log(AppStrings.loadingDropdownValues);
      final values = await getAllDropdownValues();

      if (values.isEmpty) {
        log(AppStrings.warningEmptyDropdownValues);
        // Varsayılan değerleri kullan
        dropdownValues.value = {
          'genders': gender,
          'countries': countries,
          'bodyTypes': bodyTypes,
          'drinkingHabits': drinkingHabits,
          'smokingHabits': smokingHabits,
          'maritalStatuses': maritalStatuses,
          'employmentStatuses': employmentStatuses,
          'livingSituations': livingSituations,
          'nationalities': nationalities,
          'educationLevels': educationLevels,
          'languages': languages,
          'religions': religion,
          'ethnicities': ethnicities,
          'professions': itJobs,
        };
      } else {
        log('${AppStrings.dropdownValuesLoadedSuccessfully}: ${values.keys.join(", ")}');
        dropdownValues.value = values;
      }
    } catch (e, stackTrace) {
      log('${AppStrings.errorLoadingDropdownValues}: $e');
      log('Stack trace: $stackTrace');
      // Hata durumunda varsayılan değerleri kullan
      dropdownValues.value = {
        'genders': gender,
        'countries': countries,
        'bodyTypes': bodyTypes,
        'drinkingHabits': drinkingHabits,
        'smokingHabits': smokingHabits,
        'maritalStatuses': maritalStatuses,
        'employmentStatuses': employmentStatuses,
        'livingSituations': livingSituations,
        'nationalities': nationalities,
        'educationLevels': educationLevels,
        'languages': languages,
        'religions': religion,
        'ethnicities': ethnicities,
        'professions': itJobs,
      };
    }
  }

  @override
  void onInit() {
    super.onInit();
    log('AccountSettingsController onInit called');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      log(AppStrings.initializationStarted);

      // Önce kullanıcı verilerini yükle
      await retrieveUserData();
      log(AppStrings.userDataLoaded);

      // Sonra dropdown değerlerini yükle
      await loadDropdownValues();
      log(AppStrings.dropdownValuesLoaded);

      // İş deneyimi ve yetenekleri yükle
      await Future.wait([
        loadWorkExperiences()
            .then((_) => log(AppStrings.workExperiencesLoadingCompleted)),
        loadSkills().then((_) => log(AppStrings.skillsLoadingCompleted)),
      ]);
      log(AppStrings.workExperienceAndSkillsLoaded);

      // En son dropdown değerlerini başlat
      initializeDropdownValues();
      log(AppStrings.dropdownValuesInitialized);
    } catch (e, stackTrace) {
      log('${AppStrings.initializationError}: $e');
      log('Stack trace: $stackTrace');
      handleError('Error initializing controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retrieveUserData() async {
    try {
      log('${AppStrings.retrievingUserData}. ID: $currentUserId');
      var snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .get();

      if (!snapshot.exists) {
        log('${AppStrings.documentNotFound}. User ID: $currentUserId');
        handleError("User document does not exist");
        return;
      }

      var data = snapshot.data()!;
      log(AppStrings.userDataRetrievedSuccessfully);
      log('${AppStrings.dataFieldsRetrieved}: ${data.keys.join(", ")}');

      // Önce resimleri yükle
      await _loadImages(data);
      log(AppStrings.imagesLoaded);

      // Sonra diğer verileri yükle
      await _loadAllData(data);
      log(AppStrings.allDataLoaded);

      // Dropdown değerlerini güncelle
      _updateDropdownValues(data);
      log(AppStrings.dropdownValuesUpdated);

      // Checkbox değerlerini güncelle
      childrenSelection.value = data['haveChildren']?.toString() ?? '';
      relationshipSelection.value =
          data['relationshipStatus']?.toString() ?? '';
      log(AppStrings.checkboxValuesUpdated);
    } catch (e, stackTrace) {
      log('${AppStrings.errorRetrievingUserData}: $e');
      log('Stack trace: $stackTrace');
      handleError('Error retrieving user data: $e');
    }
  }

  Future<void> _loadAllData(Map<String, dynamic> data) async {
    try {
      log(AppStrings.loadAllDataStarted);
      log('${AppStrings.dataFieldsToLoad}: ${data.keys.join(", ")}');

      // Personal Info
      nameController.text = data['name']?.toString() ?? '';
      emailController.text = data['email']?.toString() ?? '';
      ageController.text = data['age']?.toString() ?? '';
      phoneNoController.text = data['phoneNo']?.toString() ?? '';
      cityController.text = data['city']?.toString() ?? '';
      countryController.text = data['country']?.toString() ?? '';
      profileHeadingController.text = data['profileHeading']?.toString() ?? '';
      genderController.text = data['gender']?.toString() ?? '';

      // Appearance
      heightController.text = data['height']?.toString() ?? '';
      weightController.text = data['weight']?.toString() ?? '';
      bodyTypeController.text = data['bodyType']?.toString() ?? '';

      // Lifestyle
      drinkController.text = data['drink']?.toString() ?? '';
      smokeController.text = data['smoke']?.toString() ?? '';
      martialStatusController.text = data['martialStatus']?.toString() ?? '';
      childrenSelection.value = data['haveChildren']?.toString() ?? '';
      noOfChildrenController.text = data['noOfChildren']?.toString() ?? '0';
      professionController.text = data['profession']?.toString() ?? '';
      employmentStatusController.text =
          data['employmentStatus']?.toString() ?? '';
      incomeController.text = data['income']?.toString() ?? '';
      livingSituationController.text =
          data['livingSituation']?.toString() ?? '';
      relationshipSelection.value =
          data['relationshipStatus']?.toString() ?? '';

      // Background
      nationalityController.text = data['nationality']?.toString() ?? '';
      educationController.text = data['education']?.toString() ?? '';
      languageSpokenController.text = data['languageSpoken']?.toString() ?? '';
      religionController.text = data['religion']?.toString() ?? '';
      ethnicityController.text = data['ethnicity']?.toString() ?? '';

      // Social Links
      instagramController.text = data['instagramUrl']?.toString() ?? '';

      log(AppStrings.loadAllDataCompleted);
      log(AppStrings.loadedValues);
      log('Name: ${nameController.text}');
      log('Email: ${emailController.text}');
      log('Age: ${ageController.text}');
      log('Gender: ${genderController.text}');
      log('Country: ${countryController.text}');
      log('Body Type: ${bodyTypeController.text}');
      log('Profession: ${professionController.text}');
      log('Education: ${educationController.text}');
      log('Instagram: ${instagramController.text}');
    } catch (e, stackTrace) {
      log('${AppStrings.loadAllDataError}: $e');
      log('Stack trace: $stackTrace');
      handleError('Error loading data: $e');
    }
  }

  Future<void> _loadImages(Map<String, dynamic> data) async {
    try {
      log(AppStrings.loadingImages);
      images.clear();
      urlsList.clear();

      // Profile image varsa ekle
      String? profileImageUrl = data['profileImageUrl'];
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        log('${AppStrings.profileImageFound}: $profileImageUrl');
        urlsList.add(profileImageUrl);
        images.add(profileImageUrl);
      } else {
        log(AppStrings.profileImageNotFound);
      }

      // Diğer resimleri ekle
      for (int i = 1; i <= 5; i++) {
        String? url = data['urlImage$i'];
        if (url != null && url.isNotEmpty) {
          log('urlImage$i bulundu: $url');
          urlsList.add(url);
          images.add(url);
        }
      }

      log('${AppStrings.totalImagesLoaded}: ${images.length}');
      log('URLs: ${urlsList.join(", ")}');
    } catch (e, stackTrace) {
      log('${AppStrings.errorLoadingImages}: $e');
      log('Stack trace: $stackTrace');
    }
  }

  void _updateDropdownValues(Map<String, dynamic> data) {
    selectedGender.value = data['gender']?.toString() ?? gender.first;
    selectedCountry.value = data['country']?.toString() ?? countries.first;
    selectedBodyType.value = data['bodyType']?.toString() ?? bodyTypes.first;
    selectedDrink.value = data['drink']?.toString() ?? drinkingHabits.first;
    selectedSmoke.value = data['smoke']?.toString() ?? smokingHabits.first;
    selectedMaritalStatus.value =
        data['martialStatus']?.toString() ?? maritalStatuses.first;
    selectedProfession.value = data['profession']?.toString() ?? itJobs.first;
    selectedEmploymentStatus.value =
        data['employmentStatus']?.toString() ?? employmentStatuses.first;
    selectedLivingSituation.value =
        data['livingSituation']?.toString() ?? livingSituations.first;
    selectedNationality.value =
        data['nationality']?.toString() ?? nationalities.first;
    selectedEducation.value =
        data['education']?.toString() ?? educationLevels.first;
    selectedLanguage.value =
        data['languageSpoken']?.toString() ?? languages.first;
    selectedReligion.value = data['religion']?.toString() ?? religion.first;
    selectedEthnicity.value =
        data['ethnicity']?.toString() ?? ethnicities.first;
  }

  void handleError(String message) {
    log('Error: $message');
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(8),
    );
  }

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

  // @override
  // void onInit() {
  //   super.onInit();
  //   initializeDropdownValues();
  //   retrieveUserData();
  // }

  void initializeDropdownValues() {
    try {
      log('initializeDropdownValues başlatıldı');
      log('Mevcut değerler: ${dropdownValues.toString()}');

      // Eğer Firestore'dan gelen değer varsa onu kullan, yoksa varsayılan değeri kullan
      genderController.text = genderController.text.isNotEmpty
          ? genderController.text
          : (dropdownValues['genders']?.firstOrNull ?? gender.first);

      countryController.text = countryController.text.isNotEmpty
          ? countryController.text
          : (dropdownValues['countries']?.firstOrNull ?? countries.first);

      bodyTypeController.text = bodyTypeController.text.isNotEmpty
          ? bodyTypeController.text
          : (dropdownValues['bodyTypes']?.firstOrNull ?? bodyTypes.first);

      drinkController.text = drinkController.text.isNotEmpty
          ? drinkController.text
          : (dropdownValues['drinkingHabits']?.firstOrNull ??
              drinkingHabits.first);

      smokeController.text = smokeController.text.isNotEmpty
          ? smokeController.text
          : (dropdownValues['smokingHabits']?.firstOrNull ??
              smokingHabits.first);

      martialStatusController.text = martialStatusController.text.isNotEmpty
          ? martialStatusController.text
          : (dropdownValues['maritalStatuses']?.firstOrNull ??
              maritalStatuses.first);

      employmentStatusController.text =
          employmentStatusController.text.isNotEmpty
              ? employmentStatusController.text
              : (dropdownValues['employmentStatuses']?.firstOrNull ??
                  employmentStatuses.first);

      livingSituationController.text = livingSituationController.text.isNotEmpty
          ? livingSituationController.text
          : (dropdownValues['livingSituations']?.firstOrNull ??
              livingSituations.first);

      nationalityController.text = nationalityController.text.isNotEmpty
          ? nationalityController.text
          : (dropdownValues['nationalities']?.firstOrNull ??
              nationalities.first);

      educationController.text = educationController.text.isNotEmpty
          ? educationController.text
          : (dropdownValues['educationLevels']?.firstOrNull ??
              educationLevels.first);

      languageSpokenController.text = languageSpokenController.text.isNotEmpty
          ? languageSpokenController.text
          : (dropdownValues['languages']?.firstOrNull ?? languages.first);

      religionController.text = religionController.text.isNotEmpty
          ? religionController.text
          : (dropdownValues['religions']?.firstOrNull ?? religion.first);

      ethnicityController.text = ethnicityController.text.isNotEmpty
          ? ethnicityController.text
          : (dropdownValues['ethnicities']?.firstOrNull ?? ethnicities.first);

      professionController.text = professionController.text.isNotEmpty
          ? professionController.text
          : (dropdownValues['professions']?.firstOrNull ?? itJobs.first);

      log('Dropdown değerleri başlatıldı');
      log('Güncel değerler:');
      log('Gender: ${genderController.text}');
      log('Country: ${countryController.text}');
      log('Body Type: ${bodyTypeController.text}');
      log('Profession: ${professionController.text}');
      // ... diğer değerler için de log ekleyebilirsiniz
    } catch (e) {
      log('Dropdown değerleri başlatılırken hata: $e');
    }
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

    String educationData = data['education'] ?? educationLevels.first;
    selectedEducation.value = educationLevels.contains(educationData)
        ? educationData
        : educationLevels.first;
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
    instagramController.text = data['instagramUrl'] ?? '';
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

  // void retrieveUserData() async {
  //   try {
  //     isLoading.value = true;
  //     var snapshot = await FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(currentUserId)
  //         .get();

  //     if (snapshot.exists) {
  //       var data = snapshot.data()!;
  //       loadPersonalInfo(data);
  //       loadAppearanceInfo(data);
  //       loadLifestyleInfo(data);
  //       loadBackgroundInfo(data);
  //       loadConnectionsInfo(data);
  //       loadImages(data);
  //     } else {
  //       handleError("User document does not exist");
  //     }
  //   } catch (e) {
  //     handleError('Error retrieving user data: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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
        'instagramUrl': instagramController.text,

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

  Future<void> addWorkExperience() async {
    try {
      log(AppStrings.addingWorkExperience);
      if (titleController.text.isEmpty || companyController.text.isEmpty) {
        handleError('Job title and company fields are required');
        return;
      }

      final experience = WorkExperience(
        title: titleController.text,
        company: companyController.text,
        startDate: startDateController.text,
        endDate: endDateController.text,
        description: descriptionController.text,
        technologies: [],
      );

      log('${AppStrings.workExperienceCreated}: ${experience.toMap()}');

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('workExperience')
          .add(experience.toMap());

      log('${AppStrings.workExperienceAddedToFirestore}. ID: ${docRef.id}');

      workExperiences.add(experience);
      clearWorkExperienceForm();

      Get.snackbar(
        AppStrings.success,
        AppStrings.workExperienceAddedSuccessfully,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );
    } catch (e, stackTrace) {
      log('${AppStrings.errorAddingWorkExperience}: $e');
      log('Stack trace: $stackTrace');
      handleError('Error adding work experience: $e');
    }
  }

  Future<void> addSkill(String skill) async {
    try {
      log('${AppStrings.addingSkill}: $skill');
      if (skill.isEmpty) {
        handleError('Skill field cannot be empty');
        return;
      }

      if (!skills.contains(skill)) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .update({
          'skills': FieldValue.arrayUnion([skill])
        });

        skills.add(skill);
        log(AppStrings.skillAddedSuccessfully);

        Get.snackbar(
          AppStrings.success,
          AppStrings.skillAddedSuccessfully,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
        );
      } else {
        log(AppStrings.skillAlreadyExists);
        Get.snackbar(
          AppStrings.warning,
          AppStrings.skillAlreadyExists,
          backgroundColor: Colors.orange.shade50,
          colorText: Colors.orange.shade900,
        );
      }
    } catch (e, stackTrace) {
      log('${AppStrings.errorAddingSkill}: $e');
      log('Stack trace: $stackTrace');
      handleError('Error adding skill: $e');
    }
  }

  Future<void> removeSkill(String skill) async {
    try {
      log('${AppStrings.removingSkill}: $skill');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'skills': FieldValue.arrayRemove([skill])
      });

      skills.remove(skill);
      log(AppStrings.skillRemovedSuccessfully);

      Get.snackbar(
        AppStrings.success,
        AppStrings.skillRemovedSuccessfully,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );
    } catch (e, stackTrace) {
      log('${AppStrings.errorRemovingSkill}: $e');
      log('Stack trace: $stackTrace');
      handleError('Error removing skill: $e');
    }
  }

  void clearWorkExperienceForm() {
    titleController.clear();
    companyController.clear();
    startDateController.clear();
    endDateController.clear();
    descriptionController.clear();
  }

  Future<void> loadWorkExperiences() async {
    try {
      log(AppStrings.loadingWorkExperiences);
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('workExperience')
          .orderBy('startDate', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        log(AppStrings.noWorkExperienceFound);
        workExperiences.clear();
        return;
      }

      workExperiences.value = snapshot.docs
          .map((doc) {
            log('Work experience loaded: ${doc.data()}');
            try {
              return WorkExperience.fromMap(doc.data());
            } catch (e) {
              log('Error parsing work experience ${doc.id}: $e');
              log('Data: ${doc.data()}');
              // Hatalı veriyi atla ve devam et
              return null;
            }
          })
          .where((exp) => exp != null)
          .cast<WorkExperience>()
          .toList();

      log('${AppStrings.totalWorkExperiencesLoaded}: ${workExperiences.length}');
    } catch (e, stackTrace) {
      log('${AppStrings.errorLoadingWorkExperiences}: $e');
      log('Stack trace: $stackTrace');
      handleError('Error loading work experiences: $e');
    }
  }

  Future<void> loadSkills() async {
    try {
      log(AppStrings.loadingSkills);
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!doc.exists) {
        log('User document not found');
        return;
      }

      if (doc.data()!.containsKey('skills')) {
        final skillsData = doc.data()!['skills'];

        if (skillsData is List) {
          // Skills verisi List olarak geliyor
          if (skillsData.isNotEmpty &&
              skillsData.first is Map<String, dynamic>) {
            // Map listesi olarak geliyor (Skill objesi)
            skills.value = skillsData
                .map((skillMap) => skillMap['name'] as String)
                .where((name) => name != null)
                .cast<String>()
                .toList();
          } else if (skillsData.isNotEmpty && skillsData.first is String) {
            // String listesi olarak geliyor
            skills.value = List<String>.from(skillsData);
          } else {
            // Boş liste
            skills.clear();
          }
        } else {
          log('Skills data is not a list');
          skills.clear();
        }

        log('${AppStrings.skillsLoadedSuccessfully}: ${skills.join(", ")}');
      } else {
        log(AppStrings.skillsNotFoundOrEmpty);
        skills.clear();
      }
    } catch (e, stackTrace) {
      log('${AppStrings.errorLoadingSkills}: $e');
      log('Stack trace: $stackTrace');
      handleError('Error loading skills: $e');
    }
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        final formattedDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        if (isStartDate) {
          startDateController.text = formattedDate;
          log('${AppStrings.startDateSelected}: $formattedDate');
        } else {
          endDateController.text = formattedDate;
          log('${AppStrings.endDateSelected}: $formattedDate');
        }
      }
    } catch (e) {
      log('${AppStrings.dateSelectionError}: $e');
      handleError('Error selecting date: $e');
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
    scrollController.dispose();
    super.onClose();
  }
}
