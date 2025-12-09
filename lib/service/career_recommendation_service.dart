import 'dart:math' show min, pi, sin, cos, sqrt, atan2;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:tuncforwork/models/models.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CareerRecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tüm kariyer yollarını getir
  Future<List<CareerPath>> getAllCareerPaths() async {
    try {
      final querySnapshot = await _firestore.collection('career_paths').get();

      return querySnapshot.docs
          .map((doc) => CareerPath.fromMap(doc.data()))
          .toList();
    } catch (e) {
      log('Kariyer yolları yüklenirken hata: $e');
      return [];
    }
  }

  // Kişiye özel kariyer yolu önerileri
  Future<List<Map<String, dynamic>>> getPersonalizedCareerRecommendations(
      Person person) async {
    try {
      if (person.skills == null || person.skills!.isEmpty) {
        return [];
      }

      final List<CareerPath> allPaths = await getAllCareerPaths();
      List<Map<String, dynamic>> recommendations = [];

      for (var path in allPaths) {
        // Yetenek eşleşme puanını hesapla
        double matchScore = 0;
        List<String> missingSkills = [];

        for (var requiredSkill in path.requiredSkills) {
          bool hasSkill = false;
          double skillScore = 0;

          for (var personSkill in person.skills!) {
            if (personSkill.name.toLowerCase() == requiredSkill.toLowerCase()) {
              hasSkill = true;
              // Yetenek puanı ve deneyim yılına göre skor hesapla
              skillScore = personSkill.proficiency *
                  min(personSkill.yearsOfExperience / 2, 1.0);
              break;
            }
          }

          if (hasSkill) {
            matchScore += skillScore;
          } else {
            missingSkills.add(requiredSkill);
          }
        }

        // Normalize skor (0-100 arası)
        double normalizedScore = path.requiredSkills.isNotEmpty
            ? (matchScore / path.requiredSkills.length) * 100
            : 0;

        // Hangi aşamada olduğunu belirle
        CareerStage? currentStage;
        CareerStage? nextStage;
        int stageIndex = -1;

        for (int i = 0; i < path.stages.length; i++) {
          var stage = path.stages[i];
          int matchedSkills = 0;
          int totalSkills = stage.requiredSkills.length;

          for (var stageSkill in stage.requiredSkills) {
            for (var personSkill in person.skills!) {
              if (personSkill.name.toLowerCase() == stageSkill.toLowerCase()) {
                matchedSkills++;
                break;
              }
            }
          }

          double stageMatchPercentage =
              totalSkills > 0 ? (matchedSkills / totalSkills) * 100 : 0;

          // Eğer aşama eşleşmesi %70'in üzerindeyse bu aşamada kabul et
          if (stageMatchPercentage >= 70) {
            stageIndex = i;
            currentStage = stage;

            // Bir sonraki aşamayı belirle
            if (i < path.stages.length - 1) {
              nextStage = path.stages[i + 1];
            }
          }
        }

        // Eğer hiçbir aşama ile eşleşme yoksa ilk aşamayı öner
        if (currentStage == null && path.stages.isNotEmpty) {
          stageIndex = -1;
          nextStage = path.stages[0];
        }

        // Öğrenme yolunu oluştur
        List<LearningResource> learningPath = [];

        if (nextStage != null) {
          // Eksik beceriler için kaynakları ekle
          Set<String> addedResourceTitles = {};

          for (var skill in missingSkills) {
            for (var resource in nextStage.recommendedResources) {
              if (resource.title.toLowerCase().contains(skill.toLowerCase()) &&
                  !addedResourceTitles.contains(resource.title)) {
                learningPath.add(resource);
                addedResourceTitles.add(resource.title);
              }
            }
          }

          // Eğer eksik beceriler için yeterli kaynak bulunamadıysa, genel kaynakları ekle
          if (learningPath.length < 3 &&
              nextStage.recommendedResources.isNotEmpty) {
            for (var resource in nextStage.recommendedResources) {
              if (!addedResourceTitles.contains(resource.title)) {
                learningPath.add(resource);
                addedResourceTitles.add(resource.title);

                if (learningPath.length >= 5) {
                  break; // Maksimum 5 kaynak
                }
              }
            }
          }
        }

        recommendations.add({
          'careerPath': path,
          'matchScore': normalizedScore,
          'currentStage': currentStage,
          'nextStage': nextStage,
          'stageIndex': stageIndex,
          'missingSkills': missingSkills,
          'learningPath': learningPath,
        });
      }

      // Eşleşme puanına göre sırala
      recommendations.sort((a, b) =>
          (b['matchScore'] as double).compareTo(a['matchScore'] as double));

      return recommendations;
    } catch (e) {
      log('Kariyer önerileri oluşturulurken hata: $e');
      return [];
    }
  }

  // Kariyer hedefi belirle ve Firestore'a kaydet
  Future<void> setCareerGoal(
      Person person, String careerPathId, List<String> milestones) async {
    try {
      // Kariyer yolunu getir
      final docSnapshot =
          await _firestore.collection('career_paths').doc(careerPathId).get();

      if (!docSnapshot.exists) {
        throw Exception('Belirtilen kariyer yolu bulunamadı');
      }

      final careerPath = CareerPath.fromMap(docSnapshot.data()!);

      // Eksik becerileri belirle
      List<String> missingSkills = [];

      for (var requiredSkill in careerPath.requiredSkills) {
        bool hasSkill = false;

        if (person.skills != null) {
          for (var personSkill in person.skills!) {
            if (personSkill.name.toLowerCase() == requiredSkill.toLowerCase()) {
              hasSkill = true;
              break;
            }
          }
        }

        if (!hasSkill) {
          missingSkills.add(requiredSkill);
        }
      }

      // Kariyer hedefi oluştur
      final careerGoal = CareerGoal(
        title: careerPath.title,
        description: 'Kariyer hedefi: ${careerPath.title}',
        targetDate: DateTime.now().add(Duration(days: 365)), // 1 yıl sonrası
        requiredSkills: missingSkills,
        milestones: milestones,
      );

      // Skill Gaps hesapla
      Map<String, double> skillGaps = {};

      for (var skill in missingSkills) {
        skillGaps[skill] = 0.5; // Varsayılan olarak orta düzeyde bir eksiklik
      }

      // Person nesnesini güncelle
      person.copyWith(
        careerGoal: careerGoal,
        skillGaps: skillGaps,
      );

      // Firestore'da güncelle
      await _firestore.collection('users').doc(person.uid).update({
        'careerGoal': careerGoal.toMap(),
        'skillGaps': skillGaps,
      });
    } catch (e) {
      log('Kariyer hedefi belirlenirken hata: $e');
      rethrow;
    }
  }

  // Önerilen kariyer yolları ve işler arasında eşleşmeleri bul
  Future<List<Map<String, dynamic>>> matchJobsToCareerPaths(
      Person person, List<Map<String, dynamic>> jobs) async {
    try {
      final recommendations =
          await getPersonalizedCareerRecommendations(person);

      if (recommendations.isEmpty || jobs.isEmpty) {
        return jobs;
      }

      // Her iş için en iyi kariyer yolu eşleşmesini bul
      for (int i = 0; i < jobs.length; i++) {
        var job = jobs[i];
        double bestMatchScore = 0;
        CareerPath? bestMatchPath;

        for (var recommendation in recommendations) {
          CareerPath careerPath = recommendation['careerPath'];

          // İş ilanının gerektirdiği beceriler ile kariyer yolunun becerilerini karşılaştır
          List<String> jobSkills = job['requiredSkills'];
          int matchedSkills = 0;

          for (var skill in jobSkills) {
            if (careerPath.requiredSkills
                .any((s) => s.toLowerCase() == skill.toLowerCase())) {
              matchedSkills++;
            }
          }

          double matchScore = jobSkills.isNotEmpty
              ? (matchedSkills / jobSkills.length) * 100
              : 0;

          if (matchScore > bestMatchScore) {
            bestMatchScore = matchScore;
            bestMatchPath = careerPath;
          }
        }

        // İş ilanına kariyer yolu eşleşme bilgilerini ekle
        if (bestMatchPath != null) {
          jobs[i]['careerPathMatch'] = {
            'path': bestMatchPath,
            'matchScore': bestMatchScore,
          };
        }
      }

      return jobs;
    } catch (e) {
      log('İş ilanları eşleştirilirken hata: $e');
      return jobs;
    }
  }

  // Kullanıcı için kişiselleştirilmiş öğrenme yolu oluştur
  Future<List<LearningResource>> createLearningPath(Person person) async {
    try {
      if (person.careerGoal == null ||
          person.skillGaps == null ||
          person.skillGaps!.isEmpty) {
        return [];
      }

      // Tüm kariyer yollarını getir
      final allPaths = await getAllCareerPaths();

      // Kariyer hedefine en iyi uyan yolu bul
      CareerPath? targetPath;
      for (var path in allPaths) {
        if (path.title.toLowerCase() ==
            person.careerGoal!.title.toLowerCase()) {
          targetPath = path;
          break;
        }
      }

      if (targetPath == null) {
        return [];
      }

      // Kullanıcının mevcut aşamasını belirle
      int currentStageIndex = 0;
      if (person.skills != null && person.skills!.isNotEmpty) {
        for (int i = targetPath.stages.length - 1; i >= 0; i--) {
          var stage = targetPath.stages[i];
          int matchedSkills = 0;

          for (var stageSkill in stage.requiredSkills) {
            for (var personSkill in person.skills!) {
              if (personSkill.name.toLowerCase() == stageSkill.toLowerCase()) {
                matchedSkills++;
                break;
              }
            }
          }

          double matchPercentage = stage.requiredSkills.isNotEmpty
              ? (matchedSkills / stage.requiredSkills.length) * 100
              : 0;

          if (matchPercentage >= 60) {
            currentStageIndex = i;
            break;
          }
        }
      }

      // Öğrenme yolunu oluştur
      List<LearningResource> learningPath = [];
      Set<String> addedResourceTitles = {};

      // Bir sonraki aşama ve sonrası için öğrenme kaynaklarını ekle
      for (int i = currentStageIndex; i < targetPath.stages.length; i++) {
        var stage = targetPath.stages[i];

        // Eksik becerilere odaklan
        for (var skill in person.skillGaps!.keys) {
          for (var resource in stage.recommendedResources) {
            if (resource.title.toLowerCase().contains(skill.toLowerCase()) &&
                !addedResourceTitles.contains(resource.title)) {
              learningPath.add(resource);
              addedResourceTitles.add(resource.title);
            }
          }
        }

        // Genel kaynakları ekle
        for (var resource in stage.recommendedResources) {
          if (!addedResourceTitles.contains(resource.title)) {
            learningPath.add(resource);
            addedResourceTitles.add(resource.title);

            if (learningPath.length >= 10) {
              break; // Maksimum 10 kaynak
            }
          }
        }

        // Yeterli kaynak bulunduğunda çık
        if (learningPath.length >= 10) {
          break;
        }
      }

      return learningPath;
    } catch (e) {
      log('Öğrenme yolu oluşturulurken hata: $e');
      return [];
    }
  }

  // Skills gap analizi ile kullanıcı için gelişim önerileri oluştur
  Future<Map<String, List<LearningResource>>> analyzeSkillGaps(
      Person person) async {
    try {
      if (person.skills == null || person.skills!.isEmpty) {
        return {};
      }

      // Tüm kariyer yollarını getir
      final allPaths = await getAllCareerPaths();

      // Kişinin yeteneklerine en çok uyan kariyer yollarını belirle
      List<CareerPath> matchingPaths = [];

      for (var path in allPaths) {
        int matchedSkills = 0;

        for (var pathSkill in path.requiredSkills) {
          for (var personSkill in person.skills!) {
            if (personSkill.name.toLowerCase() == pathSkill.toLowerCase()) {
              matchedSkills++;
              break;
            }
          }
        }

        double matchPercentage = path.requiredSkills.isNotEmpty
            ? (matchedSkills / path.requiredSkills.length) * 100
            : 0;

        if (matchPercentage >= 40) {
          // En az %40 eşleşme olan yolları seç
          matchingPaths.add(path);
        }
      }

      // Eğer eşleşen yol yoksa boş dön
      if (matchingPaths.isEmpty) {
        return {};
      }

      // Her kariyer yolu için eksik yetenekleri ve önerilen kaynakları belirle
      Map<String, List<LearningResource>> skillGapResources = {};

      for (var path in matchingPaths) {
        // Eksik yetenekleri belirle
        for (var pathSkill in path.requiredSkills) {
          bool hasSkill = false;

          for (var personSkill in person.skills!) {
            if (personSkill.name.toLowerCase() == pathSkill.toLowerCase()) {
              hasSkill = true;
              break;
            }
          }

          if (!hasSkill) {
            // Bu yetenek için önerilen kaynakları bul
            List<LearningResource> resources = [];

            for (var stage in path.stages) {
              for (var resource in stage.recommendedResources) {
                if (resource.title
                        .toLowerCase()
                        .contains(pathSkill.toLowerCase()) ||
                    resource.type
                        .toLowerCase()
                        .contains(pathSkill.toLowerCase())) {
                  resources.add(resource);
                }
              }
            }

            if (resources.isNotEmpty) {
              // Puanlama ve platform bazında sırala
              resources.sort((a, b) => b.rating.compareTo(a.rating));

              // En iyi 3 kaynağı al
              if (resources.length > 3) {
                resources = resources.sublist(0, 3);
              }

              skillGapResources[pathSkill] = resources;
            }
          }
        }
      }

      return skillGapResources;
    } catch (e) {
      log('Yetenek açığı analizi yapılırken hata: $e');
      return {};
    }
  }

  void showAddWorkExperienceDialog(bool isTablet) {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final descriptionController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final technologiesController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: isTablet ? Get.width * 0.7 : Get.width * 0.9,
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'İş Deneyimi Ekle',
                  style: TextStyle(
                    fontSize: isTablet ? 24.0 : 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Pozisyon',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: 'Şirket',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Başlangıç Tarihi (GG/AA/YYYY)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'Bitiş Tarihi (GG/AA/YYYY)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: technologiesController,
                  decoration: InputDecoration(
                    labelText: 'Teknolojiler (virgülle ayırın)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('İptal'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Validasyon ve kaydetme işlemleri
                        Get.back();
                      },
                      child: Text('Kaydet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final BadgeType type;
  final DateTime earnedDate;
  final Map<String, dynamic> criteria;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.earnedDate,
    required this.criteria,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'type': type.toString(),
        'earnedDate': earnedDate.millisecondsSinceEpoch,
        'criteria': criteria,
      };

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      type: BadgeType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => BadgeType.skill,
      ),
      earnedDate: DateTime.fromMillisecondsSinceEpoch(json['earnedDate']),
      criteria: json['criteria'],
    );
  }
}

enum BadgeType { skill, challenge, achievement, social, special }

class SkillMatch {
  final String skillName;
  final double matchPercentage;
  final List<String> commonProjects;
  final List<String> commonTechnologies;
  final int experienceLevel;
  final List<String> recommendations;

  SkillMatch({
    required this.skillName,
    required this.matchPercentage,
    required this.commonProjects,
    required this.commonTechnologies,
    required this.experienceLevel,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() => {
        'skillName': skillName,
        'matchPercentage': matchPercentage,
        'commonProjects': commonProjects,
        'commonTechnologies': commonTechnologies,
        'experienceLevel': experienceLevel,
        'recommendations': recommendations,
      };

  factory SkillMatch.fromJson(Map<String, dynamic> json) {
    return SkillMatch(
      skillName: json['skillName'],
      matchPercentage: json['matchPercentage'],
      commonProjects: List<String>.from(json['commonProjects']),
      commonTechnologies: List<String>.from(json['commonTechnologies']),
      experienceLevel: json['experienceLevel'],
      recommendations: List<String>.from(json['recommendations']),
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int difficulty;
  final DateTime deadline;
  final List<String> requiredSkills;
  final Map<String, dynamic> rewards;
  final bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.deadline,
    required this.requiredSkills,
    required this.rewards,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.toString(),
        'difficulty': difficulty,
        'deadline': deadline.millisecondsSinceEpoch,
        'requiredSkills': requiredSkills,
        'rewards': rewards,
        'isCompleted': isCompleted,
      };

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ChallengeType.coding,
      ),
      difficulty: json['difficulty'],
      deadline: DateTime.fromMillisecondsSinceEpoch(json['deadline']),
      requiredSkills: List<String>.from(json['requiredSkills']),
      rewards: json['rewards'],
      isCompleted: json['isCompleted'],
    );
  }
}

enum ChallengeType { coding, design, problemSolving, collaboration, learning }

class ChallengeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Challenge> activeChallenges = <Challenge>[].obs;
  final RxList<Badge> earnedBadges = <Badge>[].obs;
  final RxList<SkillMatch> skillMatches = <SkillMatch>[].obs;

  Future<void> loadUserChallenges(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .where('isCompleted', isEqualTo: false)
          .get();

      activeChallenges.value = querySnapshot.docs
          .map((doc) => Challenge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('Challenge\'lar yüklenirken hata: $e');
    }
  }

  Future<void> completeChallenge(String userId, String challengeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .doc(challengeId)
          .update({'isCompleted': true});

      await loadUserChallenges(userId);
      await checkBadgeEligibility(userId);
    } catch (e) {
      log('Challenge tamamlanırken hata: $e');
    }
  }

  Future<void> checkBadgeEligibility(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).get();
      final completedChallenges = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .where('isCompleted', isEqualTo: true)
          .get();

      // Rozet kazanma koşullarını kontrol et
      if (completedChallenges.docs.length >= 5) {
        final badge = Badge(
          id: 'challenge_master',
          name: 'Challenge Ustası',
          description: '5 challenge tamamladınız!',
          iconUrl: 'https://example.com/badges/challenge_master.png',
          type: BadgeType.achievement,
          earnedDate: DateTime.now(),
          criteria: {'completedChallenges': 5},
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('badges')
            .doc(badge.id)
            .set(badge.toJson());
      }
    } catch (e) {
      log('Rozet kontrolü yapılırken hata: $e');
    }
  }

  Future<List<SkillMatch>> findSkillMatches(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userSkills = userDoc.data()?['skills'] as List<dynamic>? ?? [];

      // Diğer kullanıcıların becerileriyle eşleştirme yap
      final otherUsers = await _firestore.collection('users').get();
      List<SkillMatch> matches = [];

      for (var doc in otherUsers.docs) {
        if (doc.id != userId) {
          final otherSkills = doc.data()['skills'] as List<dynamic>? ?? [];

          for (var skill in userSkills) {
            for (var otherSkill in otherSkills) {
              if (skill['name'] == otherSkill['name']) {
                matches.add(SkillMatch(
                  skillName: skill['name'],
                  matchPercentage:
                      (skill['proficiency'] + otherSkill['proficiency']) / 2,
                  commonProjects: [], // Proje eşleşmelerini hesapla
                  commonTechnologies: [], // Teknoloji eşleşmelerini hesapla
                  experienceLevel: (skill['yearsOfExperience'] +
                          otherSkill['yearsOfExperience']) ~/
                      2,
                  recommendations: [], // Önerileri hesapla
                ));
              }
            }
          }
        }
      }

      return matches;
    } catch (e) {
      log('Skill eşleşmeleri bulunurken hata: $e');
      return [];
    }
  }
}

class TechEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final GeoPoint coordinates;
  final String organizerId;
  final List<String> topics;
  final int maxParticipants;
  final List<String> participants;
  final String eventType; // meetup, workshop, conference
  final String imageUrl;
  final Map<String, dynamic> additionalInfo;

  TechEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.coordinates,
    required this.organizerId,
    required this.topics,
    required this.maxParticipants,
    required this.participants,
    required this.eventType,
    required this.imageUrl,
    required this.additionalInfo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.millisecondsSinceEpoch,
        'location': location,
        'coordinates': coordinates,
        'organizerId': organizerId,
        'topics': topics,
        'maxParticipants': maxParticipants,
        'participants': participants,
        'eventType': eventType,
        'imageUrl': imageUrl,
        'additionalInfo': additionalInfo,
      };

  factory TechEvent.fromJson(Map<String, dynamic> json) {
    return TechEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      location: json['location'],
      coordinates: json['coordinates'],
      organizerId: json['organizerId'],
      topics: List<String>.from(json['topics']),
      maxParticipants: json['maxParticipants'],
      participants: List<String>.from(json['participants']),
      eventType: json['eventType'],
      imageUrl: json['imageUrl'],
      additionalInfo: json['additionalInfo'],
    );
  }
}

class CoWorkingSpace {
  final String id;
  final String name;
  final String description;
  final GeoPoint coordinates;
  final String address;
  final List<String> amenities;
  final Map<String, dynamic> pricing;
  final List<String> images;
  final double rating;
  final List<String> reviews;
  final bool isOpen;
  final Map<String, dynamic> openingHours;
  final int availableSpots;

