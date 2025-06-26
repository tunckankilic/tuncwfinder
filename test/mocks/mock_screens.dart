import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/models/tech_event.dart';
import 'package:tuncforwork/service/push_notification_system.dart';
import 'package:tuncforwork/views/screens/community/create_event_screen.dart';
import 'package:tuncforwork/views/screens/community/event_details_screen.dart';
import 'package:tuncforwork/views/screens/community/community_screen.dart';
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

  @override
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
