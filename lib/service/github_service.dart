import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GitHubService {
  final String baseUrl = 'https://api.github.com';
  String? accessToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('github_token');
  }

  Future<Map<String, dynamic>> getUserProfile(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username'),
      headers: {
        if (accessToken != null) 'Authorization': 'token $accessToken',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'GitHub profil bilgileri alınamadı: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getUserRepositories(
      String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username/repos?per_page=100'),
      headers: {
        if (accessToken != null) 'Authorization': 'token $accessToken',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('GitHub repoları alınamadı: ${response.statusCode}');
    }
  }

  Future<Map<String, int>> analyzeLanguages(
      List<Map<String, dynamic>> repositories) async {
    final Map<String, int> languageCounts = {};

    for (var repo in repositories) {
      final String? language = repo['language'];
      if (language != null) {
        languageCounts[language] = (languageCounts[language] ?? 0) + 1;
      }
    }

    return languageCounts;
  }

  Future<Map<String, dynamic>> analyzeGitHubProfile(String username) async {
    final profile = await getUserProfile(username);
    final repositories = await getUserRepositories(username);
    final languageCounts = await analyzeLanguages(repositories);

    return {
      'profile': profile,
      'repo_count': repositories.length,
      'languages': languageCounts,
      'stars_count': repositories.fold<int>(
          0, (sum, repo) => sum + ((repo['stargazers_count'] ?? 0) as int)),
      'fork_count': repositories.fold<int>(
          0, (sum, repo) => sum + ((repo['forks_count'] ?? 0) as int)),
    };
  }
}

class GitHubAnalysisScreen extends StatefulWidget {
  final String username;

  const GitHubAnalysisScreen({Key? key, required this.username})
      : super(key: key);

  @override
  _GitHubAnalysisScreenState createState() => _GitHubAnalysisScreenState();
}

class _GitHubAnalysisScreenState extends State<GitHubAnalysisScreen> {
  final GitHubService _gitHubService = GitHubService();
  Future<Map<String, dynamic>>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _gitHubService.init().then((_) {
      setState(() {
        _profileFuture = _gitHubService.analyzeGitHubProfile(widget.username);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Analizi: ${widget.username}'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final profile = data['profile'];
            final languages = data['languages'] as Map<String, int>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(profile['avatar_url']),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['name'] ?? widget.username,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(profile['bio'] ?? 'Bio bilgisi yok'),
                            Text('Takipçiler: ${profile['followers']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Repo İstatistikleri',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('Toplam Repo: ${data['repo_count']}'),
                          Text('Toplam Yıldız: ${data['stars_count']}'),
                          Text('Toplam Fork: ${data['fork_count']}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dil Dağılımı',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          ...languages.entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(entry.key)),
                                        Text('${entry.value} repo'),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Veri bulunamadı'));
        },
      ),
    );
  }
}
