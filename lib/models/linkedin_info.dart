import 'dart:convert';

class LinkedInInfo {
  final List<String> endorsedSkills;
  final List<String> connections;
  final String? headline;
  final String? summary;
  final List<String> certifications;

  LinkedInInfo({
    required this.endorsedSkills,
    required this.connections,
    this.headline,
    this.summary,
    required this.certifications,
  });

  Map<String, dynamic> toMap() {
    return {
      'endorsedSkills': endorsedSkills,
      'connections': connections,
      'headline': headline,
      'summary': summary,
      'certifications': certifications,
    };
  }

  factory LinkedInInfo.fromMap(Map<String, dynamic> map) {
    return LinkedInInfo(
      endorsedSkills: List<String>.from(map['endorsedSkills'] as List<dynamic>),
      connections: List<String>.from(map['connections'] as List<dynamic>),
      headline: map['headline'] != null ? map['headline'] as String : null,
      summary: map['summary'] != null ? map['summary'] as String : null,
      certifications: List<String>.from(map['certifications'] as List<dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory LinkedInInfo.fromJson(String source) =>
      LinkedInInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}
