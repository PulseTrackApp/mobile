// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GymFlow';

  @override
  String get settings => 'Settings';

  @override
  String get homeTab => 'Home';

  @override
  String get activityTab => 'Activity';

  @override
  String get statsTab => 'Stats';

  @override
  String get menuTab => 'Menu';

  @override
  String get menuTitle => 'Menu';

  @override
  String get settingsSubtitle => 'Theme, language, GPS and privacy';

  @override
  String get profileTitle => 'Initial profile';

  @override
  String get profileSubtitle => 'Weight, height, goal and level';

  @override
  String get profileHeadline => 'Your starting data';

  @override
  String get displayName => 'Nickname';

  @override
  String get displayNameHint => 'Ex: Jayson';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => '8 characters minimum';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get existingAccount => 'I already have an account';

  @override
  String get sexOptional => 'Sex (optional)';

  @override
  String get sexOptionalHint => 'Male, female or custom';

  @override
  String get ageOptional => 'Age (optional)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get mainGoal => 'Goals';

  @override
  String get mainGoalHint => 'Ex: lose weight';

  @override
  String get fitnessLevel => 'Fitness level';

  @override
  String get fitnessLevelHint => 'Beginner, regular, advanced';

  @override
  String get fitnessLevelBeginner => 'Beginner';

  @override
  String get fitnessLevelIntermediate => 'Regular';

  @override
  String get fitnessLevelAdvanced => 'Advanced';

  @override
  String get preferredSports => 'Main sports';

  @override
  String get preferredSportsHint => 'Run, ride, walk';

  @override
  String get bodyIndicators => 'Body indicators';

  @override
  String get bmiPreview =>
      'BMI is calculated automatically from weight and height.';

  @override
  String get bmiTitle => 'Estimated BMI';

  @override
  String get bmiWaiting => 'Enter your weight and height to see your BMI.';

  @override
  String bmiValue(String value) {
    return 'BMI $value';
  }

  @override
  String get bmiHelper => 'Tracking reference, not a medical diagnosis.';

  @override
  String get bmiCategory => 'Category';

  @override
  String get bmiCategoryUnderweight => 'Underweight';

  @override
  String get bmiCategoryNormal => 'Normal range';

  @override
  String get bmiCategoryOverweight => 'Overweight';

  @override
  String get bmiCategoryObese => 'Obesity';

  @override
  String get profileDataNote =>
      'These data power calories, targets and Gemini coaching.';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get saving => 'Saving...';

  @override
  String get requiredProfileFields =>
      'Enter at least email, password, nickname, weight and height.';

  @override
  String get profileSavedApi => 'Profile saved to the API.';

  @override
  String get apiErrorPrefix => 'API error:';

  @override
  String get apiUnexpectedError => 'Unable to reach the API for now.';

  @override
  String get requiredBodyCheckInFields => 'Enter at least your weight.';

  @override
  String get checkInSavedApi => 'Check-in saved to the API.';

  @override
  String get requiredGoalFields => 'Enter a valid target.';

  @override
  String get goalSavedApi => 'Goal saved to the API.';

  @override
  String get createGoal => 'Create goal';

  @override
  String get goalTargetValue => 'Target value';

  @override
  String get noGoalsYet => 'No active goal yet.';

  @override
  String get coachAvailable => 'Coach available';

  @override
  String get requestWeeklyReview => 'Request review';

  @override
  String get coachQuestion => 'Question for the coach';

  @override
  String get coachQuestionHint => 'Ex: what can I do this week?';

  @override
  String get askCoach => 'Send to coach';

  @override
  String get workoutSavedApi => 'Workout saved to the API.';

  @override
  String get bodyProgressTitle => 'Body progress';

  @override
  String get bodyProgressSubtitle => 'Weekly check-in, weight and measurements';

  @override
  String get weeklyCheckIn => 'Weekly check-in';

  @override
  String get currentWeight => 'Current weight';

  @override
  String get weeklyChange => 'Change';

  @override
  String get waistCm => 'Waist (cm)';

  @override
  String get chestCm => 'Chest (cm)';

  @override
  String get hipsCm => 'Hips (cm)';

  @override
  String get energyLevel => 'Energy level';

  @override
  String get sleepHours => 'Average sleep (h)';

  @override
  String get weeklyNote => 'Weekly note';

  @override
  String get weeklyNoteHint => 'Fatigue, pain, motivation...';

  @override
  String get bodyTrendTitle => 'Body trend';

  @override
  String get bodyTrendEmpty => 'Charts will appear after your first check-ins.';

  @override
  String get saveCheckIn => 'Save check-in';

  @override
  String get workoutHistoryTitle => 'History';

  @override
  String get workoutHistorySubtitle => 'Sessions, calories and routes';

  @override
  String get sessionsOverview => 'Sessions overview';

  @override
  String get caloriesBurned => 'Calories burned';

  @override
  String get totalDistance => 'Total distance';

  @override
  String get movingTime => 'Moving time';

  @override
  String get recentSessions => 'Recent sessions';

  @override
  String get noSessionsYet => 'No workout saved yet.';

  @override
  String get filters => 'Filters';

  @override
  String get goalsTitle => 'Targets';

  @override
  String get goalsSubtitle => 'Weekly and performance goals';

  @override
  String get targetsHeadline => 'Your active targets';

  @override
  String get weeklyDistanceTarget => 'Weekly distance';

  @override
  String get weeklySessionsTarget => 'Sessions per week';

  @override
  String get weeklyCaloriesTarget => 'Sport calories';

  @override
  String get weeklyTrainingTimeTarget => 'Training time';

  @override
  String get weightTarget => 'Target weight';

  @override
  String get performanceTarget => 'Performance target';

  @override
  String get coachTitle => 'Gemini coach';

  @override
  String get coachSubtitle => 'Advice, alerts and exercises';

  @override
  String get coachHeadline => 'Personal analysis with Gemini';

  @override
  String get geminiApiKey => 'AI assistant';

  @override
  String get geminiApiKeyHint => 'Managed by the API';

  @override
  String get geminiPrivacyNote =>
      'The mobile app never handles any key. It only sends your requests to the API and displays the advice it receives.';

  @override
  String get saveGeminiKey => 'Coach status';

  @override
  String get geminiBackendStatusTitle => 'Assistant connected to the API';

  @override
  String get geminiBackendStatusBody =>
      'When the service is active, the app can request a review, effort alerts and exercise suggestions.';

  @override
  String get effortWarningTitle => 'Insufficient effort alert';

  @override
  String get effortWarningBody =>
      'The coach will compare your sessions with targets and explain what is left to do.';

  @override
  String get exerciseSuggestionsTitle => 'Exercise suggestions';

  @override
  String get exerciseSuggestionsBody =>
      'Gemini can suggest an easy run, brisk walk or strength work based on your level.';

  @override
  String get weeklyReviewTitle => 'Weekly review';

  @override
  String get weeklyReviewBody =>
      'Each week, the app will analyze progress, calories, weight and recovery.';

  @override
  String get physicalProgress => 'Body progress';

  @override
  String get profileMissing =>
      'Add your weight and height to calculate calories and trends.';

  @override
  String get caloriesThisWeek => 'Weekly calories';

  @override
  String get coachPreview => 'Coach tip';

  @override
  String get coachPreviewEmpty =>
      'The coach will be available once the API is connected.';

  @override
  String get openMenu => 'Open menu';

  @override
  String get draftSaved => 'Screen ready. Next step: local storage.';

  @override
  String get onboardingWelcomeTitle => 'Your sport, your stats, your targets';

  @override
  String get onboardingWelcomeBody =>
      'GymFlow stays personal: no social network, no subscription, just your routes, performance and progress.';

  @override
  String get onboardingProfileTitle => 'Starting profile';

  @override
  String get onboardingProfileBody =>
      'Enter weight, height and level to estimate calories and targets more accurately.';

  @override
  String get onboardingTargetsTitle => 'Targets and coach';

  @override
  String get onboardingTargetsBody =>
      'Set your main goal. Gemini can later suggest exercises and flag weak weeks.';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current / $total';
  }

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingFinish => 'Enter GymFlow';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGoalLoseWeight => 'Lose weight';

  @override
  String get onboardingGoalEndurance => 'Improve endurance';

  @override
  String get onboardingGoalRestart => 'Restart training';

  @override
  String get onboardingGoalRunFaster => 'Run faster';

  @override
  String get onboardingGoalGoFurther => 'Go further';

  @override
  String get onboardingGoalMaintain => 'Stay fit';

  @override
  String get onboardingGoalCyclingWalking => 'Improve cycling or walking';

  @override
  String get onboardingGoalOther => 'Other';

  @override
  String get customGoal => 'Describe your goal';

  @override
  String get customGoalHint => 'Ex: prepare a 10K, recover better...';

  @override
  String get onboardingFavoriteSport => 'Favorite sport';

  @override
  String get onboardingWeeklyTarget => 'Weekly target';

  @override
  String get activityReadyTitle => 'Ready to start';

  @override
  String get activityReadyBody =>
      'Choose your sport, wait for GPS signal, then start the session.';

  @override
  String get trackingTitle => 'Tracking';

  @override
  String get gpsWaiting => 'Waiting for GPS';

  @override
  String get gpsReady => 'GPS ready';

  @override
  String get liveSession => 'Workout running';

  @override
  String get pausedSession => 'Workout paused';

  @override
  String get elapsedTime => 'Timer';

  @override
  String get currentSpeed => 'Speed';

  @override
  String get elevation => 'Elevation';

  @override
  String get estimatedCalories => 'Estimated calories';

  @override
  String get routePreview => 'Route preview';

  @override
  String get liveRoute => 'Live route';

  @override
  String get currentLocation => 'My location';

  @override
  String get currentLocationUnavailable =>
      'Location unavailable. Check GPS permission.';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get finish => 'Finish';

  @override
  String get sessionSummaryTitle => 'Workout summary';

  @override
  String get workoutSavedDraft =>
      'Review the metrics, add how it felt, then save the workout.';

  @override
  String get perceivedEffort => 'Perceived effort';

  @override
  String get feeling => 'Feeling';

  @override
  String get sessionNote => 'Workout note';

  @override
  String get sessionNotesHint => 'How did you feel?';

  @override
  String get saveWorkout => 'Save workout';

  @override
  String get routePoints => 'GPS points';

  @override
  String get averageSpeed => 'Average speed';

  @override
  String get notConnectedYet =>
      'GPS is active. Keep the screen open during the workout.';

  @override
  String get statsThisWeek => 'This week';

  @override
  String get statsThisMonth => 'This month';

  @override
  String get statsThisYear => 'This year';

  @override
  String get statsPeriodWeek => 'Week';

  @override
  String get statsPeriodMonth => 'Month';

  @override
  String get statsPeriodYear => 'Year';

  @override
  String get statsOverview => 'Overview';

  @override
  String get statsTrend => 'Trend';

  @override
  String get statsEmptyPeriod =>
      'Stats will appear after your first saved workouts.';

  @override
  String get sessions => 'Sessions';

  @override
  String get activeDays => 'Active days';

  @override
  String get bestPace => 'Best pace';

  @override
  String get longestDistance => 'Longest distance';

  @override
  String get readyForNextSession => 'Ready for the next session?';

  @override
  String get run => 'Run';

  @override
  String get ride => 'Ride';

  @override
  String get walk => 'Walk';

  @override
  String get startWorkout => 'Start workout';

  @override
  String get start => 'Start';

  @override
  String get todayDistance => '0.00 km today';

  @override
  String get distance => 'Distance';

  @override
  String get time => 'Time';

  @override
  String get pace => 'Pace';

  @override
  String get weeklyGoal => 'Weekly goal';

  @override
  String get weeklyGoalProgress => '0 / 20 km';

  @override
  String get performance => 'Performance';

  @override
  String get record5k => '5K record';

  @override
  String get averagePace => 'Average pace';

  @override
  String get completedGoals => 'Completed goals';

  @override
  String get emptyDuration => '00:00:00';

  @override
  String get emptyDistanceKm => '0.00 km';

  @override
  String get emptyPace => '-- /km';

  @override
  String get emptyTime => '0:00';

  @override
  String get emptyValue => '--';

  @override
  String get zero => '0';

  @override
  String get kilometersUnit => 'km';

  @override
  String get hoursUnit => 'h';

  @override
  String get paceUnit => '/km';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageFrench => 'FR';

  @override
  String get languageEnglish => 'EN';

  @override
  String get settingsSport => 'Sport';

  @override
  String get settingsUnits => 'Units';

  @override
  String get unitsMetric => 'km';

  @override
  String get unitsImperial => 'mi';

  @override
  String get defaultSport => 'Default sport';

  @override
  String weeklyTargetValue(int value) {
    return '$value km per week';
  }

  @override
  String get settingsTracking => 'Tracking';

  @override
  String get gpsAccuracy => 'GPS accuracy';

  @override
  String get gpsBalanced => 'Eco';

  @override
  String get gpsHigh => 'Precise';

  @override
  String get gpsBest => 'Max';

  @override
  String get autoPause => 'Auto pause';

  @override
  String get autoPauseDescription => 'Pauses the session when you stop moving.';

  @override
  String get countdown => 'Countdown';

  @override
  String get countdownDescription => 'Adds 3 seconds before the start.';

  @override
  String get voiceCues => 'Voice cues';

  @override
  String get voiceCuesDescription =>
      'Announces time and distance during the session.';

  @override
  String get keepScreenAwake => 'Keep screen awake';

  @override
  String get keepScreenAwakeDescription =>
      'Keeps the screen on during tracking.';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get saveRoutes => 'Save routes';

  @override
  String get saveRoutesDescription =>
      'Keeps GPS points so you can review the trace.';

  @override
  String get privateActivities => 'Private activities';

  @override
  String get privateActivitiesDescription =>
      'Keeps sessions visible only to you.';

  @override
  String get settingsAccount => 'Account';

  @override
  String get account => 'Connected account';

  @override
  String get connectedAccount => 'Account connected to GymFlow.';

  @override
  String connectedAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get signedOut => 'You are signed out.';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';
}
