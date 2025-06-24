import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType {
  meetup,
  workshop,
  conference,
  hackathon,
  webinar,
  networking,
  training
}

enum VenueType {
  coWorkingSpace,
  techCafe,
  conferenceHall,
  office,
  university,
  other
}

class TechEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final GeoPoint location;
  final String venueId;
  final String venueName;
  final VenueType venueType;
  final int maxParticipants;
  final List<String> topics;
  final List<String> requirements;
  final String organizerId;
  final List<String> participants;
  final EventType type;
  final List<String> speakers;
  final bool isOnline;
  final bool isHybrid;
  final String? joinLink;
  final List<String>? sponsors;
  final List<Schedule> agenda;
  final List<Resource> resources;
  final String address;
  final Map<String, dynamic>? transportationInfo;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  TechEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.venueId,
    required this.venueName,
    required this.venueType,
    required this.maxParticipants,
    required this.topics,
    required this.requirements,
    required this.organizerId,
    required this.participants,
    required this.type,
    required this.speakers,
    required this.isOnline,
    required this.isHybrid,
    this.joinLink,
    this.sponsors,
    required this.agenda,
    required this.resources,
    required this.address,
    this.transportationInfo,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'venueId': venueId,
      'venueName': venueName,
      'venueType': venueType.toString(),
      'maxParticipants': maxParticipants,
      'topics': topics,
      'requirements': requirements,
      'organizerId': organizerId,
      'participants': participants,
      'type': type.toString(),
      'speakers': speakers,
      'isOnline': isOnline,
      'isHybrid': isHybrid,
      'joinLink': joinLink,
      'sponsors': sponsors,
      'agenda': agenda.map((x) => x.toMap()).toList(),
      'resources': resources.map((x) => x.toMap()).toList(),
      'address': address,
      'transportationInfo': transportationInfo,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TechEvent.fromMap(Map<String, dynamic> map) {
    return TechEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: (map['date'] as Timestamp).toDate(),
      location: map['location'],
      venueId: map['venueId'],
      venueName: map['venueName'],
      venueType:
          VenueType.values.firstWhere((e) => e.toString() == map['venueType']),
      maxParticipants: map['maxParticipants'],
      topics: List<String>.from(map['topics']),
      requirements: List<String>.from(map['requirements']),
      organizerId: map['organizerId'],
      participants: List<String>.from(map['participants']),
      type: EventType.values.firstWhere((e) => e.toString() == map['type']),
      speakers: List<String>.from(map['speakers']),
      isOnline: map['isOnline'],
      isHybrid: map['isHybrid'],
      joinLink: map['joinLink'],
      sponsors:
          map['sponsors'] != null ? List<String>.from(map['sponsors']) : null,
      agenda: List<Schedule>.from(
          map['agenda']?.map((x) => Schedule.fromMap(x)) ?? []),
      resources: List<Resource>.from(
          map['resources']?.map((x) => Resource.fromMap(x)) ?? []),
      address: map['address'],
      transportationInfo: map['transportationInfo'],
      isPublished: map['isPublished'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class Schedule {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String speaker;
  final String description;

  Schedule({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.speaker,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'speaker': speaker,
      'description': description,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      title: map['title'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      speaker: map['speaker'],
      description: map['description'],
    );
  }
}

class Resource {
  final String title;
  final String type;
  final String url;
  final bool isPublic;

  Resource({
    required this.title,
    required this.type,
    required this.url,
    required this.isPublic,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'url': url,
      'isPublic': isPublic,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      title: map['title'],
      type: map['type'],
      url: map['url'],
      isPublic: map['isPublic'],
    );
  }
}
