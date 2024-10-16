import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class AccountSettingsController extends GetxController {
  RxBool uploading = false.obs;
  RxBool next = false.obs;
  RxList<dynamic> images = <dynamic>[].obs;
  RxList<String> urlsList = <String>[].obs;
  RxDouble uploadProgress = 0.0.obs;

  // Profile Image
  Rx<File?> pickedImage = Rx<File?>(null);

  // Personal Info
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final phoneNoController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final profileHeadingController = TextEditingController();
  final genderController = TextEditingController();

  // Appearance
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final bodyTypeController = TextEditingController();

  // Life style
  final drinkController = TextEditingController();
  final smokeController = TextEditingController();
  final martialStatusController = TextEditingController();
  final childrenSelection = ''.obs;
  final noOfChildrenController = TextEditingController();
  final professionController = TextEditingController();
  final employmentStatusController = TextEditingController();
  final incomeController = TextEditingController();
  final livingSituationController = TextEditingController();
  final relationshipSelection = ''.obs;

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

  // Options for checkbox groups
  List<String> childrenOptions = ['Yes', 'No'];
  List<String> relationshipOptions = [
    'Single',
    'In a relationship',
    'Married',
    'Divorced',
    'Widowed'
  ];

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
      emailController.text = data['email'] ?? '';
      ageController.text = data['age']?.toString() ?? '';
      phoneNoController.text = data['phoneNo'] ?? '';
      cityController.text = data['city'] ?? '';
      countryController.text = data['country'] ?? '';
      profileHeadingController.text = data['profileHeading'] ?? '';
      genderController.text = data['gender'] ?? '';

      // Appearance
      heightController.text = data['height'] ?? '';
      weightController.text = data['weight'] ?? '';
      bodyTypeController.text = data['bodyType'] ?? '';

      // Life style
      drinkController.text = data['drink'] ?? '';
      smokeController.text = data['smoke'] ?? '';
      martialStatusController.text = data['martialStatus'] ?? '';
      childrenSelection.value = data['haveChildren'] ?? '';
      noOfChildrenController.text = data['noOfChildren'] ?? '';
      professionController.text = data['profession'] ?? '';
      employmentStatusController.text = data['employmentStatus'] ?? '';
      incomeController.text = data['income'] ?? '';
      livingSituationController.text = data['livingSituation'] ?? '';
      relationshipSelection.value = data['relationshipStatus'] ?? '';

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

      // Profile Image
      String? profileImageUrl = data['profileImageUrl'];
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        // You might want to download and set the image file here
      }

      // Mevcut fotoğrafları yükle
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
  }

  Future<void> updateUserDataToFirestore() async {
    uploading.value = true;
    await uploadImages();

    String? profileImageUrl;
    if (pickedImage.value != null) {
      profileImageUrl = await uploadProfileImage(pickedImage.value!);
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .update({
      // Personal Info
      'name': nameController.text,
      'email': emailController.text,
      'age': int.parse(ageController.text),
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

      // Profile Image
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,

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
  }

  // bool allFieldsValid() {
  //   return nameController.text.isNotEmpty &&
  //       emailController.text.isNotEmpty &&
  //       ageController.text.isNotEmpty &&
  //       phoneNoController.text.isNotEmpty &&
  //       cityController.text.isNotEmpty &&
  //       countryController.text.isNotEmpty &&
  //       profileHeadingController.text.isNotEmpty &&
  //       genderController.text.isNotEmpty &&
  //       heightController.text.isNotEmpty &&
  //       weightController.text.isNotEmpty &&
  //       bodyTypeController.text.isNotEmpty &&
  //       drinkController.text.isNotEmpty &&
  //       smokeController.text.isNotEmpty &&
  //       martialStatusController.text.isNotEmpty &&
  //       childrenSelection.value.isNotEmpty &&
  //       noOfChildrenController.text.isNotEmpty &&
  //       professionController.text.isNotEmpty &&
  //       employmentStatusController.text.isNotEmpty &&
  //       incomeController.text.isNotEmpty &&
  //       livingSituationController.text.isNotEmpty &&
  //       relationshipSelection.value.isNotEmpty &&
  //       nationalityController.text.isNotEmpty &&
  //       educationController.text.isNotEmpty &&
  //       languageSpokenController.text.isNotEmpty &&
  //       religionController.text.isNotEmpty &&
  //       ethnicityController.text.isNotEmpty;
  // }

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
      String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  Future<void> uploadImages() async {
    for (var i = 0; i < images.length; i++) {
      var img = images[i];
      uploadProgress.value = i / images.length;

      if (img is File) {
        var refImages = FirebaseStorage.instance
            .ref()
            .child("images/${DateTime.now().millisecondsSinceEpoch}.jpg");
        await refImages.putFile(img);
        var downloadUrl = await refImages.getDownloadURL();
        urlsList.add(downloadUrl);
      } else if (img is String) {
        // If it's already a URL, just add it to the list
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

  void updateChildrenOption(String option) {
    childrenSelection.value = option;
  }

  void updateRelationshipOption(String option) {
    relationshipSelection.value = option;
  }

  @override
  void onClose() {
    // Dispose all controllers
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

    super.onClose();
  }
}
