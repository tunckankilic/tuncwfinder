import 'dart:convert';

class Project {
  final String title;
  final String description;
  final List<String> technologies;
  final DateTime date;
  final String? url;

  Project({
    required this.title,
    required this.description,
    required this.technologies,
    required this.date,
    this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'technologies': technologies,
      'date': date.millisecondsSinceEpoch,
      'url': url,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      technologies: List<String>.from(map['technologies'] ?? []),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      url: map['url'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Project.fromJson(String source) =>
      Project.fromMap(json.decode(source) as Map<String, dynamic>);
}
