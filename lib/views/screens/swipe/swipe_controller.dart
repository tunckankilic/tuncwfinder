// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:tuncforwork/views/screens/auth/controller/user_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/constants/app_strings.dart';

enum ReportReason { inappropriate, harassment, fakeProfile, spamming, others }

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
  final Map<String, DateTime> _lastBlockTimes = {};
  final RxBool _isProcessing = false.obs;
  final Rx<DateTime> _lastQueryTime = DateTime.now().obs;
  final RxInt _queryCount = 0.obs;
  String currentUserId = '';

  // Yeni: Kart tekrarını önlemek için
  final Set<String> _processedUserIds = <String>{};
  final Set<String> _swipedUserIds = <String>{};
  final RxBool _isBatchProcessing = false.obs;
  final RxInt _batchSize = 10.obs;

  // Public getters for UI access
  RxBool get isBatchProcessing => _isBatchProcessing;
  RxInt get batchSize => _batchSize;

  @override
  void onInit() {
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isNotEmpty) {
      super.onInit();
      readCurrentUserData();
      ageRange();
      getResults();
      _loadProcessedUsers();
    } else {
      log("No user is currently signed in");
    }
  }

  // Yeni: İşlenmiş kullanıcıları yükle
  Future<void> _loadProcessedUsers() async {
    try {
      final processedDocs = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("processedUsers")
          .get();

      for (var doc in processedDocs.docs) {
        _processedUserIds.add(doc.id);
      }

      log("Loaded ${_processedUserIds.length} processed users");
    } catch (e) {
      log("Error loading processed users: $e");
    }
  }

  // Yeni: Kullanıcıyı işlenmiş olarak işaretle
  Future<void> _markUserAsProcessed(String userId, String action) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("processedUsers")
          .doc(userId)
          .set({
        'action': action, // 'like', 'dislike', 'favorite', 'block'
        'timestamp': FieldValue.serverTimestamp(),
        'processedAt': DateTime.now().millisecondsSinceEpoch,
      });

      _processedUserIds.add(userId);
      _swipedUserIds.add(userId);
    } catch (e) {
      log("Error marking user as processed: $e");
    }
  }

  // Yeni: Batch swipe işlemleri
  Future<void> _processBatchSwipe(
      List<Map<String, dynamic>> swipeActions) async {
    if (_isBatchProcessing.value) return;

    _isBatchProcessing.value = true;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection("users");

      for (var action in swipeActions) {
        final String targetUserId = action['userId'];
        final String actionType =
            action['action']; // 'like', 'dislike', 'favorite'
        final String senderName = action['senderName'];

        // İşlenmiş kullanıcıları işaretle
        batch.set(
            userRef
                .doc(currentUserId)
                .collection("processedUsers")
                .doc(targetUserId),
            {
              'action': actionType,
              'timestamp': FieldValue.serverTimestamp(),
              'processedAt': DateTime.now().millisecondsSinceEpoch,
            });

        // Action'a göre batch işlemleri
        switch (actionType) {
          case 'like':
            // Like sent
            batch.set(
                userRef
                    .doc(currentUserId)
                    .collection("likeSent")
                    .doc(targetUserId),
                {'timestamp': FieldValue.serverTimestamp()});
            // Like received
            batch.set(
                userRef
                    .doc(targetUserId)
                    .collection("likeReceived")
                    .doc(currentUserId),
                {
                  'name': senderName,
                  'timestamp': FieldValue.serverTimestamp(),
                });
            break;

          case 'favorite':
            // Favorite sent
            batch.set(
                userRef
                    .doc(currentUserId)
                    .collection("favoriteSent")
                    .doc(targetUserId),
                {'timestamp': FieldValue.serverTimestamp()});
            // Favorite received
            batch.set(
                userRef
                    .doc(targetUserId)
                    .collection("favoriteReceived")
                    .doc(currentUserId),
                {
                  'name': senderName,
                  'timestamp': FieldValue.serverTimestamp(),
                });
            break;

          case 'dislike':
            // Dislike işlemi için sadece işlenmiş olarak işaretle
            break;
        }
      }

      // Batch commit
      await batch.commit();

      // UI güncelleme
      for (var action in swipeActions) {
        final String targetUserId = action['userId'];
        allUsersProfileList
            .removeWhere((profile) => profile.uid == targetUserId);
        _processedUserIds.add(targetUserId);
        _swipedUserIds.add(targetUserId);
      }

      log("Batch swipe processed: ${swipeActions.length} actions");
    } catch (e) {
      log("Error in batch swipe processing: $e");
      Get.snackbar(
        'Error',
        'Failed to process swipe actions. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isBatchProcessing.value = false;
    }
  }

  // Yeni: Gelişmiş kart yönetimi
  void removeTopProfile() {
    if (allUsersProfileList.isNotEmpty) {
      final removedProfile = allUsersProfileList[0];

      // Kullanıcıyı işlenmiş olarak işaretle
      if (removedProfile.uid != null) {
        _markUserAsProcessed(removedProfile.uid!, 'dislike');
      }

      // UI'dan kaldır
      allUsersProfileList.removeAt(0);
    }
  }

  // Yeni: Gelişmiş like işlemi
  void likeSentAndLikeReceived(
      {required String toUserId, required String senderName}) async {
    // Eğer kullanıcı zaten işlenmişse çık
    if (_processedUserIds.contains(toUserId)) {
      log("User $toUserId already processed");
      return;
    }

    // Batch işlem için hazırla
    final swipeAction = {
      'userId': toUserId,
      'action': 'like',
      'senderName': senderName,
    };

    await _processBatchSwipe([swipeAction]);
  }

  // Yeni: Gelişmiş favorite işlemi
  void favoriteSentAndFavoriteReceived(
      {required String toUserID, required String senderName}) async {
    // Eğer kullanıcı zaten işlenmişse çık
    if (_processedUserIds.contains(toUserID)) {
      log("User $toUserID already processed");
      return;
    }

    // Batch işlem için hazırla
    final swipeAction = {
      'userId': toUserID,
      'action': 'favorite',
      'senderName': senderName,
    };

    await _processBatchSwipe([swipeAction]);
  }

  // Yeni: Gelişmiş getResults - işlenmiş kullanıcıları filtrele
  Future<void> getResults() async {
    if (_isRateLimited()) return;

    try {
      // Debug için seçili filtreleri logla
      log("Selected filters:");
      log("Gender: ${chosenGender.value}");
      log("Country: ${chosenCountry.value}");
      log("Age: ${chosenAge.value}");
      log("BodyType: ${chosenBodyType.value}");
      log("Language: ${chosenLanguage.value}");
      log("Education: ${chosenEducation.value}");
      log("Employment: ${chosenEmploymentStatus.value}");
      log("Living: ${chosenLivingSituation.value}");
      log("Marital: ${chosenMaritalStatus.value}");
      log("Drink: ${chosenDrinkingHabit.value}");
      log("Smoke: ${chosenSmokingHabit.value}");
      log("Nationality: ${chosenNationality.value}");
      log("Ethnicity: ${chosenEthnicity.value}");
      log("Religion: ${chosenReligion.value}");
      log("Profession: ${chosenProfession.value}");

      // Önce tüm kullanıcıları al, sonra filtrele
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .limit(100) // Daha fazla sonuç al
          .get();

      log("Total documents fetched: ${querySnapshot.docs.length}");

      // Engellenmiş, engelleyen ve işlenmiş kullanıcıları filtrele
      List<Person> filteredUsers = [];
      for (var doc in querySnapshot.docs) {
        String userId = doc.id;
        if (userId != currentUserId) {
          bool isBlocked = await isUserBlocked(userId);
          bool hasBlockedMe = await hasUserBlockedMe(userId);
          bool isProcessed = _processedUserIds.contains(userId);

          if (!isBlocked && !hasBlockedMe && !isProcessed) {
            try {
              Person person = Person.fromDataSnapshot(doc);

              // Filtreleri uygula
              bool matchesFilters = true;

              if (_isValidInput(chosenGender.value)) {
                matchesFilters = matchesFilters &&
                    person.gender?.toLowerCase() ==
                        chosenGender.value.toLowerCase();
              }

              if (_isValidInput(chosenCountry.value)) {
                matchesFilters = matchesFilters &&
                    person.country?.toLowerCase() ==
                        chosenCountry.value.toLowerCase();
              }

              if (_isValidInput(chosenBodyType.value)) {
                matchesFilters = matchesFilters &&
                    person.bodyType?.toLowerCase() ==
                        chosenBodyType.value.toLowerCase();
              }

              if (_isValidInput(chosenLanguage.value)) {
                matchesFilters = matchesFilters &&
                    person.languageSpoken?.contains(chosenLanguage.value) ==
                        true;
              }

              if (_isValidInput(chosenEducation.value)) {
                matchesFilters = matchesFilters &&
                    person.education?.toLowerCase() ==
                        chosenEducation.value.toLowerCase();
              }

              if (_isValidInput(chosenEmploymentStatus.value)) {
                matchesFilters = matchesFilters &&
                    person.employmentStatus?.toLowerCase() ==
                        chosenEmploymentStatus.value.toLowerCase();
              }

              if (_isValidInput(chosenLivingSituation.value)) {
                matchesFilters = matchesFilters &&
                    person.livingSituation?.toLowerCase() ==
                        chosenLivingSituation.value.toLowerCase();
              }

              if (_isValidInput(chosenMaritalStatus.value)) {
                matchesFilters = matchesFilters &&
                    person.martialStatus?.toLowerCase() ==
                        chosenMaritalStatus.value.toLowerCase();
              }

              if (_isValidInput(chosenDrinkingHabit.value)) {
                matchesFilters = matchesFilters &&
                    person.drink?.toLowerCase() ==
                        chosenDrinkingHabit.value.toLowerCase();
              }

              if (_isValidInput(chosenSmokingHabit.value)) {
                matchesFilters = matchesFilters &&
                    person.smoke?.toLowerCase() ==
                        chosenSmokingHabit.value.toLowerCase();
              }

              if (_isValidInput(chosenNationality.value)) {
                matchesFilters = matchesFilters &&
                    person.nationality?.toLowerCase() ==
                        chosenNationality.value.toLowerCase();
              }

              if (_isValidInput(chosenEthnicity.value)) {
                matchesFilters = matchesFilters &&
                    person.ethnicity?.toLowerCase() ==
                        chosenEthnicity.value.toLowerCase();
              }

              if (_isValidInput(chosenReligion.value)) {
                matchesFilters = matchesFilters &&
                    person.religion?.toLowerCase() ==
                        chosenReligion.value.toLowerCase();
              }

              if (_isValidInput(chosenProfession.value)) {
                matchesFilters = matchesFilters &&
                    person.profession?.toLowerCase() ==
                        chosenProfession.value.toLowerCase();
              }

              if (_isValidInput(chosenAge.value)) {
                int minAge = int.tryParse(chosenAge.value) ?? 0;
                int userAge = int.tryParse(person.age?.toString() ?? "0") ?? 0;
                matchesFilters = matchesFilters && userAge >= minAge;
              }

              if (matchesFilters) {
                filteredUsers.add(person);
              }
            } catch (e) {
              print('Error parsing user document ${doc.id}: $e');
            }
          }
        }
      }

      allUsersProfileList.value = filteredUsers;

      if (allUsersProfileList.isEmpty) {
        Get.snackbar(
          AppStrings.noResultsFound,
          AppStrings.noMatchingUsers,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        log("Loaded ${filteredUsers.length} filtered profiles");
        Get.snackbar(
          AppStrings.success,
          '${filteredUsers.length} ${AppStrings.profilesFound}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.errorOccurredWhileFetchingResults,
        snackPosition: SnackPosition.BOTTOM,
      );
      log("Error in getResults: $e");
      log("Error stack trace: ${StackTrace.current}");
    }
  }

  // Yeni: İşlenmiş kullanıcıları temizle (opsiyonel)
  Future<void> clearProcessedUsers() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final processedRef = FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("processedUsers");

      final processedDocs = await processedRef.get();

      for (var doc in processedDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _processedUserIds.clear();
      _swipedUserIds.clear();

      log("Cleared all processed users");
    } catch (e) {
      log("Error clearing processed users: $e");
    }
  }

  // Yeni: İstatistikler
  Map<String, dynamic> getSwipeStatistics() {
    return {
      'totalProcessed': _processedUserIds.length,
      'totalSwiped': _swipedUserIds.length,
      'remainingProfiles': allUsersProfileList.length,
      'isBatchProcessing': _isBatchProcessing.value,
    };
  }

  void readCurrentUserData() async {
    try {
      final dataSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .get();

      if (dataSnapshot.exists && dataSnapshot.data() != null) {
        final data = dataSnapshot.data()!;
        if (data.containsKey("name") && data["name"] != null) {
          senderName.value = data["name"].toString();
        }
      }
    } catch (e) {
      print("Error reading current user data: $e");
    }
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
          AppStrings.tooManyRequests,
          AppStrings.pleaseWaitBeforeTryingAgain,
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

// Rapor fonksiyonları
  Future<void> reportUser(String reportedUserId, ReportReason reason,
      [String? details]) async {
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reportedUserId': reportedUserId,
        'reporterId': currentUserId,
        'reason': reason.toString(),
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'reviewedAt': null,
      });

      // Kullanıcıyı otomatik olarak engelle
      await blockUser(reportedUserId);

      Get.snackbar(
        AppStrings.reportSubmitted,
        AppStrings.thankYouForReporting,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.failedToSubmitReport,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

// Rapor dialogunu gösteren fonksiyon
  void showReportDialog(Person person) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.reportUser,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(),
            _buildReportOption(
              AppStrings.inappropriateContent,
              AppStrings.contentViolatingGuidelines,
              Icons.warning,
              () => _submitReport(person.uid!, ReportReason.inappropriate),
            ),
            _buildReportOption(
              AppStrings.harassment,
              AppStrings.bullyingOrAggressiveBehavior,
              Icons.person_off,
              () => _submitReport(person.uid!, ReportReason.harassment),
            ),
            _buildReportOption(
              AppStrings.fakeProfile,
              AppStrings.suspiciousOrMisleadingProfile,
              Icons.face,
              () => _submitReport(person.uid!, ReportReason.fakeProfile),
            ),
            _buildReportOption(
              AppStrings.spam,
              AppStrings.unwantedCommercialContent,
              Icons.error,
              () => _submitReport(person.uid!, ReportReason.spamming),
            ),
            _buildReportOption(
              AppStrings.other,
              AppStrings.otherConcerns,
              Icons.more_horiz,
              () => _showDetailedReportDialog(person.uid!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }

  void _submitReport(String userId, ReportReason reason) {
    reportUser(userId, reason);
  }

  void _showDetailedReportDialog(String userId) {
    final TextEditingController detailsController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.provideDetails,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: detailsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: AppStrings.pleaseDescribeYourConcern,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(AppStrings.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      reportUser(
                        userId,
                        ReportReason.others,
                        detailsController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(AppStrings.submitButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void applyFilter(bool isTablet) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.filters,
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Reset all filters
                      chosenGender.value = '';
                      chosenCountry.value = '';
                      chosenAge.value = '';
                      chosenBodyType.value = '';
                      chosenLanguage.value = '';
                      chosenEducation.value = '';
                      chosenEmploymentStatus.value = '';
                      chosenLivingSituation.value = '';
                      chosenMaritalStatus.value = '';
                      chosenDrinkingHabit.value = '';
                      chosenSmokingHabit.value = '';
                      chosenNationality.value = '';
                      chosenEthnicity.value = '';
                      chosenReligion.value = '';
                      chosenProfession.value = '';
                    },
                    child: Text(
                      AppStrings.resetFilters,
                      style: TextStyle(
                        color: Colors.red[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filter content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildModernFilterSection(
                      title: AppStrings.basicInformation,
                      filters: [
                        _buildModernFilterTile(
                          icon: Icons.person,
                          title: AppStrings.gender,
                          value: chosenGender,
                          items: gender,
                          isTablet: isTablet,
                        ),
                        _buildModernFilterTile(
                          icon: Icons.cake,
                          title: AppStrings.minimumAge,
                          value: chosenAge,
                          items: ageRangeList,
                          isTablet: isTablet,
                        ),
                        _buildModernFilterTile(
                          icon: Icons.person_outline,
                          title: AppStrings.bodyType,
                          value: chosenBodyType,
                          items: bodyTypes,
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                    _buildModernFilterSection(
                      title: AppStrings.locationAndDemography,
                      filters: [
                        _buildModernFilterTile(
                          icon: Icons.location_city,
                          title: AppStrings.country,
                          value: chosenCountry,
                          items: countries,
                          isTablet: isTablet,
                        ),
                        _buildModernFilterTile(
                          icon: Icons.place,
                          title: AppStrings.nationality,
                          value: chosenNationality,
                          items: nationalities,
                          isTablet: isTablet,
                        ),
                        _buildModernFilterTile(
                          icon: Icons.people,
                          title: AppStrings.ethnicOrigin,
                          value: chosenEthnicity,
                          items: ethnicities,
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                    _buildModernFilterSection(
                      title: AppStrings.educationAndCareer,
                      filters: [
                        _buildModernFilterTile(
                          icon: Icons.school,
                          title: AppStrings.education,
                          value: chosenEducation,
                          items: educationLevels,
                          isTablet: isTablet,
                        ),
                        _buildModernFilterTile(
                          icon: Icons.work,
                          title: AppStrings.employmentStatus,
                          value: chosenEmploymentStatus,
                          items: employmentStatuses,
                          isTablet: isTablet,
                        ),
                        _buildModernFilterTile(
                          icon: Icons.work,
                          title: AppStrings.profession,
                          value: chosenProfession,
                          items: itJobs,
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                    _buildModernFilterSection(
                      title: AppStrings.lifestyle,
                      filters: [
                        _buildModernFilterTile(
                          icon: Icons.home,
                          title: AppStrings.livingSituation,
                          value: chosenLivingSituation,
                          items: livingSituations,
                          isTablet: isTablet,
                        ),
                        _buildModernFilterTile(
                          icon: Icons.favorite,
                          title: AppStrings.maritalStatus,
                          value: chosenMaritalStatus,
                          items: maritalStatuses,
                          isTablet: isTablet,
                        ),
                        _buildModernFilterTile(
                          icon: Icons.local_drink,
                          title: AppStrings.drinkingHabit,
                          value: chosenDrinkingHabit,
                          items: drinkingHabits,
                          isTablet: isTablet,
                        ),
                        _buildModernFilterTile(
                          icon: Icons.smoking_rooms,
                          title: AppStrings.smokingHabit,
                          value: chosenSmokingHabit,
                          items: smokingHabits,
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                    _buildModernFilterSection(
                      title: AppStrings.other,
                      filters: [
                        _buildModernFilterTile(
                          icon: Icons.language,
                          title: AppStrings.language,
                          value: chosenLanguage,
                          items: languages,
                          isTablet: isTablet,
                        ),
                        _buildModernFilterTile(
                          icon: Icons.church,
                          title: AppStrings.religion,
                          value: chosenReligion,
                          items: religion,
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            // Apply button
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Get.back();
                    getResults();
                  },
                  child: Text(
                    AppStrings.applyFilters,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
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

  Future<void> blockUser(String blockedUserId) async {
    // Null check
    if (blockedUserId.isEmpty || currentUserId.isEmpty) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.invalidUserInformation,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Rate limiting kontrolü
    if (_isBlockRateLimited(blockedUserId)) {
      Get.snackbar(
        AppStrings.warning,
        AppStrings.pleaseWaitBeforeBlockingAnotherUser,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // İşlem zaten devam ediyorsa çık
    if (_isProcessing.value) return;
    _isProcessing.value = true;

    try {
      // Batch operation başlat
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection("users");

      // Block işlemi için referanslar
      final blockRef = userRef
          .doc(currentUserId)
          .collection("blockedUsers")
          .doc(blockedUserId);

      // Clean up için referanslar
      final likeSentRef =
          userRef.doc(currentUserId).collection("likeSent").doc(blockedUserId);
      final likeReceivedRef = userRef
          .doc(blockedUserId)
          .collection("likeReceived")
          .doc(currentUserId);
      final favoriteSentRef = userRef
          .doc(currentUserId)
          .collection("favoriteSent")
          .doc(blockedUserId);
      final favoriteReceivedRef = userRef
          .doc(blockedUserId)
          .collection("favoriteReceived")
          .doc(currentUserId);

      // Batch operations
      batch.set(blockRef, {
        'timestamp': FieldValue.serverTimestamp(),
        'reason': 'user_blocked',
      });

      // Clean up önceki etkileşimleri
      batch.delete(likeSentRef);
      batch.delete(likeReceivedRef);
      batch.delete(favoriteSentRef);
      batch.delete(favoriteReceivedRef);

      // Batch commit
      await batch.commit();

      // UI güncelleme
      allUsersProfileList
          .removeWhere((profile) => profile.uid == blockedUserId);

      // Rate limiting güncelleme
      _lastBlockTimes[blockedUserId] = DateTime.now();

      Get.snackbar(
        AppStrings.success,
        AppStrings.userBlockedSuccessfully,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Analytics logging (isteğe bağlı)
      await _logBlockAction(blockedUserId);
    } catch (e) {
      log("Error in blockUser: $e");
      Get.snackbar(
        AppStrings.error,
        AppStrings.failedToBlockUser,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  bool _isBlockRateLimited(String userId) {
    final lastBlockTime = _lastBlockTimes[userId];
    if (lastBlockTime == null) return false;

    // 1 saat içinde aynı kullanıcıyı tekrar engellemesini önle
    return DateTime.now().difference(lastBlockTime).inHours < 1;
  }

  Future<void> _logBlockAction(String blockedUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection("analytics")
          .doc("blocks")
          .collection(currentUserId)
          .add({
        'blocked_user_id': blockedUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': Platform.isIOS ? 'iOS' : 'Android',
      });
    } catch (e) {
      // Analytics hatası kritik değil, sessizce devam et
      log("Analytics error: $e");
    }
  }

  Widget _buildDropdownListTile({
    required IconData icon,
    required String title,
    required RxString value,
    required List<String> items,
    required bool isTablet,
  }) {
    return Obx(() => Column(
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: isTablet ? 22 : 14, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(icon),
              trailing: SizedBox(
                width: 150, // Dropdown genişliğini sınırla
                child: DropdownButton<String>(
                  value: value.value.isEmpty ? null : value.value,
                  hint: Text('Select $title'),
                  isExpanded:
                      true, // Dropdown'ın mevcut alanı kaplamasını sağla
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      value.value = newValue;
                    }
                  },
                  items: items.map<DropdownMenuItem<String>>((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        overflow:
                            TextOverflow.ellipsis, // Uzun metinleri kısalt
                      ),
                    );
                  }).toList(),
                ),
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
              title: const Text(AppStrings.whatsappNotFound),
              content: const Text(AppStrings.whatsAppNotInstalled),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(AppStrings.ok),
                ),
              ],
            );
          });
    }
  }

  void openLinkedInProfile(
      {required String linkedInUsername, required BuildContext context}) async {
    var url = "https://www.linkedin.com/in/$linkedInUsername";

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
              title: const Text(AppStrings.linkedInError),
              content: const Text(AppStrings.couldNotOpenLinkedInProfile),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(AppStrings.ok),
                ),
              ],
            );
          });
    }
  }

  void openInstagramProfile(
      {required String instagramUsername,
      required BuildContext context}) async {
    var webUrl = "https://www.instagram.com/$instagramUsername";

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
              title: const Text(AppStrings.instagramError),
              content: const Text(AppStrings.couldNotOpenInstagramProfile),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(AppStrings.ok),
                ),
              ],
            );
          });
    }
  }

  Widget _buildModernFilterSection({
    required String title,
    required List<Widget> filters,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: filters,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterTile({
    required IconData icon,
    required String title,
    required RxString value,
    required List<String> items,
    required bool isTablet,
  }) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.blue[600],
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            subtitle: value.value.isNotEmpty
                ? Text(
                    value.value,
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
            trailing: Container(
              width: 120,
              child: DropdownButton<String>(
                value: value.value.isEmpty ? null : value.value,
                hint: Text(
                  AppStrings.select,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                isExpanded: true,
                underline: SizedBox(),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    value.value = newValue;
                  }
                },
                items: items.map<DropdownMenuItem<String>>((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ));
  }

  void navigateToProfile(String userId) {
    // Initialize UserDetailsController with the specific userId
    Get.lazyPut<UserDetailsController>(
        () => UserDetailsController(userId: userId),
        tag: userId,
        fenix: true);

    // Navigate to UserDetails page
    Get.to(() => UserDetails(userId: userId));
  }
}
