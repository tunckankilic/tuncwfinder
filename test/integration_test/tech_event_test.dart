import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:tuncforwork/views/screens/community/community_screen.dart';
import 'package:tuncforwork/views/screens/community/create_event_screen.dart';
import 'package:tuncforwork/views/screens/community/event_details_screen.dart';
import 'package:tuncforwork/service/tech_event_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncforwork/models/tech_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/views/screens/home/home_controller.dart';
import '../mocks/mock_screens.dart';
import '../mocks/mock_services.dart';

class MockTechEventService extends GetxService
    with Mock
    implements TechEventService {
  @override
  final RxList<TechEvent> upcomingEvents = <TechEvent>[].obs;
  @override
  final RxList<TechEvent> myEvents = <TechEvent>[].obs;
  @override
  final RxBool isLoading = false.obs;
  @override
  final RxString errorMessage = ''.obs;

  @override
  Future<void> fetchUpcomingEvents() async {
    upcomingEvents.value = [testTechEvent];
  }

  @override
  Future<void> fetchMyEvents(String userId) async {
    myEvents.value = [testTechEvent];
  }

  @override
  Disposer addListener(GetStateUpdate listener) {
    // TODO: implement addListener
    throw UnimplementedError();
  }

  @override
  Disposer addListenerId(Object? key, GetStateUpdate listener) {
    // TODO: implement addListenerId
    throw UnimplementedError();
  }

  @override
  Future<void> createEvent(TechEvent event) {
    // TODO: implement createEvent
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void disposeId(Object id) {
    // TODO: implement disposeId
  }

  @override
  Future<Map<String, dynamic>> getTransportationInfo(
      LatLng origin, LatLng destination) {
    // TODO: implement getTransportationInfo
    throw UnimplementedError();
  }

  @override
  // TODO: implement hasListeners
  bool get hasListeners => throw UnimplementedError();

  @override
  Future<void> joinEvent(String eventId, String userId) {
    // TODO: implement joinEvent
    throw UnimplementedError();
  }

  @override
  Future<void> leaveEvent(String eventId, String userId) {
    // TODO: implement leaveEvent
    throw UnimplementedError();
  }

  @override
  // TODO: implement listeners
  int get listeners => throw UnimplementedError();

  @override
  void notifyChildrens() {
    // TODO: implement notifyChildrens
  }

  @override
  void refresh() {
    // TODO: implement refresh
  }

  @override
  void refreshGroup(Object id) {
    // TODO: implement refreshGroup
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
  }

  @override
  void removeListenerId(Object id, VoidCallback listener) {
    // TODO: implement removeListenerId
  }

  @override
  Future<List<Map<String, dynamic>>> suggestVenues(
      int participantCount, LatLng location) {
    // TODO: implement suggestVenues
    throw UnimplementedError();
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    // TODO: implement update
  }
}

final testTechEvent = TechEvent(
  id: '1',
  title: 'Flutter Meetup',
  description: 'Flutter ile mobil uygulama geliştirme etkinliği',
  date: DateTime.now(),
  location: GeoPoint(41.0082, 28.9784),
  venueId: 'venue-1',
  venueName: 'Tech Hub',
  venueType: VenueType.techCafe,
  maxParticipants: 50,
  topics: ['Flutter', 'Mobile Development'],
  requirements: ['Laptop', 'Flutter SDK'],
  organizerId: 'test-user',
  participants: ['user1', 'user2'],
  type: EventType.meetup,
  speakers: ['John Doe'],
  isOnline: false,
  isHybrid: false,
  agenda: [],
  resources: [],
  address: 'İstanbul, Türkiye',
  isPublished: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

void main() {
  group('Etkinlik Yönetimi Widget Testleri', () {
    setUp(() {
      final mockService = MockTechEventService();
      Get.put<TechEventService>(mockService);
      Get.put<HomeController>(MockHomeController());
    });

    testWidgets('Etkinlik oluşturma formu testi', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            home: MockCreateEventScreen(),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.text('Etkinlik Oluştur'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        testTechEvent.title,
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        testTechEvent.description,
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        testTechEvent.address,
      );

      expect(find.text(testTechEvent.title), findsOneWidget);
      expect(find.text(testTechEvent.description), findsOneWidget);
      expect(find.text(testTechEvent.address), findsOneWidget);
    });

    testWidgets('Etkinlik arama testi', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            home: MockCommunityScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        'Flutter',
      );
      await tester.pumpAndSettle();
    });

    testWidgets('Etkinlik detay ekranı testi', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            home: MockEventDetailsScreen(event: testTechEvent),
          ),
        ),
      );

      expect(find.text(testTechEvent.title), findsOneWidget);
      expect(find.text(testTechEvent.description), findsOneWidget);
      expect(find.text(testTechEvent.address), findsOneWidget);
      expect(find.text('Google Map'), findsOneWidget);
    });
  });
}
