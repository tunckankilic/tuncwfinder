import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/models/person.dart';
import 'package:tuncforwork/views/screens/swipe/mixins/swipe_filter_mixin.dart';

// Test controller that uses the mixin
class TestSwipeFilterController extends GetxController with SwipeFilterMixin {}

void main() {
  late TestSwipeFilterController controller;

  setUp(() {
    Get.testMode = true;
    controller = TestSwipeFilterController();
  });

  tearDown(() {
    Get.reset();
  });

  group('SwipeFilterMixin - Age Range', () {
    test('ageRange creates list from 18 to 100', () {
      // Act
      controller.ageRange();

      // Assert
      expect(controller.ageRangeList.length, 83); // 100 - 18 + 1
      expect(controller.ageRangeList.first, '18');
      expect(controller.ageRangeList.last, '100');
    });
  });

  group('SwipeFilterMixin - Filter Matching', () {
    test('matchesFilters - no filters applied returns true', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        gender: 'Male',
        age: 25,
      );
      final processedIds = <String>{};

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, true);
    });

    test('matchesFilters - processed user returns false', () {
      // Arrange
      final person = Person(uid: 'test-1', name: 'Test User');
      final processedIds = <String>{'test-1'};

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, false);
    });

    test('matchesFilters - gender filter matches', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        gender: 'Male',
      );
      final processedIds = <String>{};
      controller.chosenGender.value = 'Male';

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, true);
    });

    test('matchesFilters - gender filter does not match', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        gender: 'Male',
      );
      final processedIds = <String>{};
      controller.chosenGender.value = 'Female';

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, false);
    });

    test('matchesFilters - age filter matches', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        age: 25,
      );
      final processedIds = <String>{};
      controller.chosenAge.value = '25';

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, true);
    });

    test('matchesFilters - country filter matches', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        country: 'Turkey',
      );
      final processedIds = <String>{};
      controller.chosenCountry.value = 'Turkey';

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, true);
    });

    test('matchesFilters - multiple filters all match', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        gender: 'Male',
        age: 25,
        country: 'Turkey',
        education: 'Bachelor',
      );
      final processedIds = <String>{};
      controller.chosenGender.value = 'Male';
      controller.chosenAge.value = '25';
      controller.chosenCountry.value = 'Turkey';
      controller.chosenEducation.value = 'Bachelor';

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, true);
    });

    test('matchesFilters - one filter does not match', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        gender: 'Male',
        age: 25,
        country: 'Turkey',
      );
      final processedIds = <String>{};
      controller.chosenGender.value = 'Male';
      controller.chosenAge.value = '30'; // Doesn't match!

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, false);
    });

    test('matchesFilters - case insensitive matching', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        gender: 'MALE',
      );
      final processedIds = <String>{};
      controller.chosenGender.value = 'male';

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, true);
    });

    test('matchesFilters - "all" filter is ignored', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        gender: 'Male',
      );
      final processedIds = <String>{};
      controller.chosenGender.value = 'all'; // Should be ignored

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, true);
    });

    test('matchesFilters - employment status filter', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        employmentStatus: 'Full-time',
      );
      final processedIds = <String>{};
      controller.chosenEmploymentStatus.value = 'Full-time';

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, true);
    });

    test('matchesFilters - marital status filter', () {
      // Arrange
      final person = Person(
        uid: 'test-1',
        name: 'Test User',
        maritalStatus: 'Single',
      );
      final processedIds = <String>{};
      controller.chosenMaritalStatus.value = 'Single';

      // Act
      final result = controller.matchesFilters(person, processedIds);

      // Assert
      expect(result, true);
    });
  });

  group('SwipeFilterMixin - Clear Filters', () {
    test('clearFilters resets all filter values', () {
      // Arrange
      controller.chosenGender.value = 'Male';
      controller.chosenAge.value = '25';
      controller.chosenCountry.value = 'Turkey';
      controller.chosenEducation.value = 'Bachelor';
      controller.chosenProfession.value = 'Engineer';

      // Act
      controller.clearFilters();

      // Assert
      expect(controller.chosenGender.value, '');
      expect(controller.chosenAge.value, '');
      expect(controller.chosenCountry.value, '');
      expect(controller.chosenEducation.value, '');
      expect(controller.chosenProfession.value, '');
    });
  });

  group('SwipeFilterMixin - Active Filter Count', () {
    test('getActiveFilterCount returns 0 when no filters', () {
      // Act
      final count = controller.getActiveFilterCount();

      // Assert
      expect(count, 0);
    });

    test('getActiveFilterCount returns correct count', () {
      // Arrange
      controller.chosenGender.value = 'Male';
      controller.chosenAge.value = '25';
      controller.chosenCountry.value = 'Turkey';

      // Act
      final count = controller.getActiveFilterCount();

      // Assert
      expect(count, 3);
    });

    test('getActiveFilterCount ignores "all" values', () {
      // Arrange
      controller.chosenGender.value = 'Male';
      controller.chosenAge.value = 'all'; // Should be ignored
      controller.chosenCountry.value = 'Turkey';

      // Act
      final count = controller.getActiveFilterCount();

      // Assert
      expect(count, 2);
    });

    test('getActiveFilterCount ignores empty values', () {
      // Arrange
      controller.chosenGender.value = 'Male';
      controller.chosenAge.value = '';
      controller.chosenCountry.value = '   '; // Whitespace

      // Act
      final count = controller.getActiveFilterCount();

      // Assert
      expect(count, 1);
    });
  });

  group('SwipeFilterMixin - Apply Filters', () {
    test('applyFilters filters list correctly', () async {
      // Arrange
      final allUsers = [
        Person(uid: '1', name: 'User 1', gender: 'Male', age: 25),
        Person(uid: '2', name: 'User 2', gender: 'Female', age: 30),
        Person(uid: '3', name: 'User 3', gender: 'Male', age: 35),
      ];
      final filteredList = <Person>[].obs;
      final processedIds = <String>{};
      controller.chosenGender.value = 'Male';

      // Act
      await controller.applyFilters(allUsers, filteredList, processedIds);

      // Assert
      expect(filteredList.length, 2);
      expect(filteredList[0].uid, '1');
      expect(filteredList[1].uid, '3');
    });

    test('applyFilters excludes processed users', () async {
      // Arrange
      final allUsers = [
        Person(uid: '1', name: 'User 1', gender: 'Male'),
        Person(uid: '2', name: 'User 2', gender: 'Male'),
        Person(uid: '3', name: 'User 3', gender: 'Male'),
      ];
      final filteredList = <Person>[].obs;
      final processedIds = <String>{'1', '3'};
      controller.chosenGender.value = 'Male';

      // Act
      await controller.applyFilters(allUsers, filteredList, processedIds);

      // Assert
      expect(filteredList.length, 1);
      expect(filteredList[0].uid, '2');
    });
  });
}
