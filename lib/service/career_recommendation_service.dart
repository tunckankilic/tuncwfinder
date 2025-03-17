import 'dart:math' show min;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncforwork/models/models.dart';

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
      print('Kariyer yolları yüklenirken hata: $e');
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
      print('Kariyer önerileri oluşturulurken hata: $e');
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
      Person updatedPerson = person.copyWith(
        careerGoal: careerGoal,
        skillGaps: skillGaps,
      );

      // Firestore'da güncelle
      await _firestore.collection('users').doc(person.uid).update({
        'careerGoal': careerGoal.toMap(),
        'skillGaps': skillGaps,
      });
    } catch (e) {
      print('Kariyer hedefi belirlenirken hata: $e');
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
      print('İş ilanları eşleştirilirken hata: $e');
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
      print('Öğrenme yolu oluşturulurken hata: $e');
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
      print('Yetenek açığı analizi yapılırken hata: $e');
      return {};
    }
  }
}
