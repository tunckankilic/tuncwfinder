/// Auth form state models to replace TextEditingController memory leaks
class BasicInfoFormState {
  final String email;
  final String name;
  final String age;
  final String phoneNo;
  final String city;
  final String country;
  final String profileHeading;

  const BasicInfoFormState({
    this.email = '',
    this.name = '',
    this.age = '',
    this.phoneNo = '',
    this.city = '',
    this.country = '',
    this.profileHeading = '',
  });

  BasicInfoFormState copyWith({
    String? email,
    String? name,
    String? age,
    String? phoneNo,
    String? city,
    String? country,
    String? profileHeading,
  }) {
    return BasicInfoFormState(
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      phoneNo: phoneNo ?? this.phoneNo,
      city: city ?? this.city,
      country: country ?? this.country,
      profileHeading: profileHeading ?? this.profileHeading,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'phoneNo': phoneNo,
      'city': city,
      'country': country,
      'profileHeading': profileHeading,
    };
  }
}

class PhysicalInfoFormState {
  final String gender;
  final String height;
  final String weight;
  final String bodyType;

  const PhysicalInfoFormState({
    this.gender = '',
    this.height = '',
    this.weight = '',
    this.bodyType = '',
  });

  PhysicalInfoFormState copyWith({
    String? gender,
    String? height,
    String? weight,
    String? bodyType,
  }) {
    return PhysicalInfoFormState(
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bodyType: bodyType ?? this.bodyType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'height': height,
      'weight': weight,
      'bodyType': bodyType,
    };
  }
}

class LifestyleFormState {
  final String drink;
  final String smoke;
  final String maritalStatus;
  final String haveChildren;
  final String noOfChildren;
  final String livingSituation;
  final String willingToRelocate;

  const LifestyleFormState({
    this.drink = '',
    this.smoke = '',
    this.maritalStatus = '',
    this.haveChildren = '',
    this.noOfChildren = '',
    this.livingSituation = '',
    this.willingToRelocate = '',
  });

  LifestyleFormState copyWith({
    String? drink,
    String? smoke,
    String? maritalStatus,
    String? haveChildren,
    String? noOfChildren,
    String? livingSituation,
    String? willingToRelocate,
  }) {
    return LifestyleFormState(
      drink: drink ?? this.drink,
      smoke: smoke ?? this.smoke,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      haveChildren: haveChildren ?? this.haveChildren,
      noOfChildren: noOfChildren ?? this.noOfChildren,
      livingSituation: livingSituation ?? this.livingSituation,
      willingToRelocate: willingToRelocate ?? this.willingToRelocate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'drink': drink,
      'smoke': smoke,
      'maritalStatus': maritalStatus,
      'haveChildren': haveChildren,
      'noOfChildren': noOfChildren,
      'livingSituation': livingSituation,
      'willingToRelocate': willingToRelocate,
    };
  }
}

class CareerFormState {
  final String profession;
  final String employmentStatus;
  final String income;
  final String education;
  final String careerGoal;
  final String targetPosition;

  const CareerFormState({
    this.profession = '',
    this.employmentStatus = '',
    this.income = '',
    this.education = '',
    this.careerGoal = '',
    this.targetPosition = '',
  });

  CareerFormState copyWith({
    String? profession,
    String? employmentStatus,
    String? income,
    String? education,
    String? careerGoal,
    String? targetPosition,
  }) {
    return CareerFormState(
      profession: profession ?? this.profession,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      income: income ?? this.income,
      education: education ?? this.education,
      careerGoal: careerGoal ?? this.careerGoal,
      targetPosition: targetPosition ?? this.targetPosition,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profession': profession,
      'employmentStatus': employmentStatus,
      'income': income,
      'education': education,
      'careerGoal': careerGoal,
      'targetPosition': targetPosition,
    };
  }
}

class CulturalFormState {
  final String nationality;
  final String ethnicity;
  final String religion;
  final String languageSpoken;

  const CulturalFormState({
    this.nationality = '',
    this.ethnicity = '',
    this.religion = '',
    this.languageSpoken = '',
  });

  CulturalFormState copyWith({
    String? nationality,
    String? ethnicity,
    String? religion,
    String? languageSpoken,
  }) {
    return CulturalFormState(
      nationality: nationality ?? this.nationality,
      ethnicity: ethnicity ?? this.ethnicity,
      religion: religion ?? this.religion,
      languageSpoken: languageSpoken ?? this.languageSpoken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nationality': nationality,
      'ethnicity': ethnicity,
      'religion': religion,
      'languageSpoken': languageSpoken,
    };
  }
}

class SocialFormState {
  final String instagram;

  const SocialFormState({
    this.instagram = '',
  });

  SocialFormState copyWith({
    String? instagram,
  }) {
    return SocialFormState(
      instagram: instagram ?? this.instagram,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'instagram': instagram,
    };
  }
}
