import 'dart:convert';

class WorkExperience {
  final String title;
  final String company;
  final String startDate;
  final String? endDate;
  final String? description;
  final List<String> technologies;

  WorkExperience({
    required this.title,
    required this.company,
    required this.startDate,
    this.endDate,
    this.description,
    this.technologies = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'technologies': technologies,
    };
  }

  factory WorkExperience.fromMap(Map<String, dynamic> map) {
    return WorkExperience(
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'],
      description: map['description'],
      technologies: List<String>.from(map['technologies'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkExperience.fromJson(String source) =>
      WorkExperience.fromMap(json.decode(source) as Map<String, dynamic>);
}