  CoWorkingSpace({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
    required this.address,
    required this.amenities,
    required this.pricing,
    required this.images,
    required this.rating,
    required this.reviews,
    required this.isOpen,
    required this.openingHours,
    required this.availableSpots,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'coordinates': coordinates,
        'address': address,
        'amenities': amenities,
        'pricing': pricing,
        'images': images,
        'rating': rating,
        'reviews': reviews,
        'isOpen': isOpen,
        'openingHours': openingHours,
        'availableSpots': availableSpots,
      };

  factory CoWorkingSpace.fromJson(Map<String, dynamic> json) {
    return CoWorkingSpace(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coordinates: json['coordinates'],
      address: json['address'],
      amenities: List<String>.from(json['amenities']),
      pricing: json['pricing'],
      images: List<String>.from(json['images']),
      rating: json['rating'],
      reviews: List<String>.from(json['reviews']),
      isOpen: json['isOpen'],
      openingHours: json['openingHours'],
      availableSpots: json['availableSpots'],
    );
  }
}

class TechCafe {
  final String id;
  final String name;
  final String description;
  final GeoPoint coordinates;
  final String address;
  final List<String> features;
  final Map<String, dynamic> menu;
  final List<String> images;
  final double rating;
  final List<String> reviews;
  final bool isOpen;
  final Map<String, dynamic> openingHours;
  final int availableSeats;
  final bool hasPowerOutlets;
  final bool hasHighSpeedInternet;

