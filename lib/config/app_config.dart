/// Base URL only - no trailing slash.
/// Override at build/run: --dart-define=BASE_URL=https://api.example.com
const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'https://ebg1xd8fv9.execute-api.ap-south-1.amazonaws.com/second',
);

/// Path suffix for user profile. Kept in code so only base URL changes per env.
const String userProfilePath = '/v1/user/profile';
const String userQuestionnairePath = '/v1/user/questionnaire';
const String experiencesAllPath = '/v1/experiences/all';
const String experiencesPath = '/v1/experiences';
const String userInterestedExperiencesPath = '/v1/user/interested-experiences';

String get userProfileUrl => '$baseUrl$userProfilePath';
String get userQuestionnaireUrl => '$baseUrl$userQuestionnairePath';
String get experiencesAllUrl => '$baseUrl$experiencesAllPath';
String get userInterestedExperiencesUrl => '$baseUrl$userInterestedExperiencesPath';

String experienceInterestUrl(String experienceId) => '$baseUrl/v1/experiences/$experienceId/interest';

String experienceStatusUrl(String experienceId) => '$baseUrl/v1/experiences/$experienceId/status';

String get experiencesUrl => '$baseUrl$experiencesPath';