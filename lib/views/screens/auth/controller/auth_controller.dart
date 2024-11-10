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

  // Form Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
    // Your EULA text here
  ''';

  final String privacyPolicy = '''
    // Your Privacy Policy text here
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

  // Error handling
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
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

  // Navigation
  void nextPage() {
    if (currentPage.value < 4) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    }
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

  // Authentication methods
  Future<void> register() async {
    if (!validateSignupFields()) {
      return;
    }

    showProgressBar.value = true;
    try {
      // Create user account
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Upload profile picture
      String photoUrl = await _uploadProfilePicture(userCredential.user!.uid);

      // Create user model
      pM.Person newUser = pM.Person(
        uid: userCredential.user!.uid,
        imageProfile: photoUrl,
        email: emailController.text.trim(),
        password: passwordController.text,
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

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toJson());

      _showSuccess('Account created successfully');
      Get.offAll(() => const HomeScreen());
    } catch (error) {
      _showError(error.toString());
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
      _showError(error.toString());
    } finally {
      isLoading.value = false;
    }
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
