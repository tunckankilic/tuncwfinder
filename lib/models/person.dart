import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

class Person {
  //personal info
  String? uid;
  String? imageProfile;
  String? email;
  String? password;
  String? name;
  int? age;
  String? phoneNo;
  String? city;
  String? country;
  String? profileHeading;
  int? publishedDateTime;
  String? gender;

  //Appearance
  String? height;
  String? weight;
  String? bodyType;

  //Life style
  String? drink;
  String? smoke;
  String? martialStatus;
  String? haveChildren;
  String? noOfChildren;
  String? profession;
  String? employmentStatus;
  String? income;
  String? livingSituation;
  String? willingToRelocate;

  //Background - Cultural Values
  String? nationality;
  String? education;
  String? languageSpoken;
  String? religion;
  String? ethnicity;

  //Connections
  String? instagramUrl;

  // Kariyer ve beceri entegrasyonu için yeni alanlar
  List<Skill>? skills;
  List<WorkExperience>? workExperiences;
  List<Project>? projects;
  List<String>? educationHistory;
  CareerGoal? careerGoal;
  Map<String, double>?
      skillGaps; // Hedeflenen kariyere göre eksik beceriler ve seviyeleri

  Person({
    //personal info
    //Life style
    //Background - Cultural Values
    this.uid,
    this.imageProfile,
    this.email,
    this.password,
    this.name,
    this.age,
    this.phoneNo,
    this.city,
    this.country,
    this.profileHeading,
    this.publishedDateTime,
    this.gender,
    this.height,
    this.weight,
    this.bodyType,
    this.drink,
    this.smoke,
    this.martialStatus,
    this.haveChildren,
    this.noOfChildren,
    this.profession,
    this.employmentStatus,
    this.income,
    this.livingSituation,
    this.willingToRelocate,
    this.nationality,
    this.education,
    this.languageSpoken,
    this.religion,
    this.ethnicity,
    this.instagramUrl,
    // Yeni alanlar
    this.skills,
    this.workExperiences,
    this.projects,
    this.educationHistory,
    this.careerGoal,
    this.skillGaps,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> baseMap = {
      //personal info
      "uid": uid,
      "imageProfile": imageProfile,
      "email": email,
      "password": password,
      "name": name,
      "age": age,
      "phoneNo": phoneNo,
      "city": city,
      "country": country,
      "profileHeading": profileHeading,
      "publishedDateTime": publishedDateTime,
      "gender": gender,

      //Appearance
      "height": height,
      "weight": weight,
      "bodyType": bodyType,

      //Life style
      "drink": drink,
      "smoke": smoke,
      "martialStatus": martialStatus,
      "haveChildren": haveChildren,
      "noOfChildren": noOfChildren,
      "profession": profession,
      "employmentStatus": employmentStatus,
      "income": income,
      "livingSituation": livingSituation,
      "willingToRelocate": willingToRelocate,

      //Background - Cultural Values
      "nationality": nationality,
      "education": education,
      "languageSpoken": languageSpoken,
      "religion": religion,
      "ethnicity": ethnicity,

      //Connections
      "instagramUrl": instagramUrl,
    };

    // Eğer kariyer ve beceri alanları varsa bunları da ekle
    if (skills != null) {
      baseMap["skills"] = skills!.map((skill) => skill.toMap()).toList();
    }
    if (workExperiences != null) {
      baseMap["workExperiences"] =
          workExperiences!.map((exp) => exp.toMap()).toList();
    }
    if (projects != null) {
      baseMap["projects"] =
          projects!.map((project) => project.toMap()).toList();
    }
    if (educationHistory != null) {
      baseMap["educationHistory"] = educationHistory;
    }
    if (careerGoal != null) {
      baseMap["careerGoal"] = careerGoal!.toMap();
    }
    if (skillGaps != null) {
      baseMap["skillGaps"] = skillGaps;
    }

    return baseMap;
  }

  static Person fromDataSnapshot(DocumentSnapshot snapshot) {
    try {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      log('Parsing document data: $data'); // Debug için

      // Temel alanları doldur
      Person person = Person(
        uid: data['uid'] as String?,
        email: data['email'] as String?,
        imageProfile: data['imageProfile'] as String?,
        name: data['name'] as String?,
        age: data['age'] != null ? int.tryParse(data['age'].toString()) : null,
        phoneNo: data['phoneNo'] as String?,
        city: data['city'] as String?,
        country: data['country'] as String?,
        profileHeading: data['profileHeading'] as String?,
        publishedDateTime: data['publishedDateTime'] as int?,
        gender: data['gender'] as String?,
        height: data['height'] as String?,
        weight: data['weight'] as String?,
        bodyType: data['bodyType'] as String?,
        drink: data['drink'] as String?,
        smoke: data['smoke'] as String?,
        martialStatus: data['martialStatus'] as String?,
        haveChildren: data['haveChildren'] as String?,
        noOfChildren: data['noOfChildren'] as String?,
        profession: data['profession'] as String?,
        employmentStatus: data['employmentStatus'] as String?,
        income: data['income'] as String?,
        livingSituation: data['livingSituation'] as String?,
        willingToRelocate: data['willingToRelocate'] as String?,
        nationality: data['nationality'] as String?,
        education: data['education'] as String?,
        languageSpoken: data['languageSpoken'] as String?,
        religion: data['religion'] as String?,
        ethnicity: data['ethnicity'] as String?,
        instagramUrl: data['instagramUrl'] as String?,
      );

      // Kariyer ve beceri alanlarını doldur (eğer mevcutsa)
      if (data.containsKey('skills') && data['skills'] != null) {
        try {
          final skillsList = data['skills'] as List;
          if (skillsList.isNotEmpty &&
              skillsList.first is Map<String, dynamic>) {
            // Map listesi olarak geliyor (Skill objesi)
            person.skills = skillsList
                .where((item) => item is Map<String, dynamic>)
                .map((skillMap) =>
                    Skill.fromMap(skillMap as Map<String, dynamic>))
                .toList();
          } else if (skillsList.isNotEmpty && skillsList.first is String) {
            // String listesi olarak geliyor, Skill objelerine dönüştür
            person.skills = skillsList
                .where((item) => item is String)
                .map((skillName) => Skill(
                      name: skillName as String,
                      proficiency: 0.5, // Varsayılan değer
                      yearsOfExperience: 1, // Varsayılan değer
                    ))
                .toList();
          } else {
            person.skills = [];
          }
        } catch (e) {
          print('Error parsing skills: $e');
          person.skills = [];
        }
      }

      if (data.containsKey('workExperiences') &&
          data['workExperiences'] != null) {
        try {
          final workExpList = data['workExperiences'] as List;
          person.workExperiences = workExpList
              .where((item) => item is Map<String, dynamic>)
              .map((expMap) {
                try {
                  return WorkExperience.fromMap(expMap as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing work experience: $e');
                  print('Data: $expMap');
                  return null;
                }
              })
              .where((exp) => exp != null)
              .cast<WorkExperience>()
              .toList();
        } catch (e) {
          print('Error parsing work experiences: $e');
          person.workExperiences = [];
        }
      }

      if (data.containsKey('projects') && data['projects'] != null) {
        try {
          final projectsList = data['projects'] as List;
          person.projects = projectsList
              .where((item) => item is Map<String, dynamic>)
              .map((projectMap) =>
                  Project.fromMap(projectMap as Map<String, dynamic>))
              .toList();
        } catch (e) {
          print('Error parsing projects: $e');
          person.projects = [];
        }
      }

      if (data.containsKey('educationHistory') &&
          data['educationHistory'] != null) {
        try {
          final educationList = data['educationHistory'] as List;
          person.educationHistory = educationList
              .where((item) => item is String)
              .map((item) => item as String)
              .toList();
        } catch (e) {
          print('Error parsing education history: $e');
          person.educationHistory = [];
        }
      }

      if (data.containsKey('careerGoal') && data['careerGoal'] != null) {
        try {
          if (data['careerGoal'] is Map<String, dynamic>) {
            person.careerGoal =
                CareerGoal.fromMap(data['careerGoal'] as Map<String, dynamic>);
          }
        } catch (e) {
          print('Error parsing career goal: $e');
        }
      }

      if (data.containsKey('skillGaps') && data['skillGaps'] != null) {
        try {
          if (data['skillGaps'] is Map<String, dynamic>) {
            person.skillGaps = Map<String, double>.from(
                data['skillGaps'] as Map<String, dynamic>);
          }
        } catch (e) {
          print('Error parsing skill gaps: $e');
        }
      }

      return person;
    } catch (e) {
      log('Error in fromDataSnapshot: $e');
      rethrow;
    }
  }

  Person copyWith({
    String? uid,
    String? imageProfile,
    String? email,
    String? password,
    String? name,
    int? age,
    String? phoneNo,
    String? city,
    String? country,
    String? profileHeading,
    String? lookingForInaPartner,
    int? publishedDateTime,
    String? gender,
    String? height,
    String? weight,
    String? bodyType,
    String? drink,
    String? smoke,
    String? martialStatus,
    String? haveChildren,
    String? noOfChildren,
    String? profession,
    String? employmentStatus,
    String? income,
    String? livingSituation,
    String? willingToRelocate,
    String? nationality,
    String? education,
    String? languageSpoken,
    String? religion,
    String? ethnicity,
    String? instagramUrl,
    List<Skill>? skills,
    List<WorkExperience>? workExperiences,
    List<Project>? projects,
    List<String>? educationHistory,
    CareerGoal? careerGoal,
    Map<String, double>? skillGaps,
  }) {
    return Person(
      uid: uid ?? this.uid,
      imageProfile: imageProfile ?? this.imageProfile,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      age: age ?? this.age,
      phoneNo: phoneNo ?? this.phoneNo,
      city: city ?? this.city,
      country: country ?? this.country,
      profileHeading: profileHeading ?? this.profileHeading,
      publishedDateTime: publishedDateTime ?? this.publishedDateTime,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bodyType: bodyType ?? this.bodyType,
      drink: drink ?? this.drink,
      smoke: smoke ?? this.smoke,
      martialStatus: martialStatus ?? this.martialStatus,
      haveChildren: haveChildren ?? this.haveChildren,
      noOfChildren: noOfChildren ?? this.noOfChildren,
      profession: profession ?? this.profession,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      income: income ?? this.income,
      livingSituation: livingSituation ?? this.livingSituation,
      willingToRelocate: willingToRelocate ?? this.willingToRelocate,
      nationality: nationality ?? this.nationality,
      education: education ?? this.education,
      languageSpoken: languageSpoken ?? this.languageSpoken,
      religion: religion ?? this.religion,
      ethnicity: ethnicity ?? this.ethnicity,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      skills: skills ?? this.skills,
      workExperiences: workExperiences ?? this.workExperiences,
      projects: projects ?? this.projects,
      educationHistory: educationHistory ?? this.educationHistory,
      careerGoal: careerGoal ?? this.careerGoal,
      skillGaps: skillGaps ?? this.skillGaps,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> baseMap = <String, dynamic>{
      'uid': uid,
      'imageProfile': imageProfile,
      'email': email,
      'password': password,
      'name': name,
      'age': age,
      'phoneNo': phoneNo,
      'city': city,
      'country': country,
      'profileHeading': profileHeading,
      'publishedDateTime': publishedDateTime,
      'gender': gender,
      'height': height,
      'weight': weight,
      'bodyType': bodyType,
      'drink': drink,
      'smoke': smoke,
      'martialStatus': martialStatus,
      'haveChildren': haveChildren,
      'noOfChildren': noOfChildren,
      'profession': profession,
      'employmentStatus': employmentStatus,
      'income': income,
      'livingSituation': livingSituation,
      'willingToRelocate': willingToRelocate,
      'nationality': nationality,
      'education': education,
      'languageSpoken': languageSpoken,
      'religion': religion,
      'ethnicity': ethnicity,
      'instagramUrl': instagramUrl,
    };

    // Kariyer ve beceri alanlarını ekle
    if (skills != null) {
      baseMap['skills'] = skills!.map((skill) => skill.toMap()).toList();
    }
    if (workExperiences != null) {
      baseMap['workExperiences'] =
          workExperiences!.map((exp) => exp.toMap()).toList();
    }
    if (projects != null) {
      baseMap['projects'] =
          projects!.map((project) => project.toMap()).toList();
    }
    if (educationHistory != null) {
      baseMap['educationHistory'] = educationHistory;
    }
    if (careerGoal != null) {
      baseMap['careerGoal'] = careerGoal!.toMap();
    }
    if (skillGaps != null) {
      baseMap['skillGaps'] = skillGaps;
    }

    return baseMap;
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    Person person = Person(
      uid: map['uid'] != null ? map['uid'] as String : null,
      imageProfile:
          map['imageProfile'] != null ? map['imageProfile'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      age: map['age'] != null ? map['age'] as int : null,
      phoneNo: map['phoneNo'] != null ? map['phoneNo'] as String : null,
      city: map['city'] != null ? map['city'] as String : null,
      country: map['country'] != null ? map['country'] as String : null,
      profileHeading: map['profileHeading'] != null
          ? map['profileHeading'] as String
          : null,
      publishedDateTime: map['publishedDateTime'] != null
          ? map['publishedDateTime'] as int
          : null,
      gender: map['gender'] != null ? map['gender'] as String : null,
      height: map['height'] != null ? map['height'] as String : null,
      weight: map['weight'] != null ? map['weight'] as String : null,
      bodyType: map['bodyType'] != null ? map['bodyType'] as String : null,
      drink: map['drink'] != null ? map['drink'] as String : null,
      smoke: map['smoke'] != null ? map['smoke'] as String : null,
      martialStatus:
          map['martialStatus'] != null ? map['martialStatus'] as String : null,
      haveChildren:
          map['haveChildren'] != null ? map['haveChildren'] as String : null,
      noOfChildren:
          map['noOfChildren'] != null ? map['noOfChildren'] as String : null,
      profession:
          map['profession'] != null ? map['profession'] as String : null,
      employmentStatus: map['employmentStatus'] != null
          ? map['employmentStatus'] as String
          : null,
      income: map['income'] != null ? map['income'] as String : null,
      livingSituation: map['livingSituation'] != null
          ? map['livingSituation'] as String
          : null,
      willingToRelocate: map['willingToRelocate'] != null
          ? map['willingToRelocate'] as String
          : null,
      nationality:
          map['nationality'] != null ? map['nationality'] as String : null,
      education: map['education'] != null ? map['education'] as String : null,
      languageSpoken: map['languageSpoken'] != null
          ? map['languageSpoken'] as String
          : null,
      religion: map['religion'] != null ? map['religion'] as String : null,
      ethnicity: map['ethnicity'] != null ? map['ethnicity'] as String : null,
      instagramUrl:
          map['instagramUrl'] != null ? map['instagramUrl'] as String : null,
    );

    // Kariyer ve beceri alanlarını ekle
    if (map.containsKey('skills') && map['skills'] != null) {
      final skillsData = map['skills'] as List;
      if (skillsData.isNotEmpty && skillsData.first is Map<String, dynamic>) {
        // Map listesi olarak geliyor (Skill objesi)
        person.skills = skillsData
            .map((skillMap) => Skill.fromMap(skillMap as Map<String, dynamic>))
            .toList();
      } else if (skillsData.isNotEmpty && skillsData.first is String) {
        // String listesi olarak geliyor, Skill objelerine dönüştür
        person.skills = skillsData
            .map((skillName) => Skill(
                  name: skillName as String,
                  proficiency: 0.5, // Varsayılan değer
                  yearsOfExperience: 1, // Varsayılan değer
                ))
            .toList();
      } else {
        person.skills = [];
      }
    }

    if (map.containsKey('workExperiences') && map['workExperiences'] != null) {
      try {
        final workExpList = map['workExperiences'] as List;
        person.workExperiences = workExpList
            .where((item) => item is Map<String, dynamic>)
            .map((expMap) {
              try {
                return WorkExperience.fromMap(expMap as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing work experience in fromMap: $e');
                print('Data: $expMap');
                return null;
              }
            })
            .where((exp) => exp != null)
            .cast<WorkExperience>()
            .toList();
      } catch (e) {
        print('Error parsing work experiences in fromMap: $e');
        person.workExperiences = [];
      }
    }

    if (map.containsKey('projects') && map['projects'] != null) {
      person.projects = (map['projects'] as List)
          .map((projectMap) =>
              Project.fromMap(projectMap as Map<String, dynamic>))
          .toList();
    }
    if (map.containsKey('educationHistory') &&
        map['educationHistory'] != null) {
      person.educationHistory =
          List<String>.from(map['educationHistory'] as List<dynamic>);
    }

    if (map.containsKey('careerGoal') && map['careerGoal'] != null) {
      person.careerGoal =
          CareerGoal.fromMap(map['careerGoal'] as Map<String, dynamic>);
    }

    if (map.containsKey('skillGaps') && map['skillGaps'] != null) {
      person.skillGaps =
          Map<String, double>.from(map['skillGaps'] as Map<String, dynamic>);
    }

    return person;
  }

  factory Person.fromJson(String source) =>
      Person.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Person(uid: $uid, imageProfile: $imageProfile, email: $email, password: $password, name: $name, age: $age, phoneNo: $phoneNo, city: $city, country: $country, profileHeading: $profileHeading, publishedDateTime: $publishedDateTime, gender: $gender, height: $height, weight: $weight, bodyType: $bodyType, drink: $drink, smoke: $smoke, martialStatus: $martialStatus, haveChildren: $haveChildren, noOfChildren: $noOfChildren, profession: $profession, employmentStatus: $employmentStatus, income: $income, livingSituation: $livingSituation, willingToRelocate: $willingToRelocate, nationality: $nationality, education: $education, languageSpoken: $languageSpoken, religion: $religion, ethnicity: $ethnicity, instagramUrl: $instagramUrl, skills: $skills, workExperiences: $workExperiences, projects: $projects, educationHistory: $educationHistory, careerGoal: $careerGoal, skillGaps: $skillGaps)';
  }

  @override
  bool operator ==(covariant Person other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.imageProfile == imageProfile &&
        other.email == email &&
        other.password == password &&
        other.name == name &&
        other.age == age &&
        other.phoneNo == phoneNo &&
        other.city == city &&
        other.country == country &&
        other.profileHeading == profileHeading &&
        other.publishedDateTime == publishedDateTime &&
        other.gender == gender &&
        other.height == height &&
        other.weight == weight &&
        other.bodyType == bodyType &&
        other.drink == drink &&
        other.smoke == smoke &&
        other.martialStatus == martialStatus &&
        other.haveChildren == haveChildren &&
        other.noOfChildren == noOfChildren &&
        other.profession == profession &&
        other.employmentStatus == employmentStatus &&
        other.income == income &&
        other.livingSituation == livingSituation &&
        other.willingToRelocate == willingToRelocate &&
        other.nationality == nationality &&
        other.education == education &&
        other.languageSpoken == languageSpoken &&
        other.religion == religion &&
        other.ethnicity == ethnicity &&
        other.instagramUrl == instagramUrl &&
        other.skills.toString() == skills.toString() &&
        other.workExperiences.toString() == workExperiences.toString() &&
        other.projects.toString() == projects.toString() &&
        other.educationHistory.toString() == educationHistory.toString() &&
        other.careerGoal.toString() == careerGoal.toString() &&
        other.skillGaps.toString() == skillGaps.toString();
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        imageProfile.hashCode ^
        email.hashCode ^
        password.hashCode ^
        name.hashCode ^
        age.hashCode ^
        phoneNo.hashCode ^
        city.hashCode ^
        country.hashCode ^
        profileHeading.hashCode ^
        publishedDateTime.hashCode ^
        gender.hashCode ^
        height.hashCode ^
        weight.hashCode ^
        bodyType.hashCode ^
        drink.hashCode ^
        smoke.hashCode ^
        martialStatus.hashCode ^
        haveChildren.hashCode ^
        noOfChildren.hashCode ^
        profession.hashCode ^
        employmentStatus.hashCode ^
        income.hashCode ^
        livingSituation.hashCode ^
        willingToRelocate.hashCode ^
        nationality.hashCode ^
        education.hashCode ^
        languageSpoken.hashCode ^
        religion.hashCode ^
        ethnicity.hashCode ^
        instagramUrl.hashCode ^
        skills.hashCode ^
        workExperiences.hashCode ^
        projects.hashCode ^
        educationHistory.hashCode ^
        careerGoal.hashCode ^
        skillGaps.hashCode;
  }
}
