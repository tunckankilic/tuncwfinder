import 'dart:convert';

class Project {
  final String title;
  final String description;
  final String? url;
  final List<String> technologies;
  final DateTime date;

  Project({
    required this.title,
    required this.description,
    this.url,
    required this.technologies,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'technologies': technologies,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      title: map['title'] as String,
      description: map['description'] as String,
      url: map['url'] != null ? map['url'] as String : null,
      technologies: List<String>.from(map['technologies'] as List<dynamic>),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Project.fromJson(String source) =>
      Project.fromMap(json.decode(source) as Map<String, dynamic>);
}
