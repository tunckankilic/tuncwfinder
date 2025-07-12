import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:tuncforwork/constants/app_strings.dart';

// Firestore instance
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Dropdown değerlerini almak için metodlar
Future<List<String>> getDropdownValues(String collectionName) async {
  try {
    log(AppStrings.logInitialized.replaceAll('{}', collectionName));
    final snapshot = await _firestore.collection(collectionName).get();

    if (snapshot.docs.isEmpty) {
      log(AppStrings.logCollectionEmpty.replaceAll('{}', collectionName));
      return [];
    }

    final values = snapshot.docs
        .map((doc) => doc.data()['value'] as String?)
        .where((value) => value != null)
        .cast<String>()
        .toList();

    log(AppStrings.logValuesFound
        .replaceAll('{}', collectionName)
        .replaceAll('{}', values.length.toString()));
    return values;
  } catch (e, stackTrace) {
    log(AppStrings.logGeneralError
        .replaceAll('{}', collectionName)
        .replaceAll('{}', e.toString()));
    log(AppStrings.logStackTrace.replaceAll('{}', stackTrace.toString()));
    return [];
  }
}

Future<Map<String, List<String>>> getAllDropdownValues() async {
  try {
    log(AppStrings.logInitialized.replaceAll('{}', 'getAllDropdownValues'));
    final collections = [
      'genders',
      'countries',
      'bodyTypes',
      'drinkingHabits',
      'smokingHabits',
      'maritalStatuses',
      'employmentStatuses',
      'livingSituations',
      'nationalities',
      'educationLevels',
      'languages',
      'religions',
      'ethnicities',
      'professions',
      'industries',
    ];

    Map<String, List<String>> values = {};

    for (var collection in collections) {
      try {
        log(AppStrings.logLoadingCollection.replaceAll('{}', collection));
        final collectionValues = await getDropdownValues(collection);
        if (collectionValues.isNotEmpty) {
          values[collection] = collectionValues;
          log(AppStrings.logCollectionLoaded
              .replaceAll('{}', collection)
              .replaceAll('{}', collectionValues.length.toString()));
        } else {
          log(AppStrings.logCollectionEmpty.replaceAll('{}', collection));
        }
      } catch (e) {
        log(AppStrings.logGeneralError
            .replaceAll('{}', collection)
            .replaceAll('{}', e.toString()));
      }
    }

    if (values.isEmpty) {
      log(AppStrings.logNoDropdownValues);
    } else {
      log(AppStrings.logTotalCollections
          .replaceAll('{}', values.length.toString()));
    }

    return values;
  } catch (e, stackTrace) {
    log(AppStrings.logAllDropdownValuesError.replaceAll('{}', e.toString()));
    log(AppStrings.logStackTrace.replaceAll('{}', stackTrace.toString()));
    return {};
  }
}

// Global Variables
String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
String fcmServerToken = dotenv.env['FCM_SERVER_TOKEN'] ?? '';
String? chosenAge;
String? chosenCountry;
String? chosenGender;

// Programming and Technical Skills
const List<String> programmingLanguages = [
  'JavaScript',
  'Python',
  'Java',
  'C#',
  'C++',
  'Ruby',
  'PHP',
  'Swift',
  'Kotlin',
  'Go',
  'Rust',
  'TypeScript',
  'Dart',
  'Other'
];

const List<String> frameworks = [
  'React',
  'Angular',
  'Vue.js',
  'Node.js',
  'Django',
  'Flask',
  'Spring',
  'ASP.NET',
  'Laravel',
  'Flutter',
  'React Native',
  'TensorFlow',
  'PyTorch',
  'Docker',
  'Kubernetes',
  'AWS',
  'Azure',
  'GCP',
  'Other'
];

const List<String> databases = [
  'MySQL',
  'PostgreSQL',
  'MongoDB',
  'SQLite',
  'Oracle',
  'SQL Server',
  'Redis',
  'Cassandra',
  'Firebase',
  'Other'
];

const List<String> skillLevels = [
  'Beginner',
  'Intermediate',
  'Advanced',
  'Expert'
];

