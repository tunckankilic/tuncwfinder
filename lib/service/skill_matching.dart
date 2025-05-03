import 'dart:math';
import 'package:tuncforwork/models/models.dart';

class SkillMatchingService {
  // TF-IDF hesaplama için yardımcı fonksiyonlar
  Map<String, double> _calculateTermFrequency(List<String> document) {
    Map<String, double> tf = {};
    for (var term in document) {
      tf[term] = (tf[term] ?? 0) + 1;
    }

    // Normalize
    int docLength = document.length;
    tf.forEach((term, count) {
      tf[term] = count / docLength;
    });

    return tf;
  }

  Map<String, double> _calculateInverseDocumentFrequency(
      List<List<String>> documents) {
    Map<String, double> idf = {};
    Set<String> uniqueTerms = {};

    // Tüm belgelerdeki benzersiz terimleri topla
    for (var doc in documents) {
      for (var term in Set<String>.from(doc)) {
        uniqueTerms.add(term);
      }
    }

    // Her terim için IDF değerini hesapla
    for (var term in uniqueTerms) {
      int docsWithTerm = 0;
      for (var doc in documents) {
        if (doc.contains(term)) {
          docsWithTerm++;
        }
      }
      idf[term] = log(documents.length / docsWithTerm);
    }

    return idf;
  }

  Map<String, double> _calculateTfIdf(
      Map<String, double> tf, Map<String, double> idf) {
    Map<String, double> tfIdf = {};
    tf.forEach((term, tfValue) {
      tfIdf[term] = tfValue * (idf[term] ?? 0);
    });
    return tfIdf;
  }

  double _calculateCosineSimilarity(
      Map<String, double> vec1, Map<String, double> vec2) {
    // Tüm terimleri birleştir
    Set<String> allTerms = {...vec1.keys, ...vec2.keys};

    double dotProduct = 0;
    double mag1 = 0;
    double mag2 = 0;

    for (var term in allTerms) {
      double v1 = vec1[term] ?? 0;
      double v2 = vec2[term] ?? 0;

      dotProduct += v1 * v2;
      mag1 += v1 * v1;
      mag2 += v2 * v2;
    }

    mag1 = sqrt(mag1);
    mag2 = sqrt(mag2);

    if (mag1 == 0 || mag2 == 0) return 0;
    return dotProduct / (mag1 * mag2);
  }

  double calculateSkillMatch(Person user, JobPosting job) {
    // Kullanıcının becerileri yoksa eşleşme sağlanamaz
    if (user.skills == null || user.skills!.isEmpty) {
      return 0.0;
    }

    // 1. Beceri eşleşmesi puanı (40%)
    double skillMatchScore = 0;
    int matchedSkillsCount = 0;

    for (var requiredSkill in job.requiredSkills) {
      for (var userSkill in user.skills!) {
        if (userSkill.name.toLowerCase() == requiredSkill.toLowerCase()) {
          // Beceri eşleşti, deneyim yılına ve uzmanlık seviyesine göre puan ekle
          double experienceWeight = min(
              userSkill.yearsOfExperience / max(1, job.requiredYearsExperience),
              1.0);
          double skillWeight = userSkill.proficiency;

          skillMatchScore += experienceWeight * skillWeight;
          matchedSkillsCount++;
          break;
        }
      }
    }

    // Normalize skill match score
    double normalizedSkillScore = job.requiredSkills.isNotEmpty
        ? skillMatchScore / job.requiredSkills.length
        : 0;

    // 2. İş açıklaması ve kullanıcı deneyimi/projeleri arasında metin benzerliği (30%)
    List<String> jobDescription = job.description.toLowerCase().split(' ');

    // Kullanıcı deneyimlerini ve proje açıklamalarını birleştir
    List<String> userExperience = [];

    // İş deneyimlerini ekle
    if (user.workExperiences != null && user.workExperiences!.isNotEmpty) {
      for (var exp in user.workExperiences!) {
        userExperience.addAll(exp.description.toLowerCase().split(' '));
        userExperience.addAll(exp.title.toLowerCase().split(' '));
      }
    }

    // Projeleri ekle
    if (user.projects != null && user.projects!.isNotEmpty) {
      for (var proj in user.projects!) {
        userExperience.addAll(proj.description.toLowerCase().split(' '));
        userExperience.addAll(proj.title.toLowerCase().split(' '));
      }
    }

    List<List<String>> allDocuments = [jobDescription, userExperience];

    // TF-IDF ve Kosinüs Benzerliği hesapla
    Map<String, double> jobTF = _calculateTermFrequency(jobDescription);
    Map<String, double> userTF = _calculateTermFrequency(userExperience);
    Map<String, double> idf = _calculateInverseDocumentFrequency(allDocuments);

    Map<String, double> jobTfIdf = _calculateTfIdf(jobTF, idf);
    Map<String, double> userTfIdf = _calculateTfIdf(userTF, idf);

    double textSimilarity = _calculateCosineSimilarity(jobTfIdf, userTfIdf);

    // 3. Eğitim seviyesi eşleşmesi (20%)
    double educationScore = 0;

    // Temel eğitim bilgisini kontrol et
    if (user.education != null &&
        user.education!
            .toLowerCase()
            .contains(job.educationLevel.toLowerCase())) {
      educationScore = 1.0;
    }

    // Ayrıca eğitim geçmişini de kontrol et
    if (educationScore < 1.0 &&
        user.educationHistory != null &&
        user.educationHistory!.isNotEmpty) {
      for (var edu in user.educationHistory!) {
        if (edu.toLowerCase().contains(job.educationLevel.toLowerCase())) {
          educationScore = 1.0;
          break;
        }
      }
    }

    // 4. Eşleşen becerilerin oranı (10%)
    double matchRatio = job.requiredSkills.isNotEmpty
        ? matchedSkillsCount / job.requiredSkills.length
        : 0;

    // Ağırlıklı toplam skor hesapla
    double totalScore = (normalizedSkillScore * 0.4) +
        (textSimilarity * 0.3) +
        (educationScore * 0.2) +
        (matchRatio * 0.1);

    return totalScore * 100; // Yüzdelik skora dönüştür
  }

  List<Map<String, dynamic>> matchJobsToUser(
      Person user, List<JobPosting> jobs) {
    List<Map<String, dynamic>> results = [];

    for (var job in jobs) {
      double matchScore = calculateSkillMatch(user, job);

      results.add({
        'job': job,
        'score': matchScore,
        'matchReason': _generateMatchReason(user, job, matchScore)
      });
    }

    // Skor'a göre azalan sıralama
    results.sort((a, b) => (b['score']).compareTo(a['score']));

    return results;
  }

  String _generateMatchReason(Person user, JobPosting job, double score) {
    if (score >= 90) {
      return "Mükemmel eşleşme! Aranan becerilerin çoğuna sahipsiniz.";
    } else if (score >= 70) {
      return "İyi eşleşme. Temel becerileriniz iş için uygun.";
    } else if (score >= 50) {
      return "Kısmi eşleşme. Bazı becerilere sahipsiniz ancak gelişim alanları var.";
    } else {
      return "Düşük eşleşme. Bu pozisyon için becerilerinizi geliştirmeniz gerekebilir.";
    }
  }
}
