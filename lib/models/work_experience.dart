import 'dart:convert';

class WorkExperience {
  final String title;
  final String company;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> technologies;

  WorkExperience({
    required this.title,
    required this.company,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.technologies,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'description': description,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'technologies': technologies,
    };
  }

  factory WorkExperience.fromMap(Map<String, dynamic> map) {
    return WorkExperience(
      title: map['title'] as String,
      company: map['company'] as String,
      description: map['description'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int)
          : null,
      technologies: List<String>.from(map['technologies'] as List<dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkExperience.fromJson(String source) =>
      WorkExperience.fromMap(json.decode(source) as Map<String, dynamic>);
}
