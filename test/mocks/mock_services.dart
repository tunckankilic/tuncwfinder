import 'package:get/get.dart';
import 'package:tuncforwork/models/tech_event.dart';
import 'package:tuncforwork/service/tech_event_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MockTechEventService extends GetxController implements TechEventService {
  @override
  final RxList<TechEvent> upcomingEvents = <TechEvent>[].obs;
  @override
  final RxList<TechEvent> myEvents = <TechEvent>[].obs;
  @override
  final RxBool isLoading = false.obs;
  @override
  final RxString errorMessage = ''.obs;

  @override
  Future<void> createEvent(TechEvent event) async {}

  @override
  Future<void> fetchMyEvents(String userId) async {
    myEvents.value = [testTechEvent];
  }

  @override
  Future<void> fetchUpcomingEvents() async {
    upcomingEvents.value = [testTechEvent];
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {}

  @override
  Future<void> leaveEvent(String eventId, String userId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final testTechEvent = TechEvent(
  id: '1',
  title: 'Flutter Meetup',
  description: 'Flutter ile mobil uygulama geliştirme etkinliği',
  date: DateTime.now(),
  location: const GeoPoint(41.0082, 28.9784),
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