const List<String> languageLevels = [
  'Native',
  'Fluent',
  'Advanced',
  'Intermediate',
  'Basic'
];

// Personal Information Options
final List<String> gender = [
  'Woman',
  'Man',
  'Transgender',
  'Non-binary',
  'Genderqueer',
  'Gender fluid',
  'Agender',
  'Bigender',
  'Two-Spirit',
  'Androgynous',
  'Demigender',
  'Gender non-conforming',
  'Questioning',
  'Prefer not to say',
  'Other (self-describe)',
];

final List<String> bodyTypes = [
  'Slim',
  'Athletic',
  'Average',
  'Curvy',
  'Muscular',
  'A few extra pounds',
  'Heavyset',
  'Stocky',
  'Petite',
  'Tall',
  'Short',
];

final List<String> smokingHabits = [
  'Non-smoker',
  'Light smoker',
  'Regular smoker',
  'Heavy smoker',
  'Trying to quit',
  'Former smoker',
  'Social smoker',
  'Vaper',
  'Cigar smoker',
  'Pipe smoker',
];

final List<String> drinkingHabits = [
  'Non-drinker',
  'Social drinker',
  'Light drinker',
  'Moderate drinker',
  'Heavy drinker',
  'Recovering alcoholic',
  'Occasional drinker',
  'Drink on special occasions only',
  'Beer enthusiast',
  'Wine connoisseur',
  'Cocktail lover',
];

final List<String> maritalStatuses = [
  'Single (never married)',
  'Married',
  'Divorced',
  'Widowed',
  'Separated',
  'Domestic partnership',
  'Civil union',
  'Engaged',
  'Cohabiting',
  'Common-law marriage',
  'Remarried',
  'Annulled',
  'Single (divorced)',
  'Single (widowed)',
  'Legally separated',
  'Married (living apart)',
  'Married (same-sex)',
  'Registered partnership',
  'In a relationship',
  'It\'s complicated',
];

// Location and Demographics
final List<String> countries = [
  'Belize',
  'Canada',
  'Costa Rica',
  'El Salvador',
  'Guatemala',
  'Honduras',
  'Mexico',
  'Nicaragua',
  'Panama',
  'United States',
  'Albania',
  'Andorra',
  'Austria',
  'Belarus',
  'Belgium',
  'Bosnia and Herzegovina',
  'Bulgaria',
  'Croatia',
  'Czech Republic',
  'Denmark',
  'Estonia',
  'Finland',
  'France',
  'Germany',
  'Greece',
  'Hungary',
  'Iceland',
  'Ireland',
  'Italy',
  'Kosovo',
  'Latvia',
  'Liechtenstein',
  'Lithuania',
  'Luxembourg',
  'Malta',
  'Moldova',
  'Monaco',
  'Montenegro',
  'Netherlands',
  'North Macedonia',
  'Norway',
  'Poland',
  'Portugal',
  'Romania',
  'Russia',
  'San Marino',
  'Serbia',
  'Slovakia',
  'Slovenia',
  'Spain',
  'Sweden',
  'Switzerland',
  'Ukraine',
  'United Kingdom',
  'Vatican City',
  'Bahrain',
  'Cyprus',
  'Egypt',
  'Iran',
  'Iraq',
  'Israel',
  'Jordan',
  'Kuwait',
  'Lebanon',
  'Oman',
  'Palestine',
  'Qatar',
  'Saudi Arabia',
  'Syria',
  'Turkey',
  'United Arab Emirates',
  'Yemen',
];

final List<String> nationalities = [
  'American',
  'British',
  'Canadian',
  'French',
  'German',
  'Italian',
  'Spanish',
  'Chinese',
  'Japanese',
  'Russian',
  'Brazilian',
  'Mexican',
  'Indian',
  'Australian',
  'Egyptian',
  'Nigerian',
  'South African',
  'Swedish',
  'Dutch',
  'Turkish',
];

