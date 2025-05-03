import 'dart:developer';
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
import 'package:tuncforwork/models/models.dart';
import 'package:tuncforwork/models/person.dart' as pM;
import 'package:tuncforwork/service/validation.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_bindings.dart';
import 'package:tuncforwork/views/screens/auth/controller/user_controller.dart';
import 'package:tuncforwork/views/screens/home/home_bindings.dart';
import 'package:tuncforwork/views/screens/home/home_controller.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:url_launcher/url_launcher.dart';

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
  RxBool obsPass = true.obs;

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
  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;

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
5. Children's Privacy
The application does not knowingly collect personal information from children under 13 years of age. If you are a parent or guardian and believe that your child has provided us with personal information, please contact us.
6. Changes to This Policy
This privacy policy may be updated from time to time. Changes will be posted on this page, and users will be notified in case of significant changes.
7. Contact
If you have any questions about this privacy policy, please contact us at:
email: ismail.tunc.kankilic@gmail.com
By accepting this privacy policy, you declare that you understand and agree to the terms stated herein.
  ''';

  final List<RxBool> checks = List.generate(5, (index) => false.obs);
  final List<String> textler = [
    "At least 8 character",
    "At least one capital letter (A-Z)",
    "At least 1 small letter (a-z)",
    "At least 1 digit (0-9)",
    "At least 1 special character (!,#...)",
  ];
  final RxBool isVisible = true.obs;

  // Kariyer ve Beceri Alanları için Yeni Controller'lar
  final TextEditingController careerGoalController = TextEditingController();
  final TextEditingController targetPositionController =
      TextEditingController();
  final TextEditingController skillController = TextEditingController();

  // Kariyer ve Beceri Alanları için Observable Değişkenler
  final RxList<String> selectedSkills = <String>[].obs;
  final RxList<WorkExperience> workExperiences = <WorkExperience>[].obs;
  final RxList<Project> projects = <Project>[].obs;
  final Rx<CareerGoal?> careerGoal = Rx<CareerGoal?>(null);

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();

    passwordController.addListener(() {
      if (confirmPasswordController.text.isNotEmpty) {
        if (passwordController.text != confirmPasswordController.text) {
          confirmPasswordError.value = 'Passwords do not match';
        } else {
          confirmPasswordError.value = '';
        }
      }
    });
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

  Future<void> register() async {
    try {
      showProgressBar.value = true;

      // Debug için sosyal medya değerlerini kontrol edelim
      log('LinkedIn URL: ${linkedInController.text}');
      log('Instagram URL: ${instagramController.text}');
      log('Github URL: ${githubController.text}');

      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw 'User creation failed';
      }

      String profileImageUrl = '';
      if (pickedImage.value != null) {
        profileImageUrl = await _uploadProfilePicture(user.uid);
      }

      // Sosyal medya URL'lerini temizleyelim
      final linkedInUrl = linkedInController.text.trim();
      final instagramUrl = instagramController.text.trim();
      final githubUrl = githubController.text.trim();

      final pM.Person userData = pM.Person(
        uid: user.uid,
        imageProfile: profileImageUrl,
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
        age: int.tryParse(ageController.text.trim()),
        phoneNo: phoneNoController.text.trim(),
        city: cityController.text.trim(),
        country: countryController.text.trim(),
        profileHeading: profileHeadingController.text.trim(),
        publishedDateTime: DateTime.now().millisecondsSinceEpoch,
        gender: genderController.text.trim(),
        height: heightController.text.trim(),
        weight: weightController.text.trim(),
        bodyType: bodyTypeController.text.trim(),
        drink: drinkController.text.trim(),
        smoke: smokeController.text.trim(),
        martialStatus: martialStatusController.text.trim(),
        haveChildren: childrenSelection.value,
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
        // Sosyal medya URL'lerini boş string yerine null olarak ayarlayalım
        linkedInUrl: linkedInUrl.isNotEmpty ? linkedInUrl : null,
        instagramUrl: instagramUrl.isNotEmpty ? instagramUrl : null,
        githubUrl: githubUrl.isNotEmpty ? githubUrl : null,
      );

      await _firestore.collection('users').doc(user.uid).set(userData.toJson());
      await user.updateDisplayName(nameController.text.trim());
      await user.updatePhotoURL(profileImageUrl);

      await _firestore.collection('user_settings').doc(user.uid).set({
        'emailNotifications': true,
        'pushNotifications': true,
        'profileVisibility': 'public',
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'accountStatus': 'active',
        'isVerified': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      await Future.wait([
        _firestore.collection('users/${user.uid}/followers').add({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        }),
        _firestore.collection('users/${user.uid}/following').add({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        }),
        _firestore.collection('users/${user.uid}/connections').add({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        }),
        _firestore.collection('users/${user.uid}/matches').add({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        })
      ]);

      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
      final writtenData =
          await _firestore.collection('users').doc(user.uid).get();
      log('Written data: ${writtenData.data()}');

      clearAllFields();

      Get.offAll(
        () => const HomeScreen(),
        binding: HomeBindings(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
    } catch (e) {
      _showError('Registration failed: ${e.toString()}');
      log('Registration error: $e');
    } finally {
      showProgressBar.value = false;
    }
  }

  void validatePassword(String value) {
    final strength = PasswordValidator.validatePassword(value);

    if (!strength.isValid) {
      passwordError.value = 'Provide all the password requirements';
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirmPassword(String value) {
    if (value != passwordController.text) {
      confirmPasswordError.value = 'Şifreler eşleşmiyor';
    } else {
      confirmPasswordError.value = '';
    }
  }

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

  Future<void> pickImage() async {
    try {
      isLoading.value = true;

      var status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
        if (status.isDenied) {
          _showError('Please allow access to your gallery to select a photo');
          return;
        }
      }

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
      log('Error picking image: $e');
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
      log('Error capturing image: $e');
      _showError('Failed to capture image. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    if (!termsAccepted.value) {
      Get.snackbar('Terms Required',
          'Please accept the terms and conditions to continue');
      return;
    }

    try {
      isLoading.value = true;

      // 1. Auth işlemi
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // 2. User document kontrolü
      final userDocRef =
          _firestore.collection('users').doc(userCredential.user!.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        throw 'User document not found';
      }

      // 3. UserController'ı initialize et
      final userController = Get.find<UserController>();
      await userController.initializeUserStream(userCredential.user!.uid);

      // 4. Verilerin yüklenmesini bekle
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return userController.currentUser.value == null;
      });

      // 5. HomeController'ı yükle ve initialize et
      final homeController = Get.put(HomeController(), permanent: true);
      await homeController.initializeControllers();

      // 6. Ana ekrana yönlendir - HomeBindings kullanma
      await Get.offAll(
        () => const HomeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
    } catch (e) {
      log('Login error: $e');
      _showError('Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<void> _prefillUserData(User user) async {
    emailController.text = user.email ?? '';
    nameController.text = user.displayName ?? '';
    phoneNoController.text = user.phoneNumber ?? '';

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
        log('Error downloading profile picture: $e');
      }
    }

    profileHeadingController.text = 'Hey there! I\'m new here.';
    termsAccepted.value = false;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        cityController.text = data['city'] ?? '';
        countryController.text = data['country'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        genderController.text = data['gender'] ?? '';
      }
    } catch (e) {
      log('Error fetching user data from Firestore: $e');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<String> _uploadProfilePicture(String uid) async {
    try {
      final ref = _storage.ref().child(
          'user_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(pickedImage.value!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log('Error in _uploadProfilePicture: $e');
      throw 'Failed to upload profile picture';
    }
  }

  void clearAllFields() {
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

    childrenSelection.value = 'No';
    relationshipSelection.value = 'Single';
    radioHaveChildrenController.value = '';
    radioRelationshipStatusController.value = '';
    termsAccepted.value = false;
    pickedImage.value = null;

    currentPage.value = 0;
    pageController.jumpToPage(0);
  }

  // validation.dart içinde

// Start Page validasyonu için
  static ValidationResult validateStartPage({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    // Name Validation
    if (name.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Name is required',
      );
    }

    if (name.trim().length < 2) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Name must be at least 2 characters long',
      );
    }

    // Email Validation
    if (!GetUtils.isEmail(email.trim())) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid email address',
      );
    }

    // Password Validation
    final passwordStrength = PasswordValidator.validatePassword(password);
    if (!passwordStrength.isValid) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password does not meet requirements',
      );
    }

    // Confirm Password Validation
    if (password != confirmPassword) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Passwords do not match',
      );
    }

    return ValidationResult(isValid: true);
  }

// AuthController içinde nextPage metodunu güncelle
  void nextPage() {
    ValidationResult? validationResult;

    switch (currentPage.value) {
      case 0: // Start Page
        validationResult = RegistrationValidator.validateStartPage(
          profileImage: pickedImage.value,
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
        );
        break;

      case 1: // Personal Info
        validationResult = RegistrationValidator.validatePersonalInfo(
          age: ageController.text,
          gender: genderController.text,
          phone: phoneNoController.text,
          country: countryController.text,
          city: cityController.text,
          profileHeading: profileHeadingController.text,
        );
        break;

      case 2: // Appearance
        validationResult = RegistrationValidator.validateAppearance(
          height: heightController.text,
          weight: weightController.text,
          bodyType: bodyTypeController.text,
        );
        break;

      case 3: // Lifestyle
        validationResult = RegistrationValidator.validateLifestyle(
          drink: drinkController.text,
          smoke: smokeController.text,
          maritalStatus: martialStatusController.text,
          haveChildren: childrenSelection.value,
          numberOfChildren: noOfChildrenController.text,
          profession: professionController.text,
          employmentStatus: employmentStatusController.text,
          income: incomeController.text,
          livingSituation: livingSituationController.text,
          relationshipStatus: relationshipSelection.value,
        );
        break;

      case 4: // Background
        validationResult = RegistrationValidator.validateBackground(
          nationality: nationalityController.text,
          education: educationController.text,
          language: languageSpokenController.text,
          religion: religionController.text,
          ethnicity: ethnicityController.text,
        );
        break;

      case 5: // Social Links and Terms
        validationResult = RegistrationValidator.validateSocialLinks(
          linkedIn: linkedInController.text,
          instagram: instagramController.text,
          github: githubController.text,
          termsAccepted: termsAccepted.value,
        );
        break;

      default:
        validationResult = ValidationResult(isValid: true);
    }

    if (validationResult.isValid) {
      if (currentPage.value < 5) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        currentPage.value++;
      } else {
        // Son sayfada ve validasyon başarılıysa kayıt işlemini başlat
        register();
      }
    } else {
      Get.snackbar(
        'Error',
        validationResult.errorMessage ?? 'Please check your inputs',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    }
  }

// AuthController içinde:
  Widget buildPasswordFields() {
    return Column(
      children: [
        PasswordInputField(
          controller: passwordController,
          label: 'Şifre',
          onChanged: (value) {
            validatePassword(value);
          },
        ),
        const SizedBox(height: 16),
        PasswordInputField(
          controller: confirmPasswordController,
          label: 'Şifre Tekrar',
          isConfirmField: true,
          onChanged: (value) {
            validateConfirmPassword(value);
          },
        ),
      ],
    );
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

  Future<void> _connectGithub(BuildContext context) async {
    try {
      final GithubAuthProvider githubProvider = GithubAuthProvider();
      final UserCredential result =
          await FirebaseAuth.instance.signInWithProvider(githubProvider);

      if (result.additionalUserInfo?.username != null) {
        githubController.text = result.additionalUserInfo!.username!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('GitHub profile connected successfully!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect GitHub: ${e.toString()}')));
    }
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

  void handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = 'This email is already registered';
        break;
      case 'invalid-email':
        message = 'Invalid email address';
        break;
      case 'operation-not-allowed':
        message = 'Email/password registration is disabled';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      default:
        message = e.message ?? 'An error occurred';
    }
    _showError(message);
  }

  // Beceri İşlemleri
  void addSkill(String skill) {
    if (!selectedSkills.contains(skill)) {
      selectedSkills.add(skill);
    }
  }

  void removeSkill(String skill) {
    selectedSkills.remove(skill);
  }

  // İş Deneyimi İşlemleri
  void addWorkExperience(WorkExperience experience) {
    workExperiences.add(experience);
  }

  void removeWorkExperience(int index) {
    if (index >= 0 && index < workExperiences.length) {
      workExperiences.removeAt(index);
    }
  }

  void showAddWorkExperienceDialog(bool isTablet) {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final descriptionController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final technologiesController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'İş Deneyimi Ekle',
                style: TextStyle(
                  fontSize: isTablet ? 20.0 : 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 20.0 : 16.0),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Pozisyon',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 16.0 : 12.0),
              TextField(
                controller: companyController,
                decoration: InputDecoration(
                  labelText: 'Şirket',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 16.0 : 12.0),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 16.0 : 12.0),
              TextField(
                controller: startDateController,
                decoration: InputDecoration(
                  labelText: 'Başlangıç Tarihi (YYYY-MM-DD)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 16.0 : 12.0),
              TextField(
                controller: endDateController,
                decoration: InputDecoration(
                  labelText: 'Bitiş Tarihi (YYYY-MM-DD)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 16.0 : 12.0),
              TextField(
                controller: technologiesController,
                decoration: InputDecoration(
                  labelText: 'Teknolojiler (virgülle ayırın)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 24.0 : 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('İptal'),
                  ),
                  SizedBox(width: isTablet ? 16.0 : 12.0),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          companyController.text.isNotEmpty &&
                          descriptionController.text.isNotEmpty &&
                          startDateController.text.isNotEmpty &&
                          technologiesController.text.isNotEmpty) {
                        try {
                          final startDate =
                              DateTime.parse(startDateController.text);
                          final endDate = endDateController.text.isNotEmpty
                              ? DateTime.parse(endDateController.text)
                              : null;
                          final technologies = technologiesController.text
                              .split(',')
                              .map((e) => e.trim())
                              .toList();

                          addWorkExperience(WorkExperience(
                            title: titleController.text,
                            company: companyController.text,
                            description: descriptionController.text,
                            startDate: startDate,
                            endDate: endDate,
                            technologies: technologies,
                          ));
                          Get.back();
                        } catch (e) {
                          Get.snackbar(
                            'Hata',
                            'Tarih formatı hatalı. Lütfen YYYY-MM-DD formatında girin.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                    },
                    child: Text('Ekle'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Proje İşlemleri
  void addProject(Project project) {
    projects.add(project);
  }

  void removeProject(int index) {
    if (index >= 0 && index < projects.length) {
      projects.removeAt(index);
    }
  }

  void showAddProjectDialog(bool isTablet) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final technologiesController = TextEditingController();
    final dateController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Proje Ekle',
                style: TextStyle(
                  fontSize: isTablet ? 20.0 : 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 20.0 : 16.0),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Proje Başlığı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 16.0 : 12.0),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 16.0 : 12.0),
              TextField(
                controller: technologiesController,
                decoration: InputDecoration(
                  labelText: 'Teknolojiler (virgülle ayırın)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 16.0 : 12.0),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Tarih (YYYY-MM-DD)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 24.0 : 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('İptal'),
                  ),
                  SizedBox(width: isTablet ? 16.0 : 12.0),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          descriptionController.text.isNotEmpty &&
                          technologiesController.text.isNotEmpty &&
                          dateController.text.isNotEmpty) {
                        try {
                          final date = DateTime.parse(dateController.text);
                          final technologies = technologiesController.text
                              .split(',')
                              .map((e) => e.trim())
                              .toList();

                          addProject(Project(
                            title: titleController.text,
                            description: descriptionController.text,
                            technologies: technologies,
                            date: date,
                          ));
                          Get.back();
                        } catch (e) {
                          Get.snackbar(
                            'Hata',
                            'Tarih formatı hatalı. Lütfen YYYY-MM-DD formatında girin.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                    },
                    child: Text('Ekle'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
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
    careerGoalController.dispose();
    targetPositionController.dispose();
    skillController.dispose();
    super.onClose();
  }
}
