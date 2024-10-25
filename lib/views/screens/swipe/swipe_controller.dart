// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwipeController extends GetxController {
  RxList<Person> allUsersProfileList = <Person>[].obs;
  RxString senderName = "".obs;
  Rx<PageController> pageController =
      PageController(initialPage: 0, viewportFraction: 1).obs;
  RxList<String> ageRangeList = <String>[].obs;
  RxString chosenGender = "".obs;
  RxString chosenCountry = "".obs;
  RxString chosenAge = "".obs;
  RxString chosenLanguage = "".obs;
  RxString chosenBodyType = "".obs;
  RxString chosenEducation = "".obs;
  RxString chosenEmploymentStatus = "".obs;
  RxString chosenLivingSituation = "".obs;
  RxString chosenMaritalStatus = "".obs;
  RxString chosenDrinkingHabit = "".obs;
  RxString chosenSmokingHabit = "".obs;
  RxString chosenNationality = "".obs;
  RxString chosenEthnicity = "".obs;
  RxString chosenReligion = "".obs;
  RxString chosenProfession = "".obs;
  Rx<DateTime> _lastQueryTime = DateTime.now().obs;
  RxInt _queryCount = 0.obs;
  String currentUserId = '';
  @override
  void onInit() {
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    super.onInit();
    readCurrentUserData();
    ageRange();
    getResults();
  }

  void readCurrentUserData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .get()
        .then((dataSnapshot) {
      senderName.value = dataSnapshot.data()!["name"].toString();
    });
  }

  void ageRange() {
    for (int i = 18; i < 65; i++) {
      ageRangeList.add(i.toString());
    }
  }

  bool _isValidAge(String input) {
    int? age = int.tryParse(input);
    return age != null && age >= 18 && age <= 120;
  }

  bool _isValidEmail(String input) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
  }

  // Input validation
  bool _isValidInput(String input) {
    // Implement proper input validation based on your requirements
    return input.isNotEmpty &&
        input.length <= 100 &&
        !input.contains(RegExp(r'[<>&\]'));
  }

  // Rate limiting
  bool _isRateLimited() {
    if (DateTime.now().difference(_lastQueryTime.value).inSeconds < 10) {
      _queryCount.value++;
      if (_queryCount.value > 5) {
        Get.snackbar(
          'Too Many Requests',
          'Please wait before trying again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
    } else {
      _queryCount.value = 0;
    }
    _lastQueryTime.value = DateTime.now();
    return false;
  }

  void applyFilter() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildDropdownListTile(
                icon: Icons.person,
                title: 'Gender',
                value: chosenGender,
                items: gender,
              ),
              _buildDropdownListTile(
                icon: Icons.location_city,
                title: 'Country',
                value: chosenCountry,
                items: countries,
              ),
              _buildDropdownListTile(
                icon: Icons.cake,
                title: 'Minimum Age',
                value: chosenAge,
                items: ageRangeList,
              ),
              _buildDropdownListTile(
                icon: Icons.person_outline,
                title: "Body Type",
                value: chosenBodyType,
                items: bodyTypes,
              ),
              _buildDropdownListTile(
                icon: Icons.language,
                title: "Language",
                value: chosenLanguage,
                items: languages,
              ),
              _buildDropdownListTile(
                icon: Icons.school,
                title: "Education",
                value: chosenEducation,
                items: highSchool,
              ),
              _buildDropdownListTile(
                icon: Icons.work,
                title: "Employment",
                value: chosenEmploymentStatus,
                items: employmentStatuses,
              ),
              _buildDropdownListTile(
                icon: Icons.home,
                title: "Living Situation",
                value: chosenLivingSituation,
                items: livingSituations,
              ),
              _buildDropdownListTile(
                icon: Icons.favorite,
                title: "Marital Status",
                value: chosenMaritalStatus,
                items: maritalStatuses,
              ),
              _buildDropdownListTile(
                icon: Icons.local_drink,
                title: "Drinking Habit",
                value: chosenDrinkingHabit,
                items: drinkingHabits,
              ),
              _buildDropdownListTile(
                icon: Icons.smoking_rooms,
                title: "Smoking Habit",
                value: chosenSmokingHabit,
                items: smokingHabits,
              ),
              _buildDropdownListTile(
                icon: Icons.place,
                title: "Nationality",
                value: chosenNationality,
                items: nationalities,
              ),
              _buildDropdownListTile(
                icon: Icons.people,
                title: "Ethnicity",
                value: chosenEthnicity,
                items: ethnicities,
              ),
              _buildDropdownListTile(
                icon: Icons.church,
                title: "Religion",
                value: chosenReligion,
                items: religion,
              ),
              _buildDropdownListTile(
                  icon: Icons.work,
                  title: "Profession",
                  value: chosenProfession,
                  items: itJobs),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  child: const Text('Apply Filter'),
                  onPressed: () {
                    Get.back();
                    getResults();
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> isUserBlocked(String userId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("blockedUsers")
        .doc(userId)
        .get();
    return doc.exists;
  }

  Future<bool> hasUserBlockedMe(String userId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("blockedUsers")
        .doc(currentUserId)
        .get();
    return doc.exists;
  }

  void removeTopProfile() {
    if (allUsersProfileList.isNotEmpty) {
      allUsersProfileList.removeAt(0);
    }
  }

  Future<void> blockUser(String blockedUserId) async {
    try {
      // Kullanıcıyı engelle
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("blockedUsers")
          .doc(blockedUserId)
          .set({
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Engellenen kullanıcıyı listeden kaldır
      allUsersProfileList
          .removeWhere((profile) => profile.uid == blockedUserId);

      Get.snackbar('Success', 'User blocked successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to block user: $e');
      print("Error in blockUser: $e");
    }
  }

  Widget _buildDropdownListTile({
    required IconData icon,
    required String title,
    required RxString value,
    required List<String> items,
  }) {
    return Obx(() => Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(icon),
              trailing: DropdownButton<String>(
                value: value.value.isEmpty ? null : value.value,
                hint: Text('Select $title'),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    value.value = newValue;
                  }
                },
                items: items.map<DropdownMenuItem<String>>((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
              ),
            ),
          ],
        ));
  }

  startChattingInWhatsApp(
      {required String receiverPhoneNumber,
      required BuildContext context}) async {
    var androidUrl =
        "whatsapp://send?phone=$receiverPhoneNumber&text=Hi, I found your profile on dating app.";
    var iosUrl =
        "https://wa.me/$receiverPhoneNumber?text=${Uri.parse('Hi, I found your profile on dating app.')}";

    try {
      if (Platform.isIOS) {
        await launchUrl((Uri.parse(iosUrl)));
      } else {
        await launchUrl((Uri.parse(androidUrl)));
      }
    } on Exception {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Whatsapp Not Found"),
              content: const Text("WhatsApp is not installed."),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          });
    }
  }

  void openLinkedInProfile(
      {required String linkedInUsername, required BuildContext context}) async {
    var url = linkedInUsername;

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("LinkedIn Error"),
              content: const Text("Could not open LinkedIn profile."),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          });
    }
  }

  void openInstagramProfile(
      {required String instagramUsername,
      required BuildContext context}) async {
    var webUrl = instagramUsername;

    try {
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(Uri.parse(webUrl),
            mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $webUrl';
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Instagram Error"),
              content: const Text("Could not open Instagram profile."),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          });
    }
  }

  void openGitHubProfile(
      {required String gitHubUsername, required BuildContext context}) async {
    var url = gitHubUsername;

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("GıtHub Error"),
              content: const Text("Could not open GitHub profile."),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("Ok"),
                ),
              ],
            );
          });
    }
  }

  Future<void> getResults() async {
    if (_isRateLimited()) return;

    try {
      Query query = FirebaseFirestore.instance.collection("users");

      // Apply equality filters with input validation
      if (_isValidInput(chosenGender.value)) {
        query = query.where("gender", isEqualTo: chosenGender.value);
      }
      if (_isValidInput(chosenCountry.value)) {
        query = query.where("country", isEqualTo: chosenCountry.value);
      }
      if (_isValidInput(chosenBodyType.value)) {
        query = query.where("bodyType", isEqualTo: chosenBodyType.value);
      }
      if (_isValidInput(chosenLanguage.value)) {
        query =
            query.where("languageSpoken", arrayContains: chosenLanguage.value);
      }
      if (_isValidInput(chosenEducation.value)) {
        query = query.where("education", isEqualTo: chosenEducation.value);
      }
      if (_isValidInput(chosenEmploymentStatus.value)) {
        query = query.where("employmentStatus",
            isEqualTo: chosenEmploymentStatus.value);
      }
      if (_isValidInput(chosenLivingSituation.value)) {
        query = query.where("livingSituation",
            isEqualTo: chosenLivingSituation.value);
      }
      if (_isValidInput(chosenMaritalStatus.value)) {
        query =
            query.where("maritalStatus", isEqualTo: chosenMaritalStatus.value);
      }
      if (_isValidInput(chosenDrinkingHabit.value)) {
        query = query.where("drink", isEqualTo: chosenDrinkingHabit.value);
      }
      if (_isValidInput(chosenSmokingHabit.value)) {
        query = query.where("smoke", isEqualTo: chosenSmokingHabit.value);
      }
      if (_isValidInput(chosenNationality.value)) {
        query = query.where("nationality", isEqualTo: chosenNationality.value);
      }
      if (_isValidInput(chosenEthnicity.value)) {
        query = query.where("ethnicity", isEqualTo: chosenEthnicity.value);
      }
      if (_isValidInput(chosenReligion.value)) {
        query = query.where("religion", isEqualTo: chosenReligion.value);
      }
      if (_isValidInput(chosenProfession.value)) {
        query = query.where("profession", isEqualTo: chosenProfession.value);
      }

      // Apply range filter last
      if (_isValidInput(chosenAge.value)) {
        int minAge = int.tryParse(chosenAge.value) ?? 0;
        query = query.where("age", isGreaterThanOrEqualTo: minAge);
      }

      // Limit query results and add pagination
      const int pageSize = 20;
      query = query.limit(pageSize);

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        Get.snackbar(
          'No Results',
          'No matches found for your search criteria.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Engellenmiş ve engelleyen kullanıcıları filtrele
      List<Person> filteredUsers = [];
      for (var doc in querySnapshot.docs) {
        String userId = doc.id;
        if (userId != currentUserId) {
          bool isBlocked = await isUserBlocked(userId);
          bool hasBlockedMe = await hasUserBlockedMe(userId);

          if (!isBlocked && !hasBlockedMe) {
            filteredUsers.add(Person.fromDataSnapshot(doc));
          }
        }
      }

      allUsersProfileList.value = filteredUsers;

      if (allUsersProfileList.isEmpty) {
        Get.snackbar(
          'No Results',
          'No unblocked users found matching your criteria.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      // Implement pagination
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot lastVisible = querySnapshot.docs.last;
        // Store lastVisible for next page query
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch results. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      print("Error in getResults: $e"); // For debugging
    }
  }

  void viewSentAndViewReceived(
      {required String toUserId, required String senderName}) async {
    // View sent
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("viewSent")
        .doc(toUserId)
        .set({});

    // View received
    await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserId)
        .collection("viewReceived")
        .doc(currentUserId)
        .set({
      "name": senderName,
    });
  }

  void favoriteSentAndFavoriteReceived(
      {required String toUserID, required String senderName}) async {
    // Favorite sent
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("favoriteSent")
        .doc(toUserID)
        .set({});

    // Favorite received
    await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection("favoriteReceived")
        .doc(currentUserId)
        .set({
      "name": senderName,
    });
  }

  void likeSentAndLikeReceived(
      {required String toUserId, required String senderName}) async {
    // Like sent
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .collection("likeSent")
        .doc(toUserId)
        .set({});

    // Like received
    await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserId)
        .collection("likeReceived")
        .doc(currentUserId)
        .set({
      "name": senderName,
    });
  }
}
