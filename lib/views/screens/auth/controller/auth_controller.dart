import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'package:tuncforwork/models/person.dart' as pM;
import 'package:tuncforwork/service/validation.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_bindings.dart';
import 'package:tuncforwork/views/screens/home/home_bindings.dart';
import 'package:tuncforwork/views/screens/screens.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxBool showProgressBar = false.obs;
  RxBool termsAccepted = false.obs;
  late PageController pageController;
  RxInt currentPage = 0.obs;
  RxBool obsPass = false.obs;

  // Form Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController profileHeadingController =
      TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bodyTypeController = TextEditingController();
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
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController githubController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController languageSpokenController =
      TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController ethnicityController = TextEditingController();

  // Image picker
  Rx<File?> pickedImage = Rx<File?>(null);

  // Selection variables
  final childrenSelection = RxString('No');
  final relationshipSelection = RxString('Single');
  var radioHaveChildrenController = ''.obs;
  var radioRelationshipStatusController = ''.obs;

  // Options lists
  final childrenOptions = ['Yes', 'No'];
  final relationshipOptions = [
    'Single',
    'In a relationship',
    'Married',
    "It's complicated"
  ];

  // EULA and Privacy Policy
  final String eula = '''
   End User License Agreement (EULA)
Last updated: November 12, 2024
1. Introduction
This End User License Agreement ("Agreement" or "EULA") is a legal agreement between you ("User", "you", or "your") and TuncForWork ("we", "us", "our", or "Company") for the use of the TuncForWork mobile application ("App").
2. Acceptance of Terms
By downloading, installing, or using the App, you agree to be bound by this Agreement. If you do not agree to these terms, do not use the App.
3. License Grant
Subject to your compliance with this Agreement, we grant you a limited, non-exclusive, non-transferable, revocable license to use the App for your personal, non-commercial purposes.
4. User Registration and Account Security
4.1. You must be at least 18 years old to use the App.
4.2. You are responsible for maintaining the confidentiality of your account credentials.
4.3. You agree to provide accurate, current, and complete information during registration.
4.4. You are solely responsible for all activities that occur under your account.
5. User Content and Conduct
5.1. You retain ownership of content you submit to the App.
5.2. You grant us a worldwide, non-exclusive license to use, modify, and display your content.
5.3. You agree not to:

Post illegal, harmful, or offensive content
Impersonate others
Use the App for unauthorized commercial purposes
Attempt to bypass security measures
Share malware or viruses

6. Privacy
6.1. Our Privacy Policy explains how we collect, use, and protect your information.
6.2. By using the App, you consent to our privacy practices.
7. Data Usage and Storage
7.1. The App requires access to:

Camera and photo library
Location services
Push notifications
Network connectivity
7.2. You are responsible for any data charges incurred while using the App.

8. Intellectual Property Rights
8.1. All rights, title, and interest in the App remain with us.
8.2. You may not:

Modify or create derivative works
Reverse engineer the App
Remove copyright notices
Use branding without permission

9. Termination
9.1. We may terminate your access to the App at any time for violations of this Agreement.
9.2. You may terminate this Agreement by uninstalling the App.
10. Disclaimer of Warranties
THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND.
11. Limitation of Liability
WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES.
12. Changes to Agreement
We reserve the right to modify this Agreement at any time.
13. Governing Law
This Agreement is governed by the laws of [Your Jurisdiction].
  ''';

  final String privacyPolicy = '''
   TuncForWork Privacy
TuncWFinder Privacy Policy
Last updated: 19/08/2024
This privacy policy explains how information is collected, used, protected, and disclosed during the use of the TuncWFinder application. By using the application, you agree to the practices described in this policy.
1. Information Collected
The application may collect the following information:

Camera and photo library access: For taking profile pictures and sharing content
Microphone access: For voice messages and video recordings
Apple Music access: For using music features (when necessary)
Notification permissions: For sending important updates and information

2. Use of Information
The collected information is used for the following purposes:

To provide and improve application functionality
To personalize user experience
To troubleshoot technical issues and analyze application performance
To comply with legal obligations

3. Information Sharing
User information is not shared with third parties except in the following circumstances:

When the user gives explicit permission
When there is a legal obligation
When necessary to protect the rights of the application

4. Data Security
Appropriate technical and organizational measures are taken to ensure the security of user information. However, please note that transmission methods over the internet or electronic storage are not 100% secure.
5. Children’s Privacy
The application does not knowingly collect personal information from children under 13 years of age. If you are a parent or guardian and believe that your child has provided us with personal information, please contact us.
6. Changes to This Policy
This privacy policy may be updated from time to time. Changes will be posted on this page, and users will be notified in case of significant changes.
7. Contact
If you have any questions about this privacy policy, please contact us at:
email: ismail.tunc.kankilic@gmail.com
By accepting this privacy policy, you declare that you understand and agree to the terms stated herein.
  ''';

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  // // Error handling
  // void _showError(String message) {
  //   Get.snackbar(
  //     'Error',
  //     message,
  //     snackPosition: SnackPosition.BOTTOM,
  //     backgroundColor: Colors.red,
  //     colorText: Colors.white,
  //     duration: const Duration(seconds: 3),
  //   );
  // }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Selection updates
  void updateChildrenOption(String value) {
    childrenSelection.value = value;
  }

  void updateRelationshipOption(String value) {
    relationshipSelection.value = value;
  }

  void updateHaveChildren(String value) {
    radioHaveChildrenController.value = value;
  }

  void updateRelationshipStatus(String value) {
    radioRelationshipStatusController.value = value;
  }

  // Terms acceptance
  void updateTermsAcceptance(bool accepted) {
    termsAccepted.value = accepted;
    update();
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value--;
    }
  }

  // Image picking
  Future<void> pickImage() async {
    try {
      isLoading.value = true;

      // Check permissions
      var status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
        if (status.isDenied) {
          _showError('Please allow access to your gallery to select a photo');
          return;
        }
      }

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        pickedImage.value = File(pickedFile.path);
        _showSuccess('Image selected successfully');
      }
    } catch (e) {
      print('Error picking image: $e');
      _showError('Failed to pick image. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> captureImage() async {
    try {
      isLoading.value = true;

      var status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
        if (status.isDenied) {
          _showError('Please allow access to your camera to take a photo');
          return;
        }
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        pickedImage.value = File(pickedFile.path);
        _showSuccess('Photo captured successfully');
      }
    } catch (e) {
      print('Error capturing image: $e');
      _showError('Failed to capture image. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    try {
      // Step 1: Initial Validation Checks
      // Check if passwords match
      if (passwordController.text != confirmPasswordController.text) {
        _showError('Passwords do not match');
        return;
      }

      // Check password format
      if (!ValidationUtils.isValidPassword(passwordController.text)) {
        _showError(
            'Password must be at least 8 characters and contain uppercase, lowercase, number and special character');
        return;
      }

      // Step 2: Validate all signup fields
      if (!validateSignupFields()) {
        return; // validateSignupFields already shows error messages
      }

      // Step 3: Terms and Conditions Check
      if (!termsAccepted.value) {
        _showError('Please accept the terms and conditions to continue');
        return;
      }

      // Step 4: Start Registration Process
      showProgressBar.value = true;

      try {
        // Step 5: Create Firebase Auth Account
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Step 6: Upload Profile Picture (if selected)
        String photoUrl = '';
        if (pickedImage.value != null) {
          try {
            photoUrl = await _uploadProfilePicture(userCredential.user!.uid);
          } catch (e) {
            print('Error uploading profile picture: $e');
            // Continue with registration even if image upload fails
            _showError(
                'Failed to upload profile picture, but registration will continue');
          }
        }

        // Step 7: Create User Model
        pM.Person newUser = pM.Person(
          uid: userCredential.user!.uid,
          imageProfile: photoUrl,
          email: emailController.text.trim(),
          password: passwordController
              .text, // Note: Consider if you really need to store the password
          name: nameController.text.trim(),
          age: int.tryParse(ageController.text.trim()) ?? 0,
          phoneNo: phoneNoController.text.trim(),
          city: cityController.text.trim(),
          country: countryController.text.trim(),
          profileHeading: profileHeadingController.text.trim(),
          gender: genderController.text.trim(),
          height: heightController.text.trim(),
          weight: weightController.text.trim(),
          bodyType: bodyTypeController.text.trim(),
          drink: drinkController.text.trim(),
          smoke: smokeController.text.trim(),
          martialStatus: martialStatusController.text.trim(),
          haveChildren: haveChildrenController.text.trim(),
          noOfChildren: noOfChildrenController.text.trim(),
          profession: professionController.text.trim(),
          employmentStatus: employmentStatusController.text.trim(),
          income: incomeController.text.trim(),
          livingSituation: livingSituationController.text.trim(),
          willingToRelocate: willingToRelocateController.text.trim(),
          nationality: nationalityController.text.trim(),
          education: educationController.text.trim(),
          languageSpoken: languageSpokenController.text.trim(),
          religion: religionController.text.trim(),
          ethnicity: ethnicityController.text.trim(),
          linkedInUrl: linkedInController.text.trim(),
          instagramUrl: instagramController.text.trim(),
          githubUrl: githubController.text.trim(),
          publishedDateTime: DateTime.now().millisecondsSinceEpoch,
        );

        // Step 8: Save User Data to Firestore
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toJson());

        // Step 9: Clear Form and Show Success
        clearAllFields();
        _showSuccess('Account created successfully');

        // Step 10: Navigate to Home Screen
        Get.offAll(() => const HomeScreen());
      } on FirebaseAuthException catch (e) {
        // Step 11: Handle Firebase Auth Specific Errors
        String errorMessage = 'Registration failed';

        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'An account already exists for this email';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password accounts are not enabled';
            break;
          case 'weak-password':
            errorMessage = 'The password provided is too weak';
            break;
          default:
            errorMessage = e.message ?? 'An unknown error occurred';
        }

        _showError(errorMessage);
      }
    } catch (error) {
      // Step 12: Handle General Errors
      _showError('Registration failed: ${error.toString()}');
    } finally {
      // Step 13: Always Reset Loading State
      showProgressBar.value = false;
    }
  }