  TechCafe({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
    required this.address,
    required this.features,
    required this.menu,
    required this.images,
    required this.rating,
    required this.reviews,
    required this.isOpen,
    required this.openingHours,
    required this.availableSeats,
    required this.hasPowerOutlets,
    required this.hasHighSpeedInternet,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'coordinates': coordinates,
        'address': address,
        'features': features,
        'menu': menu,
        'images': images,
        'rating': rating,
        'reviews': reviews,
        'isOpen': isOpen,
        'openingHours': openingHours,
        'availableSeats': availableSeats,
        'hasPowerOutlets': hasPowerOutlets,
        'hasHighSpeedInternet': hasHighSpeedInternet,
      };

  factory TechCafe.fromJson(Map<String, dynamic> json) {
    return TechCafe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coordinates: json['coordinates'],
      address: json['address'],
      features: List<String>.from(json['features']),
      menu: json['menu'],
      images: List<String>.from(json['images']),
      rating: json['rating'],
      reviews: List<String>.from(json['reviews']),
      isOpen: json['isOpen'],
      openingHours: json['openingHours'],
      availableSeats: json['availableSeats'],
      hasPowerOutlets: json['hasPowerOutlets'],
      hasHighSpeedInternet: json['hasHighSpeedInternet'],
    );
  }
}

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tech Meetup oluştur
  Future<void> createTechEvent(TechEvent event) async {
    try {
      await _firestore
          .collection('tech_events')
          .doc(event.id)
          .set(event.toJson());
    } catch (e) {
      log('Tech event oluşturulurken hata: $e');
      rethrow;
    }
  }

