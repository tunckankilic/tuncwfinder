import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/models/tech_event.dart';
import 'package:tuncforwork/service/push_notification_system.dart';
import 'package:tuncforwork/views/screens/favoritesent/fsfr_controller.dart';
import 'package:tuncforwork/views/screens/home/home_controller.dart';
import 'package:tuncforwork/views/screens/likesent/lslr_controller.dart';
import 'package:tuncforwork/views/screens/profile/controller/profile_controllers.dart';
import 'package:tuncforwork/views/screens/viewsent/vsvr_controller.dart';

class MockHomeController extends GetxController implements HomeController {
  @override
  final RxBool isInitialized = false.obs;
  @override
  final RxInt screenIndex = 0.obs;
  @override
  final RxBool isLoading = false.obs;
  @override
  final RxString errorMessage = ''.obs;

  @override
  PushNotificationSystem? notificationSystem;
  @override
  FsfrController? fsfrController;
  @override
  VsvrController? vsvrController;
  @override
  LslrController? lslrController;
  @override
  ProfileController? profileController;

  @override
  void changeScreen(int index) {}

  @override
  Future<void> initializeControllers() async {}

  @override
  void navigateToCommunity() {}

  @override
  void navigateToCreateEvent() {}

  @override
  void navigateToEventDetails(TechEvent event) {}

  @override
  void navigateToEventList() {}

  void navigateToMap() {}

  @override
  Future<void> refreshCurrentScreen(int index) async {}

  @override
  Widget get currentScreen => Container();

  @override
  List<GetPage> get tabScreensList => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSwipeController extends GetxController {
  final RxList<dynamic> allUsersProfileList = <dynamic>[].obs;
  final RxString senderName = "".obs;
  final RxBool isBatchProcessing = false.obs;
  final RxInt batchSize = 10.obs;

  final Set<String> _processedUserIds = <String>{};
  final Set<String> _swipedUserIds = <String>{};

  void removeTopProfile() {
    if (allUsersProfileList.isNotEmpty) {
      allUsersProfileList.removeAt(0);
    }
  }

  void likeSentAndLikeReceived(
      {required String toUserId, required String senderName}) async {
    // Mock implementation
    _processedUserIds.add(toUserId);
    _swipedUserIds.add(toUserId);
  }

  void favoriteSentAndFavoriteReceived(
      {required String toUserID, required String senderName}) async {
    // Mock implementation
    _processedUserIds.add(toUserID);
    _swipedUserIds.add(toUserID);
  }

  void showReportDialog(dynamic person) {
    // Mock implementation
  }

  void applyFilter(bool isTablet) {
    // Mock implementation
  }

  Future<void> clearProcessedUsers() async {
    // Mock implementation
    _processedUserIds.clear();
    _swipedUserIds.clear();
  }

  Map<String, dynamic> getSwipeStatistics() {
    return {
      'totalProcessed': _processedUserIds.length,
      'totalSwiped': _swipedUserIds.length,
      'remainingProfiles': allUsersProfileList.length,
      'isBatchProcessing': isBatchProcessing.value,
    };
  }

  void openInstagramProfile(
      {required String instagramUsername, required BuildContext context}) {
    // Mock implementation
  }

  void startChattingInWhatsApp(
      {required String receiverPhoneNumber, required BuildContext context}) {
    // Mock implementation
  }

  void blockUser(String blockedUserId) {
    // Mock implementation
    _processedUserIds.add(blockedUserId);
  }
}

class MockCreateEventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {},
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Etkinlik Oluştur'),
          ),
        ],
      ),
    );
  }
}

class MockCommunityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search events...',
            ),
          ),
        ],
      ),
    );
  }
}

class MockEventDetailsScreen extends StatelessWidget {
  final TechEvent event;

  const MockEventDetailsScreen({Key? key, required this.event})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(event.title),
          Text(event.description),
          Text(event.address),
          Container(
            height: 200,
            color: Colors.grey,
            child: const Center(
              child: Text('Google Map'),
            ),
          ),
        ],
      ),
    );
  }
}

class MockSwipeCards extends StatelessWidget {
  final List<dynamic> profiles;
  final Function(dynamic) onSwipeLeft;
  final Function(dynamic) onSwipeRight;
  final Function(dynamic) onSwipeUp;

  const MockSwipeCards({
    super.key,
    required this.profiles,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          Text('Mock Swipe Cards - ${profiles.length} profiles'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (profiles.isNotEmpty) {
                    onSwipeLeft(profiles[0]);
                  }
                },
                child: const Text('Swipe Left'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (profiles.isNotEmpty) {
                    onSwipeRight(profiles[0]);
                  }
                },
                child: const Text('Swipe Right'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (profiles.isNotEmpty) {
                    onSwipeUp(profiles[0]);
                  }
                },
                child: const Text('Swipe Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