// Helper method to clear all form fields
  void clearAllFields() {
    // Form Controllers
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    ageController.clear();
    phoneNoController.clear();
    cityController.clear();
    countryController.clear();
    profileHeadingController.clear();
    genderController.clear();
    heightController.clear();
    weightController.clear();
    bodyTypeController.clear();
    drinkController.clear();
    smokeController.clear();
    martialStatusController.clear();
    haveChildrenController.clear();
    noOfChildrenController.clear();
    professionController.clear();
    employmentStatusController.clear();
    incomeController.clear();
    livingSituationController.clear();
    willingToRelocateController.clear();
    linkedInController.clear();
    instagramController.clear();
    githubController.clear();
    nationalityController.clear();
    educationController.clear();
    languageSpokenController.clear();
    religionController.clear();
    ethnicityController.clear();

    // Observable Variables
    childrenSelection.value = 'No';
    relationshipSelection.value = 'Single';
    radioHaveChildrenController.value = '';
    radioRelationshipStatusController.value = '';
    termsAccepted.value = false;
    pickedImage.value = null;

    // Reset Page
    currentPage.value = 0;
    pageController.jumpToPage(0);
  }

  // Validate Personal Info Page (Page 0)
  bool _validatePersonalInfo() {
    if (pickedImage.value == null) {
      _showError('Please select a profile picture');
      return false;
    }
    if (nameController.text.trim().isEmpty) {
      _showError('Name is required');
      return false;
    }
    if (!ValidationUtils.isValidEmail(emailController.text.trim())) {
      _showError('Please enter a valid email');
      return false;
    }
    if (!ValidationUtils.isValidPassword(passwordController.text)) {
      _showError(
          'Password must be at least 8 characters with uppercase, lowercase, number and special character');
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }
    if (!ValidationUtils.isValidAge(ageController.text.trim())) {
      _showError('Please enter a valid age between 18 and 100');
      return false;
    }
    if (genderController.text.trim().isEmpty) {
      _showError('Please select your gender');
      return false;
    }
    if (!ValidationUtils.isValidPhone(phoneNoController.text.trim())) {
      _showError('Please enter a valid phone number');
      return false;
    }
    if (countryController.text.trim().isEmpty) {
      _showError('Please select your country');
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      _showError('City is required');
      return false;
    }
    if (profileHeadingController.text.trim().isEmpty) {
      _showError('Profile heading is required');
      return false;
    }
    return true;
  }

  // Validate Appearance Page (Page 1)
  bool _validateAppearance() {
    if (!ValidationUtils.isValidHeight(heightController.text.trim())) {
      _showError('Please enter a valid height');
      return false;
    }
    if (!ValidationUtils.isValidWeight(weightController.text.trim())) {
      _showError('Please enter a valid weight');
      return false;
    }
    if (bodyTypeController.text.trim().isEmpty) {
      _showError('Please select your body type');
      return false;
    }
    return true;
  }

  // Validate Lifestyle Page (Page 2)
  bool _validateLifestyle() {
    if (drinkController.text.trim().isEmpty) {
      _showError('Please select your drinking habits');
      return false;
    }
    if (smokeController.text.trim().isEmpty) {
      _showError('Please select your smoking habits');
      return false;
    }
    if (martialStatusController.text.trim().isEmpty) {
      _showError('Please select your marital status');
      return false;
    }
    if (childrenSelection.value.isEmpty) {
      _showError('Please specify if you have children');
      return false;
    }
    if (childrenSelection.value == 'Yes' &&
        noOfChildrenController.text.trim().isEmpty) {
      _showError('Please specify number of children');
      return false;
    }
    if (professionController.text.trim().isEmpty) {
      _showError('Please select your profession');
      return false;
    }
    if (employmentStatusController.text.trim().isEmpty) {
      _showError('Please select your employment status');
      return false;
    }
    if (incomeController.text.trim().isEmpty) {
      _showError('Please enter your income');
      return false;
    }
    if (livingSituationController.text.trim().isEmpty) {
      _showError('Please select your living situation');
      return false;
    }
    if (relationshipSelection.value.isEmpty) {
      _showError('Please select your relationship status');
      return false;
    }
    return true;
  }

  // Validate Background Page (Page 3)
  bool _validateBackground() {
    if (nationalityController.text.trim().isEmpty) {
      _showError('Please select your nationality');
      return false;
    }
    if (educationController.text.trim().isEmpty) {
      _showError('Please select your education level');
      return false;
    }
    if (languageSpokenController.text.trim().isEmpty) {
      _showError('Please select languages spoken');
      return false;
    }
    if (religionController.text.trim().isEmpty) {
      _showError('Please select your religion');
      return false;
    }
    if (ethnicityController.text.trim().isEmpty) {
      _showError('Please select your ethnicity');
      return false;
    }
    return true;
  }

  // Validate Connections Page (Page 4)
  bool _validateConnections() {
    // LinkedIn, Instagram, and GitHub URLs are optional but must be valid if provided
    if (linkedInController.text.isNotEmpty &&
        !ValidationUtils.isValidUrl(linkedInController.text)) {
      _showError('Please enter a valid LinkedIn URL');
      return false;
    }
    if (instagramController.text.isNotEmpty &&
        !ValidationUtils.isValidUrl(instagramController.text)) {
      _showError('Please enter a valid Instagram URL');
      return false;
    }
    if (githubController.text.isNotEmpty &&
        !ValidationUtils.isValidUrl(githubController.text)) {
      _showError('Please enter a valid GitHub URL');
      return false;
    }
    if (!termsAccepted.value) {
      _showError('Please accept the terms and conditions');
      return false;
    }
    return true;
  }

  // Updated nextPage method with validation
  void nextPage() {
    bool canProceed = false;

    // Validate current page before proceeding
    switch (currentPage.value) {
      case 0:
        canProceed = _validatePersonalInfo();
        break;
      case 1:
        canProceed = _validateAppearance();
        break;
      case 2:
        canProceed = _validateLifestyle();
        break;
      case 3:
        canProceed = _validateBackground();
        break;
      case 4:
        canProceed = _validateConnections();
        break;
      default:
        canProceed = true;
    }

    // Only proceed if validation passes
    if (canProceed && currentPage.value < 4) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    }
  }

  Future<void> login() async {
    // Terms and conditions kontrolü
    if (!termsAccepted.value) {
      Get.snackbar(
        'Terms Required',
        'Please accept the terms and conditions to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
      return;
    }

    // Validation checks
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (!GetUtils.isEmail(emailController.text)) {
      _showError('Please enter a valid email address');
      return;
    }

    isLoading.value = true;

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Başarılı login sonrası
      await _handleSuccessfulLogin();
    } catch (error) {
      _handleLoginError(error);
    } finally {
      isLoading.value = false;
    }
  }

