import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuncforwork/models/person.dart' as pM;
import 'package:tuncforwork/views/screens/home/home_bindings.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxBool showProgressBar = false.obs;

  // TextEditingControllers for all fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController profileHeadingController =
      TextEditingController();
  final TextEditingController lookingForInaPartnerController =
      TextEditingController();
  final TextEditingController genderController = TextEditingController();

  // Appearance
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bodyTypeController = TextEditingController();

  // Life style
  final TextEditingController drinkController = TextEditingController();
  final TextEditingController smokeController = TextEditingController();
  final TextEditingController martialStatusController = TextEditingController();
  final TextEditingController haveChildrenController = TextEditingController();
  final TextEditingController noOfChildrenController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController employmentStatusController =
      TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController livingSituationController =
      TextEditingController();
  final TextEditingController willingToRelocateController =
      TextEditingController();
  final TextEditingController relationshipYouAreLookingForController =
      TextEditingController();

  // Connections
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController githubController = TextEditingController();

  // Background - Cultural Values
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController languageSpokenController =
      TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController ethnicityController = TextEditingController();

  Rx<File?> pickedImage = Rx<File?>(null);

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  Future<void> register() async {
    showProgressBar.value = true;
    try {
      if (_validateSignupFields()) {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        String photoUrl = await _uploadProfilePicture(userCredential.user!.uid);

        pM.Person newUser = pM.Person(
          uid: userCredential.user!.uid,
          imageProfile: photoUrl,
          email: emailController.text,
          password: passwordController.text,
          name: nameController.text,
          age: int.parse(ageController.text),
          phoneNo: phoneNoController.text,
          city: cityController.text,
          country: countryController.text,
          profileHeading: profileHeadingController.text,
          lookingForInaPartner: lookingForInaPartnerController.text,
          gender: genderController.text,
          publishedDateTime: DateTime.now().millisecondsSinceEpoch,
          height: heightController.text,
          weight: weightController.text,
          bodyType: bodyTypeController.text,
          drink: drinkController.text,
          smoke: smokeController.text,
          martialStatus: martialStatusController.text,
          haveChildren: haveChildrenController.text,
          noOfChildren: noOfChildrenController.text,
          profession: professionController.text,
          employmentStatus: employmentStatusController.text,
          income: incomeController.text,
          livingSituation: livingSituationController.text,
          willingToRelocate: willingToRelocateController.text,
          relationshipYouAreLookingFor:
              relationshipYouAreLookingForController.text,
          nationality: nationalityController.text,
          education: educationController.text,
          languageSpoken: languageSpokenController.text,
          religion: religionController.text,
          ethnicity: ethnicityController.text,
          linkedInUrl: linkedInController.text,
          instagramUrl: instagramController.text,
          githubUrl: githubController.text,
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toJson());

        Get.snackbar('Success', 'Account created successfully');
        Get.offAll(() => const HomeScreen());
      }
    } catch (error) {
      Get.snackbar('Error', error.toString());
    } finally {
      showProgressBar.value = false;
    }
  }

  Future<void> login() async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Get.offAll(() => const HomeScreen(), binding: HomeBindings());
    } catch (error) {
      Get.snackbar('Error', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

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

  Future<String> _uploadProfilePicture(String uid) async {
    if (pickedImage.value == null) return '';
    Reference ref = _storage.ref().child('profile_pictures').child(uid);
    await ref.putFile(pickedImage.value!);
    return await ref.getDownloadURL();
  }

  bool _validateSignupFields() {
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
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
    linkedInController.dispose();
    instagramController.dispose();
    githubController.dispose();
    nationalityController.dispose();
    educationController.dispose();
    languageSpokenController.dispose();
    religionController.dispose();
    ethnicityController.dispose();
    super.onClose();
  }
}
