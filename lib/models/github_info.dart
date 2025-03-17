import 'dart:convert';

class GitHubInfo {
  final int publicRepos;
  final int followers;
  final int following;
  final Map<String, int> languageCounts;
  final int starsCount;
  final int forksCount;
  final DateTime lastActiveDate;

  GitHubInfo({
    required this.publicRepos,
    required this.followers,
    required this.following,
    required this.languageCounts,
    required this.starsCount,
    required this.forksCount,
    required this.lastActiveDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'publicRepos': publicRepos,
      'followers': followers,
      'following': following,
      'languageCounts': languageCounts,
      'starsCount': starsCount,
      'forksCount': forksCount,
      'lastActiveDate': lastActiveDate.millisecondsSinceEpoch,
    };
  }

  factory GitHubInfo.fromMap(Map<String, dynamic> map) {
    return GitHubInfo(
      publicRepos: map['publicRepos'] as int,
      followers: map['followers'] as int,
      following: map['following'] as int,
      languageCounts:
          Map<String, int>.from(map['languageCounts'] as Map<String, dynamic>),
      starsCount: map['starsCount'] as int,
      forksCount: map['forksCount'] as int,
      lastActiveDate:
          DateTime.fromMillisecondsSinceEpoch(map['lastActiveDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory GitHubInfo.fromJson(String source) =>
      GitHubInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}