// Başarılı login işlemleri
  Future<void> _handleSuccessfulLogin() async {
    try {
      // Son giriş tarihini güncelle
      await _updateLastLoginTime();

      // Ana sayfaya yönlendir
      Get.offAll(
        () => const HomeScreen(),
        binding: HomeBindings(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } catch (error) {
      print('Post-login operation failed: $error');
      // Ana sayfaya yine de yönlendir
      Get.offAll(() => const HomeScreen(), binding: HomeBindings());
    }
  }

// Son giriş zamanını güncelle
  Future<void> _updateLastLoginTime() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'lastLoginAt': DateTime.now()});
      }
    } catch (error) {
      print('Failed to update last login time: $error');
    }
  }

// Login hatalarını handle et
  void _handleLoginError(dynamic error) {
    String message = 'An error occurred while signing in';

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          message = 'No account found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;
        case 'network-request-failed':
          message = 'Please check your internet connection';
          break;
        default:
          message = 'Authentication failed. Please try again';
      }
    }

    _showError(message);
  }

// Hata gösterme
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade900,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.red,
      ),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

// Başarılı login mesajı (isteğe bağlı)
  void _showSuccessMessage() {
    Get.snackbar(
      'Welcome',
      'Successfully signed in',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade900,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.green,
      ),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
    );
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAll(() => const LoginScreen());
    } catch (error) {
      _showError('Failed to log out: ${error.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSuccess('Password reset email sent');
    } catch (error) {
      _showError(error.toString());
    }
  }

  // Social sign-in methods
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _handleSignIn(() => _auth.signInWithCredential(credential));
    } on FirebaseAuthException catch (e) {
      await handleSignInError(e);
    } catch (e) {
      _showError('Failed to sign in with Google: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fpSend() async {
    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(
        email: emailController.text,
      );
      Get.offAll(() => const LoginScreen(), binding: AuthBindings());
    } catch (error) {
      Get.snackbar('Error', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await _handleSignIn(() => _auth.signInWithCredential(oauthCredential));
    } on SignInWithAppleAuthorizationException catch (e) {
      _showError('Apple sign in failed: ${e.message}');
    } on FirebaseAuthException catch (e) {
      await handleSignInError(e);
    } catch (e) {
      _showError('Failed to sign in with Apple: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Validation methods
  bool validateSignupFields() {
    // Critical field validations
    Map<String, ValidationRule> validationRules = {
      'Email': ValidationRule(
        value: emailController.text,
        validator: ValidationUtils.isValidEmail,
        errorMessage: 'Please enter a valid email address',
      ),
      'Password': ValidationRule(
        value: passwordController.text,
        validator: ValidationUtils.isValidPassword,
        errorMessage:
            'Password must be at least 8 characters with uppercase, lowercase, number and special character',
      ),
      'Name': ValidationRule(
        value: nameController.text,
        validator: (value) => value.length >= 2,
        errorMessage: 'Name must be at least 2 characters long',
      ),
      'Age': ValidationRule(
        value: ageController.text,
        validator: ValidationUtils.isValidAge,
        errorMessage: 'Age must be between 18 and 100',
      ),
      'Phone Number': ValidationRule(
        value: phoneNoController.text,
        validator: ValidationUtils.isValidPhone,
        errorMessage: 'Please enter a valid phone number',
      ),
      'Height': ValidationRule(
        value: heightController.text,
        validator: ValidationUtils.isValidHeight,
        errorMessage: 'Please enter a valid height',
      ),
      'Weight': ValidationRule(
        value: weightController.text,
        validator: ValidationUtils.isValidWeight,
        errorMessage: 'Please enter a valid weight',
      ),
    };

    // Required fields that only need presence check
    Map<String, TextEditingController> requiredFields = {
      'City': cityController,
      'Country': countryController,
      'Profile Heading': profileHeadingController,
      'Gender': genderController,
      'Body Type': bodyTypeController,
      'Drink': drinkController,
      'Smoke': smokeController,
      'Marital Status': martialStatusController,
      'Have Children': haveChildrenController,
      'Number of Children': noOfChildrenController,
      'Profession': professionController,
      'Employment Status': employmentStatusController,
      'Income': incomeController,
      'Living Situation': livingSituationController,
      'Willing to Relocate': willingToRelocateController,
      'Nationality': nationalityController,
      'Education': educationController,
      'Language Spoken': languageSpokenController,
      'Religion': religionController,
      'Ethnicity': ethnicityController,
    };

    // Validate critical fields
    for (var entry in validationRules.entries) {
      if (!entry.value.isValid()) {
        _showError(entry.value.errorMessage);
        return false;
      }
    }

    // Validate required fields
    for (var entry in requiredFields.entries) {
      if (entry.value.text.trim().isEmpty) {
        _showError('Please fill in the ${entry.key} field');
        return false;
      }
    }

    // Validate optional URL fields
    Map<String, TextEditingController> urlFields = {
      'LinkedIn': linkedInController,
      'Instagram': instagramController,
      'GitHub': githubController,
    };

    for (var entry in urlFields.entries) {
      if (entry.value.text.isNotEmpty &&
          !ValidationUtils.isValidUrl(entry.value.text)) {
        _showError('Please enter a valid ${entry.key} URL or leave it empty');
        return false;
      }
    }

    // Validate terms acceptance
    if (!termsAccepted.value) {
      _showError('Please accept the terms and conditions');
      return false;
    }

    return true;
  }

  Future<void> _handleSignIn(
      Future<UserCredential> Function() signInMethod) async {
    try {
      final userCredential = await signInMethod();
      final user = userCredential.user!;
      final isRegistered = await isUserRegistered(user.uid);
      if (isRegistered) {
        Get.offAllNamed('/home');
      } else {
        await _prefillUserData(user);
        Get.toNamed('/register');
      }
    } on FirebaseAuthException catch (e) {
      await handleSignInError(e);
    } catch (e) {
      _showError('Sign in failed: $e');
    }
  }

  Future<bool> isUserRegistered(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.exists;
    } catch (e) {
      _showError('Failed to check user registration: $e');
      return false;
    }
  }

  Future<void> handleSignInError(FirebaseAuthException e) async {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        List<String> providers =
            await _auth.fetchSignInMethodsForEmail(e.email!);
        String providerName = _getProviderName(providers.first);
        _showError(
            'An account already exists with the same email address but different sign-in credentials. '
            'Sign in using $providerName.');
        break;
      case 'invalid-credential':
        _showError('The credential is malformed or has expired.');
        break;
      case 'user-disabled':
        _showError('This user account has been disabled.');
        break;
      case 'user-not-found':
        _showError('No user found for that email.');
        break;
      case 'wrong-password':
        _showError('Wrong password provided for that user.');
        break;
      default:
        _showError('An undefined error occurred: ${e.message}');
    }
  }

  String _getProviderName(String providerId) {
    switch (providerId) {
      case 'google.com':
        return 'Google';
      case 'facebook.com':
        return 'Facebook';
      case 'apple.com':
        return 'Apple';
      case 'password':
        return 'Email/Password';
      default:
        return 'Unknown Provider';
    }
  }

  Future<String> _uploadProfilePicture(String uid) async {
    if (pickedImage.value == null) return '';

    try {
      Reference ref = _storage.ref().child('profile_pictures').child(uid);
      await ref.putFile(pickedImage.value!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile picture: $e');
      _showError('Failed to upload profile picture. Using default image.');
      return '';
    }
  }

  Future<void> _prefillUserData(User user) async {
    // Basic information
    emailController.text = user.email ?? '';
    nameController.text = user.displayName ?? '';
    phoneNoController.text = user.phoneNumber ?? '';

    // Profile picture
    if (user.photoURL != null) {
      try {
        final response = await http.get(Uri.parse(user.photoURL!));
        final bytes = response.bodyBytes;
        final temp = await File(
                '${(await getTemporaryDirectory()).path}/temp_profile.jpg')
            .create();
        await temp.writeAsBytes(bytes);
        pickedImage.value = temp;
      } catch (e) {
        print('Error downloading profile picture: $e');
      }
    }

    // Default values for other fields
    profileHeadingController.text = 'Hey there! I\'m new here.';
    termsAccepted.value = false;

    // Try to get additional data from Firestore if exists
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        cityController.text = data['city'] ?? '';
        countryController.text = data['country'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        genderController.text = data['gender'] ?? '';
        // Add other fields as needed
      }
    } catch (e) {
      print('Error fetching user data from Firestore: $e');
    }
  }

  @override
  void onClose() {
    // Dispose all controllers
    pageController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
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
    haveChildrenController.dispose();
    noOfChildrenController.dispose();
    professionController.dispose();
    employmentStatusController.dispose();
    incomeController.dispose();
    livingSituationController.dispose();
    willingToRelocateController.dispose();
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
