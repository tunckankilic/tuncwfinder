import 'package:flutter_test/flutter_test.dart';
import 'package:tuncforwork/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_mock.dart';

Future<void> setupTestApp() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await setupFirebaseTest();
}

// Test verileri
final testPerson = Person(
  uid: 'test_user_id',
  name: 'Test User',
  email: 'test@example.com',
  skills: [
    Skill(name: 'Flutter', proficiency: 0.8, yearsOfExperience: 2),
    Skill(name: 'Dart', proficiency: 0.7, yearsOfExperience: 2),
    Skill(name: 'Firebase', proficiency: 0.6, yearsOfExperience: 1),
  ],
);

final testJobs = [
  JobPosting(
    id: 'job1',
    title: 'Flutter Developer',
    company: 'Test Company',
    location: 'İstanbul',
    requiredSkills: ['Flutter', 'Dart', 'Firebase'],
    description: 'Senior Flutter Developer pozisyonu',
    requiredYearsExperience: 3,
    educationLevel: 'Lisans',
  ),
  JobPosting(
    id: 'job2',
    title: 'Mobile Developer',
    company: 'Another Company',
    location: 'Ankara',
    requiredSkills: ['Flutter', 'Swift', 'Kotlin'],
    description: 'Mobile Developer pozisyonu',
    requiredYearsExperience: 2,
    educationLevel: 'Lisans',
  ),
];

final testTechEvent = TechEvent(
  id: 'event1',
  title: 'Flutter Meetup',
  description: 'Flutter geliştiricileri için meetup',
  date: DateTime.now().add(Duration(days: 7)),
  location: GeoPoint(41.0082, 28.9784),
  venueId: 'venue1',
  venueName: 'Tech Hub İstanbul',
  venueType: VenueType.coWorkingSpace,
  maxParticipants: 50,
  topics: ['Flutter', 'Dart', 'Mobile Development'],
  requirements: ['Laptop', 'Flutter SDK'],
  organizerId: 'organizer1',
  participants: [],
  type: EventType.meetup,
  speakers: ['John Doe', 'Jane Smith'],
  isOnline: false,
  isHybrid: false,
  joinLink: null,
  sponsors: [],
  agenda: [],
  resources: [],
  address: 'Levent, İstanbul',
  isPublished: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
