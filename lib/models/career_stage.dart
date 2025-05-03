import 'models.dart';

class CareerStage {
  final String title;
  final String description;
  final List<String> requiredSkills;
  final List<LearningResource> recommendedResources;
  final double averageSalary;
  final int yearsOfExperience;

  CareerStage({
    required this.title,
    required this.description,
    required this.requiredSkills,
    required this.recommendedResources,
    required this.averageSalary,
    required this.yearsOfExperience,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'requiredSkills': requiredSkills,
      'recommendedResources':
          recommendedResources.map((resource) => resource.toMap()).toList(),
      'averageSalary': averageSalary,
      'yearsOfExperience': yearsOfExperience,
    };
  }

  factory CareerStage.fromMap(Map<String, dynamic> map) {
    return CareerStage(
      title: map['title'] as String,
      description: map['description'] as String,
      requiredSkills: List<String>.from(map['requiredSkills'] as List<dynamic>),
      recommendedResources: (map['recommendedResources'] as List<dynamic>)
          .map((e) => LearningResource.fromMap(e as Map<String, dynamic>))
          .toList(),
      averageSalary: map['averageSalary'] as double,
      yearsOfExperience: map['yearsOfExperience'] as int,
    );
  }
}
