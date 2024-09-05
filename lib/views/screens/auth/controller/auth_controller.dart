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

  // PageView controller
  late PageController pageController;
  RxInt currentPage = 0.obs;

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
  RxBool termsAccepted = false.obs;
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

  // var childrenOptions = {'Yes': false.obs, 'No': false.obs};
  // var relationshipOptions = {
  //   'Single': false.obs,
  //   'In a relationship': false.obs,
  //   'Married': false.obs,
  //   "It's complicated": false.obs
  // };

  // void updateChildrenOption(String key, bool value) {
  //   childrenOptions[key]?.value = value;
  // }

  // void updateRelationshipOption(String key, bool value) {
  //   relationshipOptions[key]?.value = value;
  // }

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
    if (!termsAccepted.value) {
      Get.snackbar('Error', 'Please accept the terms and conditions');
      return;
    }

    showProgressBar.value = true;
    try {
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

  // Future<void> signInWithFacebook() async {
  //   try {
  //     isLoading.value = true;
  //     final LoginResult result = await FacebookAuth.instance.login();
  //     if (result.status == LoginStatus.success) {
  //       final AccessToken accessToken = result.accessToken!;
  //       final OAuthCredential credential =
  //           FacebookAuthProvider.credential(accessToken.tokenString);
  //       await _handleSignIn(() => _auth.signInWithCredential(credential));
  //     } else {
  //       Get.snackbar('Error', 'Facebook login failed or was cancelled');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     await handleSignInError(e);
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to sign in with Facebook: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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
    user.providerData.forEach((userInfo) {
      if (userInfo.providerId == 'facebook.com') {
        // Facebook'tan ek bilgiler alınabilir
      } else if (userInfo.providerId == 'google.com') {
        // Google'dan ek bilgiler alınabilir
      } else if (userInfo.providerId == 'apple.com') {
        // Apple'dan ek bilgiler alınabilir
      }
    });

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

  // bool _validateSignupFields() {
  //   return emailController.text.isNotEmpty &&
  //       passwordController.text.isNotEmpty &&
  //       nameController.text.isNotEmpty &&
  //       ageController.text.isNotEmpty &&
  //       phoneNoController.text.isNotEmpty &&
  //       cityController.text.isNotEmpty &&
  //       countryController.text.isNotEmpty &&
  //       profileHeadingController.text.isNotEmpty &&
  //       lookingForInaPartnerController.text.isNotEmpty &&
  //       genderController.text.isNotEmpty &&
  //       heightController.text.isNotEmpty &&
  //       weightController.text.isNotEmpty &&
  //       bodyTypeController.text.isNotEmpty &&
  //       drinkController.text.isNotEmpty &&
  //       smokeController.text.isNotEmpty &&
  //       martialStatusController.text.isNotEmpty &&
  //       haveChildrenController.text.isNotEmpty &&
  //       noOfChildrenController.text.isNotEmpty &&
  //       professionController.text.isNotEmpty &&
  //       employmentStatusController.text.isNotEmpty &&
  //       incomeController.text.isNotEmpty &&
  //       livingSituationController.text.isNotEmpty &&
  //       willingToRelocateController.text.isNotEmpty &&
  //       relationshipYouAreLookingForController.text.isNotEmpty &&
  //       nationalityController.text.isNotEmpty &&
  //       educationController.text.isNotEmpty &&
  //       languageSpokenController.text.isNotEmpty &&
  //       religionController.text.isNotEmpty &&
  //       ethnicityController.text.isNotEmpty &&
  //       termsAccepted.value;
  // }

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
