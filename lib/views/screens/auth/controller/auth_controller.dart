import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tuncforwork/models/person.dart' as pM;
import 'package:tuncforwork/service/validation.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_bindings.dart';
import 'package:tuncforwork/views/screens/home/home_bindings.dart';
import 'package:tuncforwork/views/screens/screens.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxBool showProgressBar = false.obs;
  RxBool termsAccepted = false.obs;
  late PageController pageController;
  RxInt currentPage = 0.obs;

  // All existing TextEditingControllers...
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

  Rx<File?> pickedImage = Rx<File?>(null);
  final childrenSelection = RxString('No');
  final relationshipSelection = RxString('Single');

  final childrenOptions = ['Yes', 'No'];
  final relationshipOptions = [
    'Single',
    'In a relationship',
    'Married',
    "It's complicated"
  ];

  void updateChildrenOption(String value) {
    childrenSelection.value = value;
  }

  void updateRelationshipOption(String value) {
    relationshipSelection.value = value;
  }

  var radioHaveChildrenController = ''.obs;
  var radioRelationshipStatusController = ''.obs;

  void updateHaveChildren(String value) {
    radioHaveChildrenController.value = value;
  }

  void updateRelationshipStatus(String value) {
    radioRelationshipStatusController.value = value;
  }

  final String eula = '''
TuncForWork End User License Agreement (EULA)

1. Acceptance of Terms
By using the TuncForWork application ("Application"), you agree to comply with and be bound by this End User License Agreement ("EULA") and explicitly acknowledge our zero-tolerance policy for objectionable content and abusive behavior.

2. User Accounts and Content Moderation
- You must create an account to use certain features of the Application
- You are responsible for maintaining the confidentiality of your account information
- All user-generated content is subject to moderation
- Content moderation responses will be provided within 24 hours
- Users must report objectionable content using the provided reporting tools
- Users can block abusive users through the application interface
- Violations of these terms will result in immediate account termination

3. Prohibited Content and Behavior
Users are strictly prohibited from:
- Posting offensive, inappropriate, or objectionable content
- Engaging in harassment, hate speech, or discriminatory behavior
- Sharing explicit, violent, or disturbing material
- Impersonating others or creating misleading profiles
- Spamming or distributing malicious content
- Sharing personal information of others without consent

4. Content Moderation and Enforcement
- All user-generated content is subject to review
- Reported content will be reviewed within 24 hours
- Multiple violations will result in permanent account termination
- Users can appeal moderation decisions through support channels
- TuncForWork reserves the right to remove any content at its discretion

5. User Rights and Responsibilities
Users agree to:
- Report inappropriate content and behavior
- Respect other users' privacy and rights
- Maintain accurate profile information
- Follow community guidelines
- Block users they find offensive or inappropriate

6. Intellectual Property
All content in the Application, unless user-generated, is the property of TuncForWork and is protected by copyright and other intellectual property laws.

7. Safety and Privacy
- Personal information is protected under our Privacy Policy
- Users control their visibility settings
- Security concerns should be reported immediately
- Safe communication guidelines must be followed

8. Disclaimer of Warranties
THE APPLICATION IS PROVIDED "AS IS" WITHOUT ANY WARRANTIES, EXPRESS OR IMPLIED.

9. Limitation of Liability
TO THE FULLEST EXTENT PERMITTED BY LAW, TUNCFORWORK SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES.

10. Changes to Terms
We reserve the right to modify this EULA at any time. Your continued use of the Application after any changes indicates your acceptance of the modified EULA.

11. Content Filtering and Moderation Process
TuncForWork employs the following moderation mechanisms:
- Automated content filtering
- User reporting system
- 24-hour moderation response time
- User blocking capabilities
- Account suspension and termination procedures

By accepting this EULA, you acknowledge and agree that any violation of these terms, especially regarding objectionable content or abusive behavior, will result in immediate action, including possible permanent account termination.
''';

  final String privacyPolicy = '''
TuncForWork Privacy Policy

1. Information Collection
We collect personal information that you provide to us, including but not limited to your name, email address, and profile information.

2. Use of Information
We use the collected information to provide and improve our services, personalize your experience, and communicate with you.

3. Information Sharing
We do not sell or rent your personal information to third parties. We may share your information in certain circumstances, such as when required by law.

4. Data Security
We implement reasonable security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.

5. Your Rights
You have the right to access, correct, or delete your personal information. You may also have the right to object to or restrict certain processing of your information.

6. Changes to Privacy Policy
We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.

7. Contact Us
If you have any questions about this Privacy Policy, please contact us at: [Your Contact Email]
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

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

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
      if (!ValidationUtils.isValidUrl(entry.value.text)) {
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

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Password reset email sent');
    } catch (error) {
      Get.snackbar('Error', error.toString());
    }
  }

  void nextPage() {
    if (currentPage.value < 4) {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    }
  }

  void previousPage() {
    print('Previous page called. Current page before: ${currentPage.value}');
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value--;
      print('Previous page. Current page after: ${currentPage.value}');
    } else {
      print('Cannot go to previous page. Already at first page.');
    }
  }

  Future<void> register() async {
    if (!validateSignupFields()) {
      return;
    }

    showProgressBar.value = true;
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String photoUrl = await _uploadProfilePicture(userCredential.user!.uid);

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

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toJson());

      Get.snackbar('Success', 'Account created successfully');
      Get.offAll(() => const HomeScreen());
    } catch (error) {
      _showError(error.toString());
    } finally {
      showProgressBar.value = false;
    }
  }

  bool _validateAllFields() {
    // Zorunlu alanların kontrolü
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty) {
      return false;
    }

    // Email format kontrolü
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return false;
    }

    // Yaş kontrolü
    int? age = int.tryParse(ageController.text.trim());
    if (age == null || age < 18 || age > 100) {
      Get.snackbar('Error', 'Please enter a valid age between 18 and 100');
      return false;
    }

    return true;
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
      Get.snackbar('Error', 'Failed to sign in with Google: $e');
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
      Get.snackbar('Error', 'Apple sign in failed: ${e.message}');
    } on FirebaseAuthException catch (e) {
      await handleSignInError(e);
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in with Apple: $e');
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
      Get.snackbar('Error', 'Sign in failed: $e');
    }
  }

  Future<bool> isUserRegistered(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.exists;
    } catch (e) {
      Get.snackbar('Error', 'Failed to check user registration: $e');
      return false;
    }
  }

  void updateTermsAcceptance(bool accepted) {
    termsAccepted.value = accepted;
    update(); // GetX'e değişikliği bildir
  }

  Future<void> _prefillUserData(User user) async {
    // Temel bilgiler
    emailController.text = user.email ?? '';
    nameController.text = user.displayName ?? '';
    phoneNoController.text = user.phoneNumber ?? '';

    // Profil fotoğrafı
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

    // Diğer alanlar için varsayılan veya boş değerler
    ageController.text = ''; // Yaş bilgisi genellikle sosyal medyadan alınamaz
    cityController.text = '';
    countryController.text = '';
    profileHeadingController.text = 'Hey there! I\'m new here.';
    genderController.text = '';

    // Appearance
    heightController.text = '';
    weightController.text = '';
    bodyTypeController.text = '';

    // Life style
    drinkController.text = '';
    smokeController.text = '';
    martialStatusController.text = '';
    haveChildrenController.text = '';
    noOfChildrenController.text = '';
    professionController.text = '';
    employmentStatusController.text = '';
    incomeController.text = '';
    livingSituationController.text = '';
    willingToRelocateController.text = '';

    // Connections
    // Sosyal medya bağlantıları, giriş yapılan platforma göre doldurulabilir
    linkedInController.text = '';
    instagramController.text = '';
    githubController.text = '';

    // Background - Cultural Values
    nationalityController.text = '';
    educationController.text = '';
    languageSpokenController.text =
        ''; // Firebase User nesnesinden dil kodu alınabilir
    religionController.text = '';
    ethnicityController.text = '';

    // Ek bilgiler için Firebase Auth provider data'sını kullanabiliriz
    for (var userInfo in user.providerData) {
      if (userInfo.providerId == 'facebook.com') {
        // Facebook'tan ek bilgiler alınabilir
      } else if (userInfo.providerId == 'google.com') {
        // Google'dan ek bilgiler alınabilir
      } else if (userInfo.providerId == 'apple.com') {
        // Apple'dan ek bilgiler alınabilir
      }
    }

    // Kullanıcı verilerini Firestore'dan almayı deneyelim (eğer varsa)
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Firestore'dan gelen verileri kullanarak form alanlarını dolduralım
        cityController.text = data['city'] ?? '';
        countryController.text = data['country'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        genderController.text = data['gender'] ?? '';
        // Diğer alanları da benzer şekilde doldurabilirsiniz
      }
    } catch (e) {
      print('Error fetching user data from Firestore: $e');
    }

    // Kullanıcıdan açıkça onay almamız gereken alanlar için varsayılan değerleri ayarlama
    termsAccepted.value = false; // Kullanıcının açıkça kabul etmesi gerekiyor
  }

  bool _validateSignupFields() {
    Map<String, String> fields = {
      'Email': emailController.text,
      'Password': passwordController.text,
      'Name': nameController.text,
      'Age': ageController.text,
      'Phone Number': phoneNoController.text,
      'City': cityController.text,
      'Country': countryController.text,
      'Profile Heading': profileHeadingController.text,
      'Gender': genderController.text,
      'Height': heightController.text,
      'Weight': weightController.text,
      'Body Type': bodyTypeController.text,
      'Drink': drinkController.text,
      'Smoke': smokeController.text,
      'Marital Status': martialStatusController.text,
      'Have Children': haveChildrenController.text,
      'Number of Children': noOfChildrenController.text,
      'Profession': professionController.text,
      'Employment Status': employmentStatusController.text,
      'Income': incomeController.text,
      'Living Situation': livingSituationController.text,
      'Willing to Relocate': willingToRelocateController.text,
      'Nationality': nationalityController.text,
      'Education': educationController.text,
      'Language Spoken': languageSpokenController.text,
      'Religion': religionController.text,
      'Ethnicity': ethnicityController.text,
    };

    for (var entry in fields.entries) {
      if (entry.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Please fill in the ${entry.key} field',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return false;
      }
    }

    if (!termsAccepted.value) {
      Get.snackbar(
        'Error',
        'Please accept the terms and conditions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return false;
    }

    return true;
  }

  Future<void> sendEmailVerification() async {
    try {
      await firebaseUser.value?.sendEmailVerification();
      Get.snackbar('Success', 'Verification email sent');
    } catch (error) {
      Get.snackbar(
          'Error', 'Failed to send verification email: ${error.toString()}');
    }
  }

  Future<void> linkAccountWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await firebaseUser.value?.linkWithCredential(credential);
      Get.snackbar('Success', 'Google account linked successfully');
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'credential-already-in-use') {
        Get.snackbar(
            'Error', 'This Google account is already linked to another user');
      } else {
        Get.snackbar('Error', 'Failed to link Google account: $e');
      }
    }
  }

  Future<void> linkAccountWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final AuthCredential authCredential =
          OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await firebaseUser.value?.linkWithCredential(authCredential);
      Get.snackbar('Success', 'Apple account linked successfully');
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'credential-already-in-use') {
        Get.snackbar(
            'Error', 'This Apple account is already linked to another user');
      } else {
        Get.snackbar('Error', 'Failed to link Apple account: $e');
      }
    }
  }

  Future<void> handleSignInError(FirebaseAuthException e) async {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        // Fetch providers for the email
        List<String> providers =
            await _auth.fetchSignInMethodsForEmail(e.email!);
        String providerName = _getProviderName(providers.first);
        Get.snackbar(
          'Account Exists',
          'An account already exists with the same email address but different sign-in credentials. '
              'Sign in using $providerName.',
        );
        break;
      case 'invalid-credential':
        Get.snackbar('Error', 'The credential is malformed or has expired.');
        break;
      case 'user-disabled':
        Get.snackbar('Error', 'This user account has been disabled.');
        break;
      case 'user-not-found':
        Get.snackbar('Error', 'No user found for that email.');
        break;
      case 'wrong-password':
        Get.snackbar('Error', 'Wrong password provided for that user.');
        break;
      default:
        Get.snackbar('Error', 'An undefined error occurred: ${e.message}');
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

  @override
  void onClose() {
    pageController.dispose();
    // Dispose all controllers
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
