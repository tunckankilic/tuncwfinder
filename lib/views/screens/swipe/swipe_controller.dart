// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:url_launcher/url_launcher.dart';

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
      allUsersProfileList.removeAt(0);

      // Kullanıcıyı işlenmiş olarak işaretle
      if (removedProfile.uid != null) {
        _markUserAsProcessed(removedProfile.uid!, 'dislike');
      }
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
      const int pageSize = 50; // Daha fazla sonuç al
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

      // Engellenmiş, engelleyen ve işlenmiş kullanıcıları filtrele
      List<Person> filteredUsers = [];
      for (var doc in querySnapshot.docs) {
        String userId = doc.id;
        if (userId != currentUserId) {
          bool isBlocked = await isUserBlocked(userId);
          bool hasBlockedMe = await hasUserBlockedMe(userId);
          bool isProcessed = _processedUserIds.contains(userId);

          if (!isBlocked && !hasBlockedMe && !isProcessed) {
            filteredUsers.add(Person.fromDataSnapshot(doc));
          }
        }
      }

      allUsersProfileList.value = filteredUsers;

      if (allUsersProfileList.isEmpty) {
        Get.snackbar(
          'No Results',
          'No unblocked and unprocessed users found matching your criteria.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        log("Loaded ${filteredUsers.length} new profiles");
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch results. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      log("Error in getResults: $e");
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
        'Report Submitted',
        'Thank you for reporting. We will review this within 24 hours.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit report. Please try again.',
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
                'Report User',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(),
            _buildReportOption(
              'Inappropriate Content',
              'Content that violates our guidelines',
              Icons.warning,
              () => _submitReport(person.uid!, ReportReason.inappropriate),
            ),
            _buildReportOption(
              'Harassment',
              'Bullying or aggressive behavior',
              Icons.person_off,
              () => _submitReport(person.uid!, ReportReason.harassment),
            ),
            _buildReportOption(
              'Fake Profile',
              'Suspicious or misleading profile',
              Icons.face,
              () => _submitReport(person.uid!, ReportReason.fakeProfile),
            ),
            _buildReportOption(
              'Spam',
              'Unwanted commercial content',
              Icons.error,
              () => _submitReport(person.uid!, ReportReason.spamming),
            ),
            _buildReportOption(
              'Other',
              'Other concerns',
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
                'Provide Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: detailsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Please describe your concern...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
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
                    child: Text('Submit'),
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
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildDropdownListTile(
                  icon: Icons.person,
                  title: 'Gender',
                  value: chosenGender,
                  items: gender,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.location_city,
                  title: 'Country',
                  value: chosenCountry,
                  items: countries,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.cake,
                  title: 'Minimum Age',
                  value: chosenAge,
                  items: ageRangeList,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.person_outline,
                  title: "Body Type",
                  value: chosenBodyType,
                  items: bodyTypes,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.language,
                  title: "Language",
                  value: chosenLanguage,
                  items: languages,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.school,
                  title: "Education",
                  value: chosenEducation,
                  items: educationLevels,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.work,
                  title: "Employment",
                  value: chosenEmploymentStatus,
                  items: employmentStatuses,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.home,
                  title: "Living Situation",
                  value: chosenLivingSituation,
                  items: livingSituations,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.favorite,
                  title: "Marital Status",
                  value: chosenMaritalStatus,
                  items: maritalStatuses,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.local_drink,
                  title: "Drinking Habit",
                  value: chosenDrinkingHabit,
                  items: drinkingHabits,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.smoking_rooms,
                  title: "Smoking Habit",
                  value: chosenSmokingHabit,
                  items: smokingHabits,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.place,
                  title: "Nationality",
                  value: chosenNationality,
                  items: nationalities,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.people,
                  title: "Ethnicity",
                  value: chosenEthnicity,
                  items: ethnicities,
                  isTablet: isTablet),
              _buildDropdownListTile(
                  icon: Icons.church,
                  title: "Religion",
                  value: chosenReligion,
                  items: religion,
                  isTablet: isTablet),
              _buildDropdownListTile(
                icon: Icons.work,
                title: "Profession",
                value: chosenProfession,
                items: itJobs,
                isTablet: isTablet,
              ),
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

  Future<void> blockUser(String blockedUserId) async {
    // Null check
    if (blockedUserId.isEmpty || currentUserId.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid user information',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Rate limiting kontrolü
    if (_isBlockRateLimited(blockedUserId)) {
      Get.snackbar(
        'Warning',
        'Please wait before blocking another user',
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
        'Success',
        'User blocked successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Analytics logging (isteğe bağlı)
      await _logBlockAction(blockedUserId);
    } catch (e) {
      log("Error in blockUser: $e");
      Get.snackbar(
        'Error',
        'Failed to block user. Please try again.',
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
}
