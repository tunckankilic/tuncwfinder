import 'package:flutter/material.dart';
import 'package:tuncforwork/models/job_posting.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/service/skill_matching.dart';

class JobMatchingScreen extends StatelessWidget {
  final Person userProfile;
  final List<JobPosting> jobs;

  JobMatchingScreen({required this.userProfile, required this.jobs});

  @override
  Widget build(BuildContext context) {
    final matchingService = SkillMatchingService();
    final matches = matchingService.matchJobsToUser(userProfile, jobs);

    return Scaffold(
      appBar: AppBar(
        title: Text('İş Eşleşmeleri'),
      ),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          final job = match['job'] as JobPosting;
          final score = match['score'] as double;
          final reason = match['matchReason'] as String;

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getScoreColor(score),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${score.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('${job.company} • ${job.location}'),
                  SizedBox(height: 12),
                  Text(
                    reason,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.requiredSkills.map((skill) {
                      bool hasSkill = userProfile.skills?.any((userSkill) =>
                              userSkill.name.toLowerCase() ==
                              skill.toLowerCase()) ??
                          false;

                      return Chip(
                        label: Text(skill),
                        backgroundColor:
                            hasSkill ? Colors.green[100] : Colors.grey[200],
                        labelStyle: TextStyle(
                          color:
                              hasSkill ? Colors.green[800] : Colors.grey[800],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
