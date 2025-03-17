import 'dart:convert';

class Skill {
  final String name;
  final double proficiency; // 0.0 - 1.0 arasında uzmanlık seviyesi
  final int yearsOfExperience;

  Skill({
    required this.name,
    required this.proficiency,
    required this.yearsOfExperience,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'proficiency': proficiency,
      'yearsOfExperience': yearsOfExperience,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'] as String,
      proficiency: map['proficiency'] as double,
      yearsOfExperience: map['yearsOfExperience'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Skill.fromJson(String source) =>
      Skill.fromMap(json.decode(source) as Map<String, dynamic>);
}
