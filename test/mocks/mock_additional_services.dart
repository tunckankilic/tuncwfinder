import 'package:tuncforwork/models/models.dart';
import 'package:tuncforwork/service/career_recommendation_service.dart';

/// Basit Firestore bağımsız kariyer öneri servisi mock'u.
class MockCareerRecommendationService extends CareerRecommendationService {
  MockCareerRecommendationService({List<CareerPath>? paths})
      : _paths = paths ?? [];

  final List<CareerPath> _paths;

  @override
  Future<List<CareerPath>> getAllCareerPaths() async => _paths;

  @override
  Future<List<Map<String, dynamic>>> getPersonalizedCareerRecommendations(
      Person person) async {
    return _paths.map((path) {
      final missingSkills = path.requiredSkills
          .where((skill) => !(person.skills ?? [])
              .any((p) => p.name.toLowerCase() == skill.toLowerCase()))
          .toList();

      final total = path.requiredSkills.length;
      final matchScore =
          total == 0 ? 100.0 : ((total - missingSkills.length) / total) * 100;

      return {
        'careerPath': path,
        'matchScore': matchScore,
        'currentStage': path.stages.isNotEmpty ? path.stages.first : null,
        'nextStage': path.stages.length > 1 ? path.stages[1] : null,
        'stageIndex': missingSkills.isEmpty ? 0 : -1,
        'missingSkills': missingSkills,
        'learningPath': path.stages.isNotEmpty
            ? path.stages.first.recommendedResources
            : <LearningResource>[],
      };
    }).toList();
  }

  @override
  Future<void> setCareerGoal(
      Person person, String careerPathId, List<String> milestones) async {
    // Testler için no-op
  }
}

//  PushNotificationSystem kaldırıldı (performans için)
// Aşağıdaki mock artık kullanılmıyor ancak referans için bırakıldı

/*
/// Ağ bağımlılığı olmadan bildirim davranışı kaydeden mock.
class MockPushNotificationSystem extends GetxController {
  final List<Map<String, dynamic>> sentNotifications = [];
  String? lastGeneratedToken;
  bool initialized = false;

  @override
  bool get isInitialized => initialized;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> generateDeviceRegistrationToken() async {
    lastGeneratedToken = 'mock-token';
  }

  @override
  Future<void> sendNotification({
    required String userDeviceToken,
    required String title,
    required String body,
    required NotificationType type,
    required NotificationChannel channel,
    Map<String, dynamic>? additionalData,
    String? groupKey,
    bool isScheduled = false,
    DateTime? scheduledTime,
  }) async {
    sentNotifications.add({
      'token': userDeviceToken,
      'title': title,
      'body': body,
      'type': type,
      'channel': channel,
      'additionalData': additionalData,
      'groupKey': groupKey,
      'isScheduled': isScheduled,
      'scheduledTime': scheduledTime,
    });
  }

  @override
  Future<void> sendEventNotification({
    required String userDeviceToken,
    required String eventTitle,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? eventData,
    DateTime? scheduledTime,
  }) async {
    await sendNotification(
      userDeviceToken: userDeviceToken,
      title: 'Event: $eventTitle',
      body: message,
      type: type,
      channel: NotificationChannel.events,
      additionalData: eventData,
      isScheduled: scheduledTime != null,
      scheduledTime: scheduledTime,
    );
  }

  @override
  Future<void> sendInteractionNotification({
    required String userDeviceToken,
    required String senderName,
    required NotificationType type,
    required String receiverId,
    required String senderId,
  }) async {
    await sendNotification(
      userDeviceToken: userDeviceToken,
      title: senderName,
      body: 'mock-interaction',
      type: type,
      channel: NotificationChannel.matches,
      additionalData: {
        'receiverId': receiverId,
        'senderId': senderId,
      },
    );
  }

  @override
  Future<void> whenNotificationReceived(BuildContext context) async {
    // Test ortamında dinleyici kurmaya gerek yok
  }

  @override
  Future<void> openAppAndShowNotificationData(
      String? receiverID, String? senderID, BuildContext context) async {
    // UI açma yok
  }

  Widget notificationDialogBox(
      String senderID,
      String profileImage,
      String name,
      String age,
      String city,
      String country,
      String profession,
      BuildContext context) {
    // Testler için minimal placeholder
    return const SizedBox.shrink();
  }
}
*/
