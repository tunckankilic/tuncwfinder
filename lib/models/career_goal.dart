import 'dart:convert';

class CareerGoal {
  final String title;
  final String description;
  final DateTime targetDate;
  final List<String> requiredSkills;
  final List<String> milestones;

  CareerGoal({
    required this.title,
    required this.description,
    required this.targetDate,
    required this.requiredSkills,
    required this.milestones,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'requiredSkills': requiredSkills,
      'milestones': milestones,
    };
  }

  factory CareerGoal.fromMap(Map<String, dynamic> map) {
    return CareerGoal(
      title: map['title'] as String,
      description: map['description'] as String,
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate'] as int),
      requiredSkills: List<String>.from(map['requiredSkills'] as List<dynamic>),
      milestones: List<String>.from(map['milestones'] as List<dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory CareerGoal.fromJson(String source) =>
      CareerGoal.fromMap(json.decode(source) as Map<String, dynamic>);
}
