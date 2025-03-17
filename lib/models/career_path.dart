import 'package:tuncforwork/models/career_stage.dart';

class CareerPath {
  final String id;
  final String title;
  final String description;
  final List<CareerStage> stages;
  final List<String> requiredSkills;
  final double averageSalary;
  final String demandLevel; // "Yüksek", "Orta", "Düşük"
  final String growthRate; // "Hızlı", "Orta", "Yavaş"

  CareerPath({
    required this.id,
    required this.title,
    required this.description,
    required this.stages,
    required this.requiredSkills,
    required this.averageSalary,
    required this.demandLevel,
    required this.growthRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'stages': stages.map((stage) => stage.toMap()).toList(),
      'requiredSkills': requiredSkills,
      'averageSalary': averageSalary,
      'demandLevel': demandLevel,
      'growthRate': growthRate,
    };
  }

  factory CareerPath.fromMap(Map<String, dynamic> map) {
    return CareerPath(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      stages: (map['stages'] as List<dynamic>)
          .map((e) => CareerStage.fromMap(e as Map<String, dynamic>))
          .toList(),
      requiredSkills: List<String>.from(map['requiredSkills'] as List<dynamic>),
      averageSalary: map['averageSalary'] as double,
      demandLevel: map['demandLevel'] as String,
      growthRate: map['growthRate'] as String,
    );
  }
}
