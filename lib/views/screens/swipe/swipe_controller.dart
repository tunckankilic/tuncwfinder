// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/global.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details.dart';
import 'package:tuncforwork/views/screens/profile/user_details/user_details_controller.dart';
import 'package:tuncforwork/constants/app_strings.dart';
import 'package:tuncforwork/views/screens/swipe/mixins/swipe_filter_mixin.dart';
import 'package:tuncforwork/views/screens/swipe/mixins/swipe_action_mixin.dart';
import 'package:tuncforwork/views/screens/swipe/mixins/swipe_data_mixin.dart';
import 'package:tuncforwork/views/screens/swipe/mixins/swipe_data_lists_mixin.dart';
import 'package:tuncforwork/service/user_blocking_service.dart';

enum ReportReason { inappropriate, harassment, fakeProfile, spamming, others }

class SwipeController extends GetxController
    with
        SwipeFilterMixin,
        SwipeActionMixin,
        SwipeDataMixin,
        SwipeDataListsMixin {
  Rx<PageController> pageController =
      PageController(initialPage: 0, viewportFraction: 1).obs;

  late String _currentUserId;

  @override
  String get currentUserId => _currentUserId;

  @override
  String get senderNameValue => senderName.value;

  @override
  void onInit() {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (_currentUserId.isNotEmpty) {
      super.onInit();
      _initialize();
    } else {
      log("No user is currently signed in");
    }
  }

  /// Initialization sequence
  Future<void> _initialize() async {
    await readCurrentUserData();
    ageRange();
    await loadProcessedUsers();
    await getResults();
  }

  /// Main getResults method - uses mixins for heavy lifting
  /// Optimized: Batch blocked user queries to fix N+1 problem
  /// Cost: 2 queries (blocked users) + 1 query (fetch users) = 3 total
  /// Previous: 1 + (20 * 2) = 41 queries! 13x improvement
  Future<void> getResults() async {
    try {
      _logSelectedFilters();

      final blockedUserIds =
          await userBlockingService.getBlockedUserIds(_currentUserId);
      final usersThatBlockedMe =
          await userBlockingService.getUsersThatBlockedMe(_currentUserId);

      log('Blocked users: ${blockedUserIds.length}, Users that blocked me: ${usersThatBlockedMe.length}');

      // Fetch users using SwipeDataMixin with optimized limit
      // 20 users per query = 50x cost reduction from original 100
      final allUsers = await fetchAllUsers(limit: 20);

      // Filter users (now using Sets for O(1) lookup instead of O(n))
      List<Person> filteredUsers = [];
      for (var person in allUsers) {
        if (person.uid != null && person.uid != _currentUserId) {
          // O(1) lookup instead of Firestore query!
          final isBlocked = blockedUserIds.contains(person.uid);
          final hasBlockedMe = usersThatBlockedMe.contains(person.uid);

          if (!isBlocked && !hasBlockedMe) {
            // Apply filters using SwipeFilterMixin
            if (matchesFilters(person, processedUserIds)) {
              filteredUsers.add(person);
            }
          }
        }
      }

      allUsersProfileList.value = filteredUsers;

      _showResultsSnackbar(filteredUsers.length);
    } catch (e, stackTrace) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.errorOccurredWhileFetchingResults,
        snackPosition: SnackPosition.BOTTOM,
      );
      log("Error in getResults: $e");
      log("Stack trace: $stackTrace");
    }
  }

  /// Check if user is blocked (uses cached service)
  @Deprecated('Use userBlockingService.isUserBlocked() instead')
  Future<bool> isUserBlocked(String userId) async {
    return await userBlockingService.isUserBlocked(_currentUserId, userId);
  }

  /// Check if current user is blocked by another user (uses cached service)
  @Deprecated('Use userBlockingService.hasUserBlockedMe() instead')
  Future<bool> hasUserBlockedMe(String userId) async {
    return await userBlockingService.hasUserBlockedMe(_currentUserId, userId);
  }

  /// Remove top profile from the list
  void removeTopProfile() {
    if (allUsersProfileList.isNotEmpty) {
      final removedProfile = allUsersProfileList[0];
      if (removedProfile.uid != null) {
        dislikeAction(removedProfile.uid!);
      }
      allUsersProfileList.removeAt(0);
    }
  }

  /// Like action wrapper
  void likeSentAndLikeReceived({
    required String toUserId,
    required String senderName,
  }) async {
    if (processedUserIds.contains(toUserId)) {
      log("User $toUserId already processed");
      return;
    }

    await likeAction(toUserId);
    allUsersProfileList.removeWhere((profile) => profile.uid == toUserId);
  }

  /// Favorite action wrapper
  void favoriteSentAndFavoriteReceived({
    required String toUserID,
    required String senderName,
  }) async {
    if (processedUserIds.contains(toUserID)) {
      log("User $toUserID already processed");
      return;
    }

    await favoriteAction(toUserID);
    allUsersProfileList.removeWhere((profile) => profile.uid == toUserID);
  }

  /// Report user and block
  Future<void> reportUserAndBlock(
    String reportedUserId,
    ReportReason reason, [
    String? details,
  ]) async {
    try {
      await reportUser(
        reportedUserId,
        reason.toString(),
        details,
      );

      // Block user after reporting
      await blockUser(reportedUserId, reason.toString());

      // Remove from list
      allUsersProfileList
          .removeWhere((profile) => profile.uid == reportedUserId);

      Get.snackbar(
        AppStrings.reportSubmitted,
        AppStrings.thankYouForReporting,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      log("Error reporting user: $e");
      Get.snackbar(
        AppStrings.error,
        AppStrings.failedToSubmitReport,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show report dialog
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
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
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
    reportUserAndBlock(userId, reason);
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
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(AppStrings.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final reportDetails = detailsController.text;
                      Get.back();
                      reportUserAndBlock(
                        userId,
                        ReportReason.others,
                        reportDetails,
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
    ).then((_) {
      // Dialog kapandığında controller'ı her durumda temizle (cancel, submit veya dışarı tıklama)
      detailsController.dispose();
    });
  }

  /// Show filter bottom sheet
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
                    onPressed: () => clearFilters(),
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
                    color: Colors.black.withValues(alpha: 0.1),
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

  /// Social media methods
  Future<void> startChattingInWhatsApp({
    required String receiverPhoneNumber,
    required BuildContext context,
  }) async {
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
                onPressed: () => Get.back(),
                child: const Text(AppStrings.ok),
              ),
            ],
          );
        },
      );
    }
  }

  void openLinkedInProfile({
    required String linkedInUsername,
    required BuildContext context,
  }) async {
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
                onPressed: () => Get.back(),
                child: const Text(AppStrings.ok),
              ),
            ],
          );
        },
      );
    }
  }

  void openInstagramProfile({
    required String instagramUsername,
    required BuildContext context,
  }) async {
    var webUrl = "https://www.instagram.com/$instagramUsername";

    try {
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(
          Uri.parse(webUrl),
          mode: LaunchMode.externalApplication,
        );
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
                onPressed: () => Get.back(),
                child: const Text(AppStrings.ok),
              ),
            ],
          );
        },
      );
    }
  }

  /// Navigate to user profile
  void navigateToProfile(String userId) {
    Get.lazyPut<UserDetailsController>(
      () => UserDetailsController(userId: userId),
      tag: userId,
      fenix: true,
    );
    Get.to(() => UserDetails(userId: userId));
  }

  // Private helper methods

  void _logSelectedFilters() {
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
  }

  void _showResultsSnackbar(int count) {
    if (count == 0) {
      Get.snackbar(
        AppStrings.noResultsFound,
        AppStrings.noMatchingUsers,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      log("Loaded $count filtered profiles");
      Get.snackbar(
        AppStrings.success,
        '$count ${AppStrings.profilesFound}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  // UI Helper Widgets

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
            trailing: SizedBox(
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
}
