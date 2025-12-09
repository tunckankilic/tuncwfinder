import 'dart:developer';
import 'package:get/get.dart';
import 'package:tuncforwork/models/person.dart';

/// SwipeController için filtreleme mantığını içerir
mixin SwipeFilterMixin on GetxController {
  // Filter değişkenleri
  RxString chosenGender = "".obs;
  RxString chosenCountry = "".obs;
  RxString chosenAge = "".obs;
  RxString chosenLanguage = "".obs;
  RxString chosenBodyType = "".obs;
  RxString chosenEducation = "".obs;
  RxString chosenEmploymentStatus = "".obs;
  RxString chosenLivingSituation = "".obs;
  RxString chosenMaritalStatus = "".obs;
  RxString chosenDrinkingHabit = "".obs;
  RxString chosenSmokingHabit = "".obs;
  RxString chosenNationality = "".obs;
  RxString chosenEthnicity = "".obs;
  RxString chosenReligion = "".obs;
  RxString chosenProfession = "".obs;

  RxList<String> ageRangeList = <String>[].obs;

  /// Yaş aralığı listesini oluşturur
  void ageRange() {
    List<String> ages = [];
    for (int i = 18; i <= 100; i++) {
      ages.add(i.toString());
    }
    ageRangeList.assignAll(ages);
  }

  /// Kullanıcıyı filtrelere göre kontrol eder
  bool matchesFilters(Person person, Set<String> processedUserIds) {
    bool matchesFilters = true;

    // Eğer kullanıcı daha önce işlenmişse atla
    if (processedUserIds.contains(person.uid)) {
      return false;
    }

    // Gender filter
    if (_isValidInput(chosenGender.value)) {
      matchesFilters = matchesFilters &&
          person.gender?.toLowerCase() == chosenGender.value.toLowerCase();
    }

    // Country filter
    if (_isValidInput(chosenCountry.value)) {
      matchesFilters = matchesFilters &&
          person.country?.toLowerCase() == chosenCountry.value.toLowerCase();
    }

    // Age filter
    if (_isValidInput(chosenAge.value)) {
      matchesFilters =
          matchesFilters && person.age.toString() == chosenAge.value;
    }

    // Language filter
    if (_isValidInput(chosenLanguage.value)) {
      matchesFilters = matchesFilters &&
          person.languageSpoken?.toLowerCase() ==
              chosenLanguage.value.toLowerCase();
    }

    // Body type filter
    if (_isValidInput(chosenBodyType.value)) {
      matchesFilters = matchesFilters &&
          person.bodyType?.toLowerCase() == chosenBodyType.value.toLowerCase();
    }

    // Education filter
    if (_isValidInput(chosenEducation.value)) {
      matchesFilters = matchesFilters &&
          person.education?.toLowerCase() ==
              chosenEducation.value.toLowerCase();
    }

    // Employment status filter
    if (_isValidInput(chosenEmploymentStatus.value)) {
      matchesFilters = matchesFilters &&
          person.employmentStatus?.toLowerCase() ==
              chosenEmploymentStatus.value.toLowerCase();
    }

    // Living situation filter
    if (_isValidInput(chosenLivingSituation.value)) {
      matchesFilters = matchesFilters &&
          person.livingSituation?.toLowerCase() ==
              chosenLivingSituation.value.toLowerCase();
    }

    // Marital status filter
    if (_isValidInput(chosenMaritalStatus.value)) {
      matchesFilters = matchesFilters &&
          person.maritalStatus?.toLowerCase() ==
              chosenMaritalStatus.value.toLowerCase();
    }

    // Drinking habit filter
    if (_isValidInput(chosenDrinkingHabit.value)) {
      matchesFilters = matchesFilters &&
          person.drink?.toLowerCase() ==
              chosenDrinkingHabit.value.toLowerCase();
    }

    // Smoking habit filter
    if (_isValidInput(chosenSmokingHabit.value)) {
      matchesFilters = matchesFilters &&
          person.smoke?.toLowerCase() == chosenSmokingHabit.value.toLowerCase();
    }

    // Nationality filter
    if (_isValidInput(chosenNationality.value)) {
      matchesFilters = matchesFilters &&
          person.nationality?.toLowerCase() ==
              chosenNationality.value.toLowerCase();
    }

    // Ethnicity filter
    if (_isValidInput(chosenEthnicity.value)) {
      matchesFilters = matchesFilters &&
          person.ethnicity?.toLowerCase() ==
              chosenEthnicity.value.toLowerCase();
    }

    // Religion filter
    if (_isValidInput(chosenReligion.value)) {
      matchesFilters = matchesFilters &&
          person.religion?.toLowerCase() == chosenReligion.value.toLowerCase();
    }

    // Profession filter
    if (_isValidInput(chosenProfession.value)) {
      matchesFilters = matchesFilters &&
          person.profession?.toLowerCase() ==
              chosenProfession.value.toLowerCase();
    }

    return matchesFilters;
  }

  /// Filtreleri temizler
  void clearFilters() {
    chosenGender.value = "";
    chosenCountry.value = "";
    chosenAge.value = "";
    chosenLanguage.value = "";
    chosenBodyType.value = "";
    chosenEducation.value = "";
    chosenEmploymentStatus.value = "";
    chosenLivingSituation.value = "";
    chosenMaritalStatus.value = "";
    chosenDrinkingHabit.value = "";
    chosenSmokingHabit.value = "";
    chosenNationality.value = "";
    chosenEthnicity.value = "";
    chosenReligion.value = "";
    chosenProfession.value = "";
  }

  /// Aktif filtre sayısını döndürür
  int getActiveFilterCount() {
    int count = 0;
    if (_isValidInput(chosenGender.value)) count++;
    if (_isValidInput(chosenCountry.value)) count++;
    if (_isValidInput(chosenAge.value)) count++;
    if (_isValidInput(chosenLanguage.value)) count++;
    if (_isValidInput(chosenBodyType.value)) count++;
    if (_isValidInput(chosenEducation.value)) count++;
    if (_isValidInput(chosenEmploymentStatus.value)) count++;
    if (_isValidInput(chosenLivingSituation.value)) count++;
    if (_isValidInput(chosenMaritalStatus.value)) count++;
    if (_isValidInput(chosenDrinkingHabit.value)) count++;
    if (_isValidInput(chosenSmokingHabit.value)) count++;
    if (_isValidInput(chosenNationality.value)) count++;
    if (_isValidInput(chosenEthnicity.value)) count++;
    if (_isValidInput(chosenReligion.value)) count++;
    if (_isValidInput(chosenProfession.value)) count++;
    return count;
  }

  /// Filtreleri uygular
  Future<void> applyFilters(
    List<Person> allUsers,
    RxList<Person> filteredList,
    Set<String> processedUserIds,
  ) async {
    try {
      log('Applying filters...');
      final filtered = allUsers.where((person) {
        return matchesFilters(person, processedUserIds);
      }).toList();

      filteredList.assignAll(filtered);
      log('Filtered: ${filtered.length} users match criteria');
    } catch (e) {
      log('Error applying filters: $e');
    }
  }

  // Private helper methods

  bool _isValidInput(String input) {
    return input.trim().isNotEmpty &&
        input.toLowerCase() != 'all' &&
        input.toLowerCase() != 'seç';
  }
}
