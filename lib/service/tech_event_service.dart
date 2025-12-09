import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/models/tech_event.dart';
import 'package:tuncforwork/service/push_notification_system.dart';

import 'dart:developer';

class TechEventService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<TechEvent> upcomingEvents = <TechEvent>[].obs;
  final RxList<TechEvent> myEvents = <TechEvent>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Etkinlik oluşturma
  Future<void> createEvent(TechEvent event) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestore
          .collection('tech_events')
          .doc(event.id)
          .set(event.toMap());

      // Etkinlik oluşturulduğunda katılımcılara bildirim gönder
      if (event.isPublished) {
        await _sendEventNotification(
          event,
          'Yeni Etkinlik',
          '${event.title} etkinliği oluşturuldu!',
        );
      }
    } catch (e) {
      errorMessage.value = 'Etkinlik oluşturulurken hata: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Yaklaşan etkinlikleri getir
  Future<void> fetchUpcomingEvents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestore
          .collection('tech_events')
          .where('date', isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .where('isPublished', isEqualTo: true)
          .orderBy('date')
          .get();

      upcomingEvents.value =
          snapshot.docs.map((doc) => TechEvent.fromMap(doc.data())).toList();
    } catch (e) {
      errorMessage.value = 'Etkinlikler yüklenirken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Kullanıcının etkinliklerini getir
  Future<void> fetchMyEvents(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _firestore
          .collection('tech_events')
          .where('organizerId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      myEvents.value =
          snapshot.docs.map((doc) => TechEvent.fromMap(doc.data())).toList();
    } catch (e) {
      errorMessage.value = 'Etkinlikleriniz yüklenirken hata: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Etkinliğe katıl
  Future<void> joinEvent(String eventId, String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestore.collection('tech_events').doc(eventId).update({
        'participants': FieldValue.arrayUnion([userId]),
      });

      // Etkinlik sahibine bildirim gönder
      final eventDoc =
          await _firestore.collection('tech_events').doc(eventId).get();
      final event = TechEvent.fromMap(eventDoc.data()!);

      await _sendEventNotification(
        event,
        'Yeni Katılımcı',
        'Etkinliğinize yeni bir katılımcı eklendi!',
        [event.organizerId],
      );
    } catch (e) {
      errorMessage.value = 'Etkinliğe katılırken hata: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Etkinlikten ayrıl
  Future<void> leaveEvent(String eventId, String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestore.collection('tech_events').doc(eventId).update({
        'participants': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      errorMessage.value = 'Etkinlikten ayrılırken hata: $e';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Katılımcı sayısına göre mekan önerisi - Google Maps kaldırıldı
  Future<List<Map<String, dynamic>>> suggestVenues(
      int participantCount, dynamic location) async {
    try {
      final snapshot = await _firestore
          .collection('venues')
          .where('capacity', isGreaterThanOrEqualTo: participantCount)
          .get();

      final venues = snapshot.docs.map((doc) => doc.data()).toList();
      return venues;
    } catch (e) {
      errorMessage.value = 'Mekan önerileri alınırken hata: $e';
      return [];
    }
  }

  // Toplu taşıma bilgilerini getir - Google Maps kaldırıldı
  Future<Map<String, dynamic>> getTransportationInfo(
      dynamic origin, dynamic destination) async {
    try {
      // Google Maps API kaldırıldı
      return {};
    } catch (e) {
      errorMessage.value = 'Ulaşım bilgileri alınırken hata: $e';
      return {};
    }
  }

  // Etkinlik bildirimi gönder
  Future<void> _sendEventNotification(
    TechEvent event,
    String title,
    String body, [
    List<String>? specificUserIds,
  ]) async {
    try {
      final notificationSystem = Get.find<PushNotificationSystem>();

      if (specificUserIds != null) {
        // Belirli kullanıcılara bildirim gönder
        final userTokens = await _getUserTokens(specificUserIds);
        for (final token in userTokens) {
          await notificationSystem.sendEventNotification(
            userDeviceToken: token,
            eventTitle: event.title,
            message: body,
            type: NotificationType.eventInvite,
            eventData: {
              'eventId': event.id,
              'type': 'event_notification',
              'eventType': event.type.toString(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
          );
        }
      } else {
        // Tüm kullanıcılara bildirim gönder
        final allTokens = await _getAllUserTokens();
        for (final token in allTokens) {
          await notificationSystem.sendEventNotification(
            userDeviceToken: token,
            eventTitle: event.title,
            message: body,
            type: NotificationType.eventInvite,
            eventData: {
              'eventId': event.id,
              'type': 'event_notification',
              'eventType': event.type.toString(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
          );
        }
      }

      // Etkinlik başlangıcından 1 gün önce hatırlatma gönder
      if (event.date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
        final participantTokens = await _getUserTokens(event.participants);
        for (final token in participantTokens) {
          await notificationSystem.sendEventNotification(
            userDeviceToken: token,
            eventTitle: event.title,
            message: '${event.title} etkinliği yarın başlıyor!',
            type: NotificationType.eventReminder,
            eventData: {
              'eventId': event.id,
              'type': 'event_reminder',
              'eventType': event.type.toString(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            },
            scheduledTime: event.date.subtract(const Duration(days: 1)),
          );
        }
      }
    } catch (e) {
      log('Bildirim gönderilirken hata: $e');
    }
  }

  // Kullanıcı token'larını getir
  Future<List<String>> _getUserTokens(List<String> userIds) async {
    try {
      final tokens = <String>[];
      for (final userId in userIds) {
        final doc = await _firestore.collection('users').doc(userId).get();
        final token = doc.data()?['userDeviceToken'] as String?;
        if (token != null) {
          tokens.add(token);
        }
      }
      return tokens;
    } catch (e) {
      log('Kullanıcı tokenleri alınırken hata: $e');
      return [];
    }
  }

  // Tüm kullanıcı token'larını getir
  Future<List<String>> _getAllUserTokens() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => doc.data()['userDeviceToken'] as String?)
          .where((token) => token != null)
          .cast<String>()
          .toList();
    } catch (e) {
      log('Tüm tokenler alınırken hata: $e');
      return [];
    }
  }
}