  // Yakındaki tech eventleri getir
  Future<List<TechEvent>> getNearbyEvents(
      GeoPoint userLocation, double radiusInKm) async {
    try {
      // Yandex Maps API kullanarak yakındaki eventleri getir
      final querySnapshot = await _firestore.collection('tech_events').get();

      return querySnapshot.docs
          .map((doc) => TechEvent.fromJson(doc.data()))
          .where((event) {
        // Mesafe hesaplama
        double distance = calculateDistance(userLocation, event.coordinates);
        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      log('Yakındaki eventler getirilirken hata: $e');
      return [];
    }
  }

  // Co-working space oluştur
  Future<void> createCoWorkingSpace(CoWorkingSpace space) async {
    try {
      await _firestore
          .collection('coworking_spaces')
          .doc(space.id)
          .set(space.toJson());
    } catch (e) {
      log('Co-working space oluşturulurken hata: $e');
      rethrow;
    }
  }

  // Yakındaki co-working space'leri getir
  Future<List<CoWorkingSpace>> getNearbyCoWorkingSpaces(
      GeoPoint userLocation, double radiusInKm) async {
    try {
      final querySnapshot =
          await _firestore.collection('coworking_spaces').get();

      return querySnapshot.docs
          .map((doc) => CoWorkingSpace.fromJson(doc.data()))
          .where((space) {
        double distance = calculateDistance(userLocation, space.coordinates);
        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      log('Yakındaki co-working space\'ler getirilirken hata: $e');
      return [];
    }
  }

  // Tech cafe oluştur
  Future<void> createTechCafe(TechCafe cafe) async {
    try {
      await _firestore.collection('tech_cafes').doc(cafe.id).set(cafe.toJson());
    } catch (e) {
      log('Tech cafe oluşturulurken hata: $e');
      rethrow;
    }
  }

  // Yakındaki tech cafe'leri getir
  Future<List<TechCafe>> getNearbyTechCafes(
      GeoPoint userLocation, double radiusInKm) async {
    try {
      final querySnapshot = await _firestore.collection('tech_cafes').get();

      return querySnapshot.docs
          .map((doc) => TechCafe.fromJson(doc.data()))
          .where((cafe) {
        double distance = calculateDistance(userLocation, cafe.coordinates);
        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      log('Yakındaki tech cafe\'ler getirilirken hata: $e');
      return [];
    }
  }

  // İki nokta arasındaki mesafeyi hesapla (Haversine formülü)
  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371; // km

    double lat1 = point1.latitude * (pi / 180);
    double lat2 = point2.latitude * (pi / 180);
    double dLat = (point2.latitude - point1.latitude) * (pi / 180);
    double dLon = (point2.longitude - point1.longitude) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }
}

// Örnek Rate Limiting İyileştirmesi
class RateLimiter {
  final int maxAttempts;
  final Duration window;
  final Map<String, List<DateTime>> attempts = {};

  RateLimiter({
    this.maxAttempts = 5,
    this.window = const Duration(minutes: 1),
  });

  bool shouldLimit(String key) {
    final now = DateTime.now();
    if (!attempts.containsKey(key)) {
      attempts[key] = [now];
      return false;
    }

    attempts[key]!.removeWhere(
      (attempt) => now.difference(attempt) > window,
    );

    if (attempts[key]!.length >= maxAttempts) {
      return true;
    }

    attempts[key]!.add(now);
    return false;
  }
}