final List<String> ethnicities = [
  'Han Chinese',
  'Arabs',
  'Bengalis',
  'Hispanics',
  'Punjabis',
  'Yoruba',
  'Javanese',
  'Japanese',
  'Korean',
  'Vietnamese',
  'Ashkenazi Jews',
  'Hausa',
  'Gujarati',
  'Telugu',
  'Tamil',
  'Italians',
  'Turks',
  'Persians',
  'Pashtuns',
  'Fulani',
  'Igbo',
  'Oromo',
  'Azeri',
  'Malay',
  'Sundanese',
];

// Education and Work
final List<String> educationLevels = [
  'High School',
  'Bachelor\'s',
  'Master\'s',
  'Doctorate',
  'Other'
];

final List<String> languages = [
  'English',
  'Spanish',
  'French',
  'German',
  'Italian',
  'Polish',
  'Ukrainian',
  'Dutch',
  'Romanian',
  'Greek',
  'Chinese',
  'Tagalog',
  'Vietnamese',
  'Korean',
  'Arabic',
];

final List<String> employmentStatuses = [
  "Employment Statuses",
  'Full-time employed',
  'Part-time employed',
  'Self-employed',
  'Freelancer',
  'Contractor',
  'Unemployed (seeking work)',
  'Unemployed (not seeking work)',
  'Student',
  'Retired',
  'Homemaker',
  'Internship',
  'Apprenticeship',
  'Temporarily laid off',
  'On leave (e.g., maternity, medical)',
  'Seasonal worker',
  'Gig worker',
  'Remote worker',
  'Hybrid worker (part remote, part in-office)',
  'Business owner',
  'Volunteer',
  'Disabled (unable to work)',
  'Underemployed',
  'Multiple jobs',
  'Zero-hour contract',
  'Job-sharing',
];

final List<String> itJobs = [
  "Profession",
  // IT and Technical Roles
  'Software Developer',
  'Data Scientist',
  'Cybersecurity Specialist',
  'Network Administrator',
  'System Administrator',
  'Cloud Architect',
  'DevOps Engineer',
  'Artificial Intelligence Engineer',
  'Mobile App Developer',
  'Web Developer',
  'Database Administrator',
  'UI/UX Designer',
  'QA Test Engineer',
  'Game Developer',
  'Blockchain Developer',
  'Technical Support Specialist',

  // IT Management Roles
  'IT Project Manager',
  'Chief Information Officer (CIO)',
  'Chief Technology Officer (CTO)',
  'IT Director',
  'Product Manager',
  'Scrum Master',
  'IT Business Analyst',

  // Human Resources Department
  'HR Manager',
  'Recruitment Specialist',
  'Training and Development Coordinator',
  'Compensation and Benefits Analyst',
  'Employee Relations Specialist',
  'HR Business Partner',
  'Talent Acquisition Manager',

  // Finance Department
  'Chief Financial Officer (CFO)',
  'Financial Analyst',
  'Accountant',
  'Financial Controller',
  'Payroll Specialist',
  'Tax Manager',
  'Internal Auditor',

  // Marketing Department
  'Chief Marketing Officer (CMO)',
  'Marketing Manager',
  'Digital Marketing Specialist',
  'Content Creator',
  'Brand Manager',
  'Social Media Coordinator',
  'Market Research Analyst',

  // Sales Department
  'Sales Director',
  'Account Manager',
  'Sales Representative',
  'Business Development Manager',
  'Customer Success Manager',

  // Operations Department
  'Chief Operating Officer (COO)',
  'Operations Manager',
  'Supply Chain Manager',
  'Logistics Coordinator',
  'Quality Assurance Manager',

  // Legal Department
  'General Counsel',
  'Legal Advisor',
  'Compliance Officer',
  'Intellectual Property Specialist',
];

final List<String> livingSituations = [
  "Living Situations",
  'Single-family home',
  'Apartment',
  'Shared house/flat',
  'Studio apartment',
  'Dormitory',
  'With parents',
  'Multigenerational household',
  'Retirement community',
  'Homeless shelter',
  'Temporary housing',
  'Mobile home',
  'Boat house',
  'Van life',
  'Co-living space',
  'Tiny house',
  'Assisted living facility',
  'Boarding house',
  'Commune',
  'Group home',
  'Homeless (street living)',
  'Hotel/motel long-term',
  'Squat',
  'Eco-village',
  'Military barracks',
  'Off-grid living',
];

