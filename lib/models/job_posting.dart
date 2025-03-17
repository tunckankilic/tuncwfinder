class JobPosting {
  final String id;
  final String title;
  final String company;
  final String location;
  final List<String> requiredSkills;
  final int requiredYearsExperience;
  final String description;
  final String educationLevel;

  JobPosting({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.requiredSkills,
    required this.requiredYearsExperience,
    required this.description,
    required this.educationLevel,
  });
}
