import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuncforwork/models/models.dart';
import '../models/person.dart';

class LinkedInApiService {
  final String baseUrl = 'https://api.linkedin.com/v2';
  String? accessToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('linkedin_token');
  }

  // LinkedIn API'ye istek göndermek için yardımcı metod
  Future<Map<String, dynamic>> _makeRequest(String endpoint) async {
    if (accessToken == null) {
      await init();
      if (accessToken == null) {
        throw Exception('LinkedIn erişim tokeni bulunamadı');
      }
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'cache-control': 'no-cache',
        'X-Restli-Protocol-Version': '2.0.0',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'LinkedIn API hatası: ${response.statusCode} - ${response.body}');
    }
  }

  // Kullanıcı profilini getir
  Future<Map<String, dynamic>> getUserProfile() async {
    return await _makeRequest(
        'me?projection=(id,firstName,lastName,headline,summary,profilePicture(displayImage~:playableStreams))');
  }

  // Kullanıcının becerilerini getir
  Future<List<Map<String, dynamic>>> getUserSkills() async {
    final data = await _makeRequest('me/skills');
    return List<Map<String, dynamic>>.from(data['elements']);
  }

  // Kullanıcının sertifikalarını getir
  Future<List<Map<String, dynamic>>> getUserCertifications() async {
    final data = await _makeRequest('me/certifications');
    return List<Map<String, dynamic>>.from(data['elements']);
  }

  // Kullanıcının iş deneyimlerini getir
  Future<List<Map<String, dynamic>>> getUserExperiences() async {
    final data = await _makeRequest('me/positions');
    return List<Map<String, dynamic>>.from(data['elements']);
  }

  // Kullanıcının eğitim bilgilerini getir
  Future<List<Map<String, dynamic>>> getUserEducation() async {
    final data = await _makeRequest('me/educations');
    return List<Map<String, dynamic>>.from(data['elements']);
  }

  // LinkedIn API'den alınan verileri kullanarak Person nesnesini güncelle
  Future<Person> updatePersonWithLinkedInInfo(Person person) async {
    try {
      await init(); // Token'ı yükle

      if (accessToken == null) {
        return person; // Token yoksa güncelleme yapma
      }

      // Profil bilgilerini al
      final profile = await getUserProfile();

      // Beceri bilgilerini al
      final skills = await getUserSkills();
      final List<String> skillNames = [];
      for (var skill in skills) {
        skillNames.add(skill['name']);
      }

      // Sertifikaları al
      final certifications = await getUserCertifications();
      final List<String> certNames = [];
      for (var cert in certifications) {
        certNames.add(cert['name']);
      }

      // Deneyim bilgilerini al
      final experiences = await getUserExperiences();
      final List<WorkExperience> workExperiences = [];

      for (var exp in experiences) {
        workExperiences.add(WorkExperience(
          title: exp['title'],
          company: exp['companyName'],
          description: exp['description'] ?? '',
          startDate: DateTime.parse(
              '${exp['startDate']['year']}-${exp['startDate']['month']}-01'),
          endDate: exp['endDate'] != null
              ? DateTime.parse(
                  '${exp['endDate']['year']}-${exp['endDate']['month']}-01')
              : null,
          technologies: [], // LinkedIn API'den teknoloji bilgisi alamıyoruz
        ));
      }

      // Eğitim bilgilerini al
      final educations = await getUserEducation();
      final List<String> educationList = [];

      for (var edu in educations) {
        educationList.add(
            '${edu['schoolName']} - ${edu['degreeName'] ?? 'Belirtilmemiş'} (${edu['startDate']['year']} - ${edu['endDate'] != null ? edu['endDate']['year'] : 'Devam Ediyor'})');
      }

      // LinkedIn bilgilerini oluştur
      final linkedInInfo = LinkedInInfo(
        endorsedSkills: skillNames,
        connections: [], // API'den connection sayısını alamıyoruz
        headline: profile['headline'],
        summary: profile['summary'],
        certifications: certNames,
      );

      // Person nesnesini güncelle
      person = person.copyWith(
        linkedInInfo: linkedInInfo,
        workExperiences: workExperiences,
        educationHistory: educationList,
      );

      // Bu verilerden yetenek çıkarımı yap
      List<Skill> extractedSkills = extractSkillsFromLinkedIn(person);

      // Mevcut yetenekleri güncelle veya ekle
      List<Skill> updatedSkills = person.skills ?? [];

      for (var extractedSkill in extractedSkills) {
        // Eğer yetenek zaten varsa güncelle
        bool found = false;
        for (int i = 0; i < updatedSkills.length; i++) {
          if (updatedSkills[i].name.toLowerCase() ==
              extractedSkill.name.toLowerCase()) {
            // Daha yüksek değerleri koru
            updatedSkills[i] = Skill(
              name: extractedSkill.name,
              proficiency:
                  extractedSkill.proficiency > updatedSkills[i].proficiency
                      ? extractedSkill.proficiency
                      : updatedSkills[i].proficiency,
              yearsOfExperience: extractedSkill.yearsOfExperience >
                      updatedSkills[i].yearsOfExperience
                  ? extractedSkill.yearsOfExperience
                  : updatedSkills[i].yearsOfExperience,
            );
            found = true;
            break;
          }
        }

        // Yetenek yoksa ekle
        if (!found) {
          updatedSkills.add(extractedSkill);
        }
      }

      person = person.copyWith(skills: updatedSkills);

      // Firestore'da güncelle
      await FirebaseFirestore.instance
          .collection('users')
          .doc(person.uid)
          .update(person.toMap());

      return person;
    } catch (e) {
      print('LinkedIn bilgileri alınırken hata: $e');
      return person;
    }
  }

  // LinkedIn verilerinden beceri çıkarımı yap
  List<Skill> extractSkillsFromLinkedIn(Person person) {
    List<Skill> linkedInSkills = [];

    if (person.linkedInInfo == null ||
        person.linkedInInfo!.endorsedSkills.isEmpty) {
      return linkedInSkills;
    }

    // LinkedIn'deki becerileri dönüştür
    for (var skillName in person.linkedInInfo!.endorsedSkills) {
      // Basit bir yetenek seviyesi hesapla (LinkedIn API'den gerçek onay sayısını alamıyoruz)
      double proficiency = 0.7; // Varsayılan değer

      // Deneyim yılı tahmini
      int estimatedYears = 2; // Varsayılan değer

      // İş deneyimlerinden yetenek ile ilgili bilgi çıkarmaya çalış
      if (person.workExperiences != null &&
          person.workExperiences!.isNotEmpty) {
        for (var exp in person.workExperiences!) {
          // Yetenek adı iş tanımında geçiyorsa, deneyim yılını güncelle
          if (exp.description.toLowerCase().contains(skillName.toLowerCase()) ||
              exp.title.toLowerCase().contains(skillName.toLowerCase())) {
            // İş deneyimi süresi hesapla
            final endDate = exp.endDate ?? DateTime.now();
            final duration = endDate.difference(exp.startDate);
            final years = duration.inDays ~/ 365;

            if (years > estimatedYears) {
              estimatedYears = years;
              // Deneyim arttıkça uzmanlık seviyesi de artır
              proficiency = 0.5 + (years * 0.05);
              if (proficiency > 1.0) proficiency = 1.0;
            }
          }
        }
      }

      linkedInSkills.add(Skill(
        name: skillName,
        proficiency: proficiency,
        yearsOfExperience: estimatedYears,
      ));
    }

    return linkedInSkills;
  }
}
