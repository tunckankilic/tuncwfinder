class AppStrings {
  // Auth Strings
  static const String appName = "TuncForWork";
  static const String welcome = "Welcome to TuncForWork";
  static const String loginNow = "Login now\nTo find your best match";
  static const String email = "Email";
  static const String password = "Password";
  static const String login = "Login";
  static const String register = "Register";
  static const String forgotPassword = "Did you forget your password?";
  static const String dontHaveAccount = "Don't have an account?";
  static const String createHere = "Create Here";
  static const String termsAndConditions = "Terms and Conditions";
  static const String privacyPolicy = "Privacy Policy";
  static const String iAgree = "I agree to the";
  static const String and = "and";

  // Error Messages
  static const String errorEmailExists =
      "This email is already in use. Please login or use a different email.";
  static const String errorNoAccount =
      "No account found with this email. Please register first.";
  static const String errorLoginFailed = "Login failed: ";
  static const String errorRegistrationFailed = "Registration failed: ";
  static const String errorLogoutFailed = "Logout failed: ";
  static const String errorPasswordResetFailed =
      "Failed to send password reset link: ";
  static const String errorProfileUpdateFailed = "Failed to update profile: ";
  static const String errorUrlOpen = "Cannot open URL: ";
  static const String errorUserCreationFailed = "User creation failed";
  static const String errorGithubConnection = "Failed to connect GitHub: ";
  static const String errorDownloadingProfile =
      "Error downloading profile picture: ";
  static const String errorFetchingUserData =
      "Error fetching user data from Firestore: ";
  static const String errorSignInGoogle = "Failed to sign in with Google: ";
  static const String errorSignInApple = "Failed to sign in with Apple: ";
  static const String errorSignIn = "Sign in failed: ";
  static const String errorCheckRegistration =
      "Failed to check user registration: ";
  static const String errorAuthenticationFailed =
      "Authentication failed. Please try again";
  static const String errorInvalidCredential =
      "The credential is malformed or has expired.";
  static const String errorUserDisabled =
      "This user account has been disabled.";
  static const String errorUserNotFound = "No user found for that email.";
  static const String errorWrongPassword =
      "Wrong password provided for that user.";
  static const String errorUndefined = "An undefined error occurred: ";

  // Success Messages
  static const String successTitle = "Success";
  static const String successPasswordReset = "Password reset email sent";
  static const String successProfileUpdate = "Profile information updated";
  static const String successEventJoin = "Joined the event";
  static const String successEventLeave = "Left the event";
  static const String successAccountCreated = "Account created successfully!";
  static const String successGithubConnected =
      "GitHub profile connected successfully!";
  static const String successImageSelected = "Image selected successfully";
  static const String successPhotoCaptured = "Photo captured successfully";

  // Validation Messages
  static const String validateNameRequired = "Name is required";
  static const String validateNameLength =
      "Name must be at least 2 characters long";
  static const String validateEmailFormat =
      "Please enter a valid email address";
  static const String validatePasswordRequirements =
      "Password does not meet requirements";
  static const String validatePasswordsMatch = "Passwords do not match";
  static const String validateTermsAccept =
      "Please accept the terms and conditions to continue";

  // Form Labels
  static const String labelFullName = "Full Name";
  static const String labelEmail = "Email";
  static const String labelPassword = "Password";
  static const String labelConfirmPassword = "Confirm Password";
  static const String labelProfileHeading = "Profile Heading";
  static const String labelAge = "Age";
  static const String labelPhone = "Phone";
  static const String labelCountry = "Country";
  static const String labelCity = "City";
  static const String labelHeight = "Height (cm)";
  static const String labelWeight = "Weight (kg)";
  static const String labelBodyType = "Body Type";
  static const String labelProfession = "Profession";
  static const String labelEmploymentStatus = "Employment Status";
  static const String labelIncome = "Annual Income";
  static const String labelLivingStatus = "Living Situation";

  // Button Labels
  static const String buttonTakePhoto = "Take Photo";
  static const String buttonChoosePhoto = "Choose Photo";
  static const String buttonPrevious = "Previous";
  static const String buttonNext = "Next";
  static const String buttonFinish = "Finish";
  static const String buttonAdd = "Add";
  static const String buttonCancel = "Cancel";
  static const String buttonSave = "Save";

  // Password Requirements
  static const List<String> passwordRequirements = [
    "At least 8 character",
    "At least one capital letter (A-Z)",
    "At least 1 small letter (a-z)",
    "At least 1 digit (0-9)",
    "At least 1 special character (!,#...)",
  ];

  // Social Media Labels
  static const String labelLinkedIn = "LinkedIn";
  static const String labelInstagram = "Instagram";
  static const String labelGitHub = "GitHub";
  static const String prefixLinkedIn = "linkedin.com/in/";
  static const String prefixInstagram = "@";
  static const String prefixGitHub = "github.com/";
  static const String placeholderUsername = "username";

  // Provider Names
  static const String providerGoogle = "Google";
  static const String providerFacebook = "Facebook";
  static const String providerApple = "Apple";
  static const String providerEmailPassword = "Email/Password";
  static const String providerUnknown = "Unknown Provider";

  // Collection Names
  static const String usersCollection = "users";
  static const String userSettingsCollection = "user_settings";
  static const String followersCollection = "followers";
  static const String followingCollection = "following";
  static const String connectionsCollection = "connections";
  static const String matchesCollection = "matches";

  // Field Names
  static const String fieldEmailNotifications = "emailNotifications";
  static const String fieldPushNotifications = "pushNotifications";
  static const String fieldProfileVisibility = "profileVisibility";
  static const String fieldLastUpdated = "lastUpdated";
  static const String fieldAccountStatus = "accountStatus";
  static const String fieldIsVerified = "isVerified";
  static const String fieldCreatedAt = "createdAt";

  // Event Strings
  static const String eventFull = "Event Full";
  static const String eventJoin = "Join";
  static const String eventLeave = "Leave Event";
  static const String eventEdit = "Edit Event";
  static const String eventParticipants = "Participants";
  static const String eventSpeakers = "Speakers";
  static const String eventSchedule = "Schedule";
  static const String eventResources = "Resources";
  static const String eventDescription = "Description";
  static const String eventRequirements = "Requirements";
  static const String eventLocation = "Location";
  static const String eventGetDirections = "Get Directions";
  static const String eventParticipant = "Participant";
  static const String eventHybrid = "Hybrid Event";
  static const String eventOnline = "Online Event";
  static const String eventJoinLink = "Join Link";

  // Career Strings
  static const String careerMatches = "Job Matches";
  static const String careerPathError = "Specified career path not found";
  static const String careerGoalPrefix = "Career goal: ";
  static const String addWorkExperience = "Add Work Experience";
  static const String position = "Position";
  static const String company = "Company";
  static const String description = "Description";
  static const String startDate = "Start Date (DD/MM/YYYY)";
  static const String endDate = "End Date (DD/MM/YYYY)";
  static const String technologies = "Technologies (comma separated)";
  static const String cancel = "Cancel";
  static const String save = "Save";

  // Error Log Messages
  static const String errorCareerPaths = "Error loading career paths: ";
  static const String errorCareerSuggestions =
      "Error generating career suggestions: ";
  static const String errorCareerGoal = "Error setting career goal: ";
  static const String errorJobMatching = "Error matching job listings: ";
  static const String errorLearningPath = "Error creating learning path: ";
  static const String errorSkillGap = "Error analyzing skill gap: ";
  static const String errorChallenges = "Error loading challenges: ";
  static const String errorChallengeComplete = "Error completing challenge: ";

  // Collection Names
  static const String careerPathsCollection = "career_paths";
  static const String challengesCollection = "challenges";

  // Field Names
  static const String nameField = "name";
  static const String emailField = "email";
  static const String createdAtField = "createdAt";
  static const String updatedAtField = "updatedAt";
  static const String photoURLField = "photoURL";
  static const String careerGoalField = "careerGoal";
  static const String skillGapsField = "skillGaps";
  static const String isCompletedField = "isCompleted";

  // Badge Strings
  static const String challengeMasterId = "challenge_master";
  static const String challengeMasterName = "Challenge Master";
  static const String challengeMasterDesc = "You completed 5 challenges!";
  static const String challengeMasterIcon =
      "https://example.com/badges/challenge_master.png";

  // Navigation Labels
  static const String navHome = "Home";
  static const String navFavorites = "Favorites";
  static const String navLikes = "Likes";
  static const String navProfile = "Profile";

  // Screen Titles
  static const String splashTitle = "TuncWFinder";
  static const String homeTitle = "Home";
  static const String favoritesTitle = "Favorites";
  static const String likesTitle = "Likes";
  static const String profileTitle = "Profile";

  // Route Names
  static const String routeSplash = "/splash";
  static const String routeLogin = "/login";
  static const String routeRegister = "/register";
  static const String routeHome = "/home";
  static const String routeProfile = "/profile";
  static const String routeForgotPassword = "/forgot-password";
  static const String routeCreateEvent = "/create-event";
  static const String routeEventDetails = "/event/:id";

  static const String routeNotFound = "/not-found";
  static const String routeSwipe = "/swipe";
  static const String routeFavorites = "/favorites";
  static const String routeLikes = "/likes";
  static const String routeEventList = "/events";
  static const String routeCommunity = "/community";

  // Community Screen Strings
  static const String createEventTitle = "Create Event";
  static const String createEventTitleField = "Event Title";
  static const String createEventDescription = "Event Description";
  static const String createEventType = "Event Type";
  static const String maxParticipants = "Maximum Participants";
  static const String suggestVenue = "Suggest Venue";
  static const String onlineEvent = "Online Event";
  static const String hybridEvent = "Hybrid Event";
  static const String joinLink = "Join Link";
  static const String eventTopicsList = "Topics";
  static const String createEventButton = "Create Event";
  static const String venueCapacity = "%d people";
  static const String eventCreatedSuccess = "Event created successfully";
  static const String eventCreationError = "Error creating event: %s";
  static const String errorSelectLocationAndParticipants =
      "Please select number of participants and location";

  // Event Topics
  static const List<String> availableEventTopics = [
    'Flutter',
    'Dart',
    'Firebase',
    'Mobile Development',
    'Web Development',
    'Backend',
    'Frontend',
    'DevOps',
    'Cloud Computing',
    'AI/ML',
    'Blockchain',
    'IoT',
    'Cybersecurity',
    'Data Science',
    'UI/UX Design'
  ];

  // Form Validation Messages
  static const String errorEnterTitle = "Please enter a title";
  static const String errorEnterDescription = "Please enter a description";
  static const String errorEnterParticipants =
      "Please enter number of participants";
  static const String errorInvalidNumber = "Please enter a valid number";
  static const String errorOnlineEventLink =
      "Link is required for online events";

  // Error Messages
  static const String errorPageNotFound = "Error: Page not found";
  static const String errorTitle = "Error";
}