final List<String> religion = [
  "Christianity",
  "Islam",
  "Hinduism",
  "Buddhism",
  "Judaism",
  "Other",
  "None"
];

// Legal Documents
final String eula = '''
   End User License Agreement (EULA)
Last updated: November 12, 2024
1. Introduction
This End User License Agreement ("Agreement" or "EULA") is a legal agreement between you ("User", "you", or "your") and TuncForWork ("we", "us", "our", or "Company") for the use of the TuncForWork mobile application ("App").
2. Acceptance of Terms
By downloading, installing, or using the App, you agree to be bound by this Agreement. If you do not agree to these terms, do not use the App.
3. License Grant
Subject to your compliance with this Agreement, we grant you a limited, non-exclusive, non-transferable, revocable license to use the App for your personal, non-commercial purposes.
4. User Registration and Account Security
4.1. You must be at least 18 years old to use the App.
4.2. You are responsible for maintaining the confidentiality of your account credentials.
4.3. You agree to provide accurate, current, and complete information during registration.
4.4. You are solely responsible for all activities that occur under your account.
5. User Content and Conduct
5.1. You retain ownership of content you submit to the App.
5.2. You grant us a worldwide, non-exclusive license to use, modify, and display your content.
5.3. You agree not to:

Post illegal, harmful, or offensive content
Impersonate others
Use the App for unauthorized commercial purposes
Attempt to bypass security measures
Share malware or viruses

6. Privacy
6.1. Our Privacy Policy explains how we collect, use, and protect your information.
6.2. By using the App, you consent to our privacy practices.
7. Data Usage and Storage
7.1. The App requires access to:

Camera and photo library
Location services
Push notifications
Network connectivity
7.2. You are responsible for any data charges incurred while using the App.

8. Intellectual Property Rights
8.1. All rights, title, and interest in the App remain with us.
8.2. You may not:

Modify or create derivative works
Reverse engineer the App
Remove copyright notices
Use branding without permission

9. Termination
9.1. We may terminate your access to the App at any time for violations of this Agreement.
9.2. You may terminate this Agreement by uninstalling the App.
10. Disclaimer of Warranties
THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND.
11. Limitation of Liability
WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES.
12. Changes to Agreement
We reserve the right to modify this Agreement at any time.
13. Governing Law
This Agreement is governed by the laws of [Your Jurisdiction].
  ''';

final String privacyPolicy = '''
   TuncForWork Privacy
TuncWFinder Privacy Policy
Last updated: 19/08/2024
This privacy policy explains how information is collected, used, protected, and disclosed during the use of the TuncWFinder application. By using the application, you agree to the practices described in this policy.
1. Information Collected
The application may collect the following information:

Camera and photo library access: For taking profile pictures and sharing content
Microphone access: For voice messages and video recordings
Apple Music access: For using music features (when necessary)
Notification permissions: For sending important updates and information

2. Use of Information
The collected information is used for the following purposes:

To provide and improve application functionality
To personalize user experience
To troubleshoot technical issues and analyze application performance
To comply with legal obligations

3. Information Sharing
User information is not shared with third parties except in the following circumstances:

When the user gives explicit permission
When there is a legal obligation
When necessary to protect the rights of the application

4. Data Security
Appropriate technical and organizational measures are taken to ensure the security of user information. However, please note that transmission methods over the internet or electronic storage are not 100% secure.
5. Children's Privacy
The application does not knowingly collect personal information from children under 13 years of age. If you are a parent or guardian and believe that your child has provided us with personal information, please contact us.
6. Changes to This Policy
This privacy policy may be updated from time to time. Changes will be posted on this page, and users will be notified in case of significant changes.
7. Contact
If you have any questions about this privacy policy, please contact us at:
email: ismail.tunc.kankilic@gmail.com
By accepting this privacy policy, you declare that you understand and agree to the terms stated herein.
  ''';
