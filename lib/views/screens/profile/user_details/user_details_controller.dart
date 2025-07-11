import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/service/service.dart';
import 'package:tuncforwork/views/screens/auth/controller/auth_bindings.dart';
import 'package:tuncforwork/views/screens/auth/pages/screens.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/account_settings_controller.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/pages/account_info_settings.dart';
import 'package:tuncforwork/views/screens/profile/account_settings/pages/photo_settings_screen.dart';
import 'package:tuncforwork/views/screens/profile/profile_bindings.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/models/project.dart';
import 'package:tuncforwork/models/work_experience.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailsController extends GetxController {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Info
  final RxString name = ''.obs;
  final RxString imageUrl = ''.obs;
  final RxString email = ''.obs;
  final RxString phoneNo = ''.obs;
  final RxString city = ''.obs;
  final RxString country = ''.obs;
  final RxString profession = ''.obs;
  final RxString profileHeading = ''.obs;
  final RxString education = ''.obs;

  // Additional Info
  final RxString age = ''.obs;
  final RxString gender = ''.obs;
  final RxString height = ''.obs;
  final RxString weight = ''.obs;
  final RxString bodyType = ''.obs;
  final RxString drink = ''.obs;
  final RxString smoke = ''.obs;
  final RxString martialStatus = ''.obs;
  final RxString haveChildren = ''.obs;
  final RxString noOfChildren = ''.obs;
  final RxString employmentStatus = ''.obs;
  final RxString income = ''.obs;
  final RxString livingSituation = ''.obs;
  final RxString nationality = ''.obs;
  final RxString languageSpoken = ''.obs;
  final RxString religion = ''.obs;
  final RxString ethnicity = ''.obs;

  // Social Links
  final RxString instagramUrl = ''.obs;

  // Career Info
  final RxList<WorkExperience> workExperiences = <WorkExperience>[].obs;
  final RxList<String> skills = <String>[].obs;
  final RxList<Project> projects = <Project>[].obs;

  // State
  final RxBool isLoading = true.obs;
  final RxBool isCurrentUser = false.obs;
  final RxList<String> missingFields = <String>[].obs;

  UserDetailsController({required this.userId}) {
    _init();
  }

  Future<void> _init() async {
    try {
      isLoading.value = true;
      isCurrentUser.value = userId == _auth.currentUser?.uid;
      await retrieveUserInfo();
      if (isCurrentUser.value) {
        checkMissingInformation();
      }
    } catch (e) {
      print('Error initializing user details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void checkMissingInformation() {
    missingFields.clear();

    // Temel Bilgiler
    if (name.value.isEmpty) missingFields.add('İsim');
    if (age.value == '0') missingFields.add('Yaş');
    if (gender.value.isEmpty) missingFields.add('Cinsiyet');
    if (phoneNo.value.isEmpty) missingFields.add('Telefon');
    if (city.value.isEmpty) missingFields.add('Şehir');
    if (country.value.isEmpty) missingFields.add('Ülke');
    if (education.value.isEmpty) missingFields.add('Eğitim');

    // Ek Bilgiler
    if (height.value.isEmpty) missingFields.add('Boy');
    if (weight.value.isEmpty) missingFields.add('Kilo');
    if (bodyType.value.isEmpty) missingFields.add('Vücut Tipi');
    if (drink.value.isEmpty) missingFields.add('İçki Tercihi');
    if (smoke.value.isEmpty) missingFields.add('Sigara Tercihi');
    if (martialStatus.value.isEmpty) missingFields.add('Medeni Durum');
    if (haveChildren.value.isEmpty) missingFields.add('Çocuk Durumu');
    if (employmentStatus.value.isEmpty) missingFields.add('İş Durumu');
    if (income.value.isEmpty) missingFields.add('Gelir');
    if (livingSituation.value.isEmpty) missingFields.add('Yaşam Durumu');
    if (nationality.value.isEmpty) missingFields.add('Uyruk');
    if (languageSpoken.value.isEmpty) missingFields.add('Konuşulan Dil');
    if (religion.value.isEmpty) missingFields.add('Din');
    if (ethnicity.value.isEmpty) missingFields.add('Etnik Köken');

    // Kariyer Bilgileri
    if (profession.value.isEmpty) missingFields.add('Meslek');
    if (workExperiences.isEmpty) missingFields.add('İş Deneyimi');
    if (skills.isEmpty) missingFields.add('Yetenekler');

    // Sosyal Medya
    if (instagramUrl.value.isEmpty) missingFields.add('Instagram');
    if (phoneNo.value.isEmpty) missingFields.add('WhatsApp');

    if (missingFields.isNotEmpty) {
      Get.snackbar(
        'Eksik Bilgiler',
        'Profilinizde ${missingFields.length} eksik bilgi bulunuyor. Profilinizi düzenleyerek tamamlayabilirsiniz.',
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade900,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> retrieveUserInfo() async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return;

      final data = doc.data()!;

      // Basic Info
      name.value = data['name'] ?? '';
      imageUrl.value = data['imageProfile'] ?? '';
      email.value = data['email'] ?? '';
      phoneNo.value = data['phoneNo'] ?? '';
      city.value = data['city'] ?? '';
      country.value = data['country'] ?? '';
      profession.value = data['profession'] ?? '';
      profileHeading.value = data['profileHeading'] ?? '';
      education.value = data['education'] ?? '';

      // Additional Info
      age.value = (data['age'] ?? 0).toString();
      gender.value = data['gender'] ?? '';
      height.value = data['height'] ?? '';
      weight.value = data['weight'] ?? '';
      bodyType.value = data['bodyType'] ?? '';
      drink.value = data['drink'] ?? '';
      smoke.value = data['smoke'] ?? '';
      martialStatus.value = data['martialStatus'] ?? '';
      haveChildren.value = data['haveChildren'] ?? '';
      noOfChildren.value = data['noOfChildren'] ?? '';
      employmentStatus.value = data['employmentStatus'] ?? '';
      income.value = data['income'] ?? '';
      livingSituation.value = data['livingSituation'] ?? '';
      nationality.value = data['nationality'] ?? '';
      languageSpoken.value = data['languageSpoken'] ?? '';
      religion.value = data['religion'] ?? '';
      ethnicity.value = data['ethnicity'] ?? '';

      // Social Links
      instagramUrl.value = data['instagramUrl'] ?? '';

      // Career Info
      await _loadWorkExperience();
      await _loadSkills();
      await _loadProjects();
    } catch (e) {
      print('Error retrieving user info: $e');
    }
  }

  Future<void> _loadWorkExperience() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workExperience')
          .orderBy('startDate', descending: true)
          .get();

      workExperiences.value = snapshot.docs
          .map((doc) => WorkExperience.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading work experience: $e');
    }
  }

  Future<void> _loadSkills() async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .doc('skillsList')
          .get();

      if (doc.exists) {
        skills.value = List<String>.from(doc.data()?['skills'] ?? []);
      }
    } catch (e) {
      print('Error loading skills: $e');
    }
  }

  Future<void> _loadProjects() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('projects')
          .orderBy('date', descending: true)
          .get();

      projects.value =
          snapshot.docs.map((doc) => Project.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error loading projects: $e');
    }
  }

  Future<void> launchURL(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  void navigateToAccountSettings() {
    Get.to(
      () => ProfileInfoScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AccountSettingsController>()) {
          Get.put(AccountSettingsController());
        }
      }),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  void checkIfMainProfile() {
    isCurrentUser.value = userId == _auth.currentUser?.uid;
    log("Is main profile page: ${isCurrentUser.value}");
  }

  void updateName(String newName) {
    name.value = newName;
  }

  void updateImageUrls(List<String> newUrls) {
    imageUrl.value = newUrls.first;
  }

  void signOut() {
    _auth.signOut();
    Get.offAll(
      () => const LoginScreen(),
      binding: AuthBindings(),
    );
  }

  Future<void> deleteAccountAndData(BuildContext context) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String uid = user.uid;

        // 1. Delete user data from Firestore
        await _deleteUserData(uid);

        // 2. Delete user account
        await user.delete();

        // 3. Sign out the user
        await _auth.signOut();
        Get.offAllNamed(LoginScreen.routeName);
      } else {
        log('User is not signed in.');
        Get.snackbar('Error', 'User is not signed in.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        log('This operation requires recent authentication. Please log in again.');
        Get.snackbar('Error', 'Please log in again to delete your account.');
      } else {
        log('Account deletion error: ${e.message}');
        Get.snackbar('Error', 'Failed to delete account: ${e.message}');
      }
    } catch (e) {
      log('Unexpected error occurred: $e');
      Get.snackbar('Error', 'An unexpected error occurred.');
    }
  }

  Future<void> _deleteUserData(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();

      QuerySnapshot cardSnapshot = await _firestore
          .collection('users')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in cardSnapshot.docs) {
        await doc.reference.delete();
      }
      log('User data deleted successfully for user: $uid');
    } catch (e) {
      log('Error deleting user data: $e');
      rethrow; // Re-throw the error to be caught in the calling function
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (userId.isNotEmpty) {
      checkIfMainProfile();
    } else {
      log('User ID is missing');
      Get.snackbar('Error', 'User ID is missing');
      Get.back();
    }
  }
}
