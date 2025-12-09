import 'package:flutter_test/flutter_test.dart';
import 'package:tuncforwork/models/models.dart';

void main() {
  group('Person Model - Constructor', () {
    test('creates person with all fields', () {
      // Act
      final person = Person(
        uid: 'test-123',
        name: 'John Doe',
        email: 'john@test.com',
        age: 25,
        gender: 'Male',
        city: 'Istanbul',
        country: 'Turkey',
      );

      // Assert
      expect(person.uid, 'test-123');
      expect(person.name, 'John Doe');
      expect(person.email, 'john@test.com');
      expect(person.age, 25);
      expect(person.gender, 'Male');
      expect(person.city, 'Istanbul');
      expect(person.country, 'Turkey');
    });

    test('creates person with nullable fields as null', () {
      // Act
      final person = Person();

      // Assert
      expect(person.uid, null);
      expect(person.name, null);
      expect(person.email, null);
      expect(person.age, null);
    });
  });

  group('Person Model - toJson', () {
    test('converts person to JSON correctly', () {
      // Arrange
      final person = Person(
        uid: 'test-123',
        name: 'John Doe',
        email: 'john@test.com',
        age: 25,
        gender: 'Male',
        city: 'Istanbul',
      );

      // Act
      final json = person.toJson();

      // Assert
      expect(json['uid'], 'test-123');
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@test.com');
      expect(json['age'], 25);
      expect(json['gender'], 'Male');
      expect(json['city'], 'Istanbul');
    });

    test('toJson includes skills when present', () {
      // Arrange
      final person = Person(
        uid: 'test-123',
        name: 'John Doe',
        skills: [
          Skill(name: 'Flutter', proficiency: 0.8, yearsOfExperience: 3),
          Skill(name: 'Dart', proficiency: 0.9, yearsOfExperience: 4),
        ],
      );

      // Act
      final json = person.toJson();

      // Assert
      expect(json['skills'], isNotNull);
      expect(json['skills'], isList);
      expect(json['skills'].length, 2);
    });

    test('toJson includes career goal when present', () {
      // Arrange
      final person = Person(
        uid: 'test-123',
        name: 'John Doe',
        careerGoal: CareerGoal(
          title: 'Senior Developer',
          description: 'Senior Developer',
          targetDate: DateTime.now(),
          requiredSkills: ['Flutter', 'Dart'],
          milestones: ['Milestone 1', 'Milestone 2'],
        ),
      );

      // Act
      final json = person.toJson();

      // Assert
      expect(json['careerGoal'], isNotNull);
      expect(json['careerGoal'], isMap);
    });
  });

  group('Person Model - fromMap', () {
    test('creates person from map correctly', () {
      // Arrange
      final map = {
        'uid': 'test-123',
        'name': 'John Doe',
        'email': 'john@test.com',
        'age': 25,
        'gender': 'Male',
        'city': 'Istanbul',
        'country': 'Turkey',
      };

      // Act
      final person = Person.fromMap(map);

      // Assert
      expect(person.uid, 'test-123');
      expect(person.name, 'John Doe');
      expect(person.email, 'john@test.com');
      expect(person.age, 25);
      expect(person.gender, 'Male');
      expect(person.city, 'Istanbul');
      expect(person.country, 'Turkey');
    });

    test('fromMap handles missing fields gracefully', () {
      // Arrange
      final map = {
        'uid': 'test-123',
        'name': 'John Doe',
      };

      // Act
      final person = Person.fromMap(map);

      // Assert
      expect(person.uid, 'test-123');
      expect(person.name, 'John Doe');
      expect(person.email, null);
      expect(person.age, null);
    });

    test('fromMap parses skills correctly', () {
      // Arrange
      final map = {
        'uid': 'test-123',
        'name': 'John Doe',
        'skills': [
          {
            'name': 'Flutter',
            'proficiency': 0.8,
            'yearsOfExperience': 3,
          },
          {
            'name': 'Dart',
            'proficiency': 0.9,
            'yearsOfExperience': 4,
          },
        ],
      };

      // Act
      final person = Person.fromMap(map);

      // Assert
      expect(person.skills, isNotNull);
      expect(person.skills!.length, 2);
      expect(person.skills![0].name, 'Flutter');
      expect(person.skills![0].proficiency, 0.8);
      expect(person.skills![1].name, 'Dart');
    });

    test('fromMap handles string skills list', () {
      // Arrange
      final map = {
        'uid': 'test-123',
        'name': 'John Doe',
        'skills': ['Flutter', 'Dart', 'Firebase'],
      };

      // Act
      final person = Person.fromMap(map);

      // Assert
      expect(person.skills, isNotNull);
      expect(person.skills!.length, 3);
      expect(person.skills![0].name, 'Flutter');
      expect(person.skills![0].proficiency, 0.5); // Default value
    });
  });

  group('Person Model - copyWith', () {
    test('copyWith creates new instance with updated fields', () {
      // Arrange
      final original = Person(
        uid: 'test-123',
        name: 'John Doe',
        age: 25,
        city: 'Istanbul',
      );

      // Act
      final updated = original.copyWith(
        name: 'Jane Doe',
        age: 30,
      );

      // Assert
      expect(updated.uid, 'test-123'); // Unchanged
      expect(updated.name, 'Jane Doe'); // Changed
      expect(updated.age, 30); // Changed
      expect(updated.city, 'Istanbul'); // Unchanged
    });

    test('copyWith without parameters returns same values', () {
      // Arrange
      final original = Person(
        uid: 'test-123',
        name: 'John Doe',
        age: 25,
      );

      // Act
      final copy = original.copyWith();

      // Assert
      expect(copy.uid, original.uid);
      expect(copy.name, original.name);
      expect(copy.age, original.age);
    });
  });

  group('Person Model - Equality', () {
    test('two persons with same data are equal', () {
      // Arrange
      final person1 = Person(
        uid: 'test-123',
        name: 'John Doe',
        age: 25,
      );
      final person2 = Person(
        uid: 'test-123',
        name: 'John Doe',
        age: 25,
      );

      // Act & Assert
      expect(person1 == person2, true);
      expect(person1.hashCode, person2.hashCode);
    });

    test('two persons with different data are not equal', () {
      // Arrange
      final person1 = Person(
        uid: 'test-123',
        name: 'John Doe',
        age: 25,
      );
      final person2 = Person(
        uid: 'test-456',
        name: 'Jane Doe',
        age: 30,
      );

      // Act & Assert
      expect(person1 == person2, false);
    });

    test('same instance is equal to itself', () {
      // Arrange
      final person = Person(
        uid: 'test-123',
        name: 'John Doe',
      );

      // Act & Assert
      expect(person == person, true);
    });
  });

  group('Person Model - toString', () {
    test('toString returns formatted string', () {
      // Arrange
      final person = Person(
        uid: 'test-123',
        name: 'John Doe',
        age: 25,
      );

      // Act
      final string = person.toString();

      // Assert
      expect(string, contains('test-123'));
      expect(string, contains('John Doe'));
      expect(string, contains('25'));
    });
  });

  group('Person Model - Career Fields', () {
    test('person with work experiences', () {
      // Arrange
      final person = Person(
        uid: 'test-123',
        name: 'John Doe',
        workExperiences: [
          WorkExperience(
            title: 'Senior Developer',
            company: 'Tech Corp',
            description: 'Senior Developer',
            startDate: DateTime(2020, 1, 1).toIso8601String(),
            endDate: DateTime(2025, 1, 1).toIso8601String(),
          ),
        ],
      );

      // Act
      final json = person.toJson();

      // Assert
      expect(person.workExperiences, isNotNull);
      expect(person.workExperiences!.length, 1);
      expect(json['workExperiences'], isNotNull);
    });

    test('person with projects', () {
      // Arrange
      final person = Person(
        uid: 'test-123',
        name: 'John Doe',
        projects: [
          Project(
            title: 'Flutter App',
            technologies: ['Flutter', 'Dart'],
            date: DateTime.now(),
            description: 'Mobile app',
          ),
        ],
      );

      // Act
      final json = person.toJson();

      // Assert
      expect(person.projects, isNotNull);
      expect(person.projects!.length, 1);
      expect(json['projects'], isNotNull);
    });

    test('person with skill gaps', () {
      // Arrange
      final person = Person(
        uid: 'test-123',
        name: 'John Doe',
        skillGaps: {
          'React': 0.7,
          'Docker': 0.5,
        },
      );

      // Act
      final json = person.toJson();

      // Assert
      expect(person.skillGaps, isNotNull);
      expect(person.skillGaps!.length, 2);
      expect(json['skillGaps'], isNotNull);
    });
  });

  group('Person Model - Marital Status (Fixed Typo)', () {
    test('maritalStatus field works correctly', () {
      // Arrange
      final person = Person(
        uid: 'test-123',
        name: 'John Doe',
        maritalStatus: 'Single',
      );

      // Act
      final json = person.toJson();

      // Assert
      expect(person.maritalStatus, 'Single');
      expect(json['maritalStatus'], 'Single');
    });

    test('fromMap parses maritalStatus correctly', () {
      // Arrange
      final map = {
        'uid': 'test-123',
        'name': 'John Doe',
        'maritalStatus': 'Married',
      };

      // Act
      final person = Person.fromMap(map);

      // Assert
      expect(person.maritalStatus, 'Married');
    });
  });
}
