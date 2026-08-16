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
  String get forgotPassword => 'Forgot password?';

  @override
  String get passwordResetTitle => 'Password reset';

  @override
  String get passwordResetCode => 'Received code';

  @override
  String get passwordResetCodeHint => 'Ex: ABCD1234';

  @override
  String get newPassword => 'New password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get requestResetCode => 'Get code';

  @override
  String get resetPassword => 'Change password';

  @override
  String get passwordResetSending => 'Sending...';

  @override
  String get passwordResetSubmitting => 'Updating...';

  @override
  String get passwordResetEmailRequired =>
      'Enter your email to receive a code.';

  @override
  String get passwordResetRequiredFields =>
      'Enter the email, code and new password.';

  @override
  String get passwordResetCodeSent =>
      'If this account exists, a code has just been sent.';

  @override
  String get passwordResetSuccess => 'Password updated. You can sign in.';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordSuccess =>
      'Password changed. The session was secured.';

  @override
  String get changePasswordRequiredFields =>
      'Enter the current password and the new password.';

  @override
  String get emailVerified => 'Email address confirmed';

  @override
  String get emailNotVerified => 'Email address not confirmed';

  @override
  String get emailVerificationTitle => 'Confirm email address';

  @override
  String get emailVerificationBody =>
      'Enter the code received by email to confirm your address.';

  @override
  String get verificationCode => 'Confirmation code';

  @override
  String get resendVerificationCode => 'Resend code';

  @override
  String get verifyEmail => 'Confirm address';

  @override
  String get emailVerificationCodeSent =>
      'If the address exists, a code has just been sent.';

  @override
  String get emailVerificationSuccess => 'Email address confirmed.';

  @override
  String get emailVerificationRequiredFields =>
      'Enter the code received by email.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountBody =>
      'This action permanently deletes the profile, workouts, routes, goals and tracking data.';

  @override
  String get deleteAccountConfirmLabel =>
      'I understand this action is permanent.';

  @override
  String get deleteAccountFinalButton => 'Delete permanently';

  @override
  String get deleteAccountSuccess => 'Account deleted.';

  @override
  String get deleteAccountRequiredFields =>
      'Enter your password and confirm the action.';

  @override
  String get close => 'Close';

  @override
  String get moduleLockedTitle => 'Module locked';

  @override
  String get moduleLockedShort => 'Feature locked';

  @override
  String moduleLockedBody(String module) {
    return 'The $module module is not active on this account. An administrator can enable it from the desktop app.';
  }

  @override
  String get moduleWorkouts => 'Workouts and routes';

  @override
  String get moduleBodyCheckins => 'Body progress';

  @override
  String get moduleGoals => 'Goals';

  @override
  String get moduleStats => 'Statistics';

  @override
  String get moduleWeeklySummary => 'Weekly summary';

  @override
  String get moduleCoach => 'Super Coach';

  @override
  String get moduleExport => 'Data export';

  @override
  String get modulePush => 'Notifications';

  @override
  String get existingAccount => 'I already have an account';

  @override
  String get sexOptional => 'Sex';

  @override
  String get sexOptionalHint => 'Male or female';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

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
      'These data power calories, targets and Super Coach advice.';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get saving => 'Saving...';

  @override
  String get requiredProfileFields =>
      'Enter at least your nickname, weight and height.';

  @override
  String get requiredLoginFields => 'Enter your email and password.';

  @override
  String get existingAccountSessionMissing =>
      'The session is no longer active. Sign in again from the profile step.';

  @override
  String get profileSavedApi => 'Profile saved.';

  @override
  String get apiErrorPrefix => 'Error:';

  @override
  String get apiUnexpectedError => 'GymFlow service is unavailable for now.';

  @override
  String get requiredBodyCheckInFields => 'Enter at least your weight.';

  @override
  String get checkInSavedApi => 'Check-in saved.';

  @override
  String get requiredGoalFields => 'Enter a valid target.';

  @override
  String get goalSavedApi => 'Goal saved.';

  @override
  String get createGoal => 'Create goal';

  @override
  String get goalTargetValue => 'Target value';

  @override
  String get noGoalsYet => 'No active goal yet.';

  @override
  String get coachAvailable => 'Super Coach ready';

  @override
  String get requestWeeklyReview => 'Request review';

  @override
  String get coachQuestion => 'Question for the coach';

  @override
  String get coachQuestionHint => 'Ex: what can I do this week?';

  @override
  String get askCoach => 'Send to coach';

  @override
  String get workoutSavedApi => 'Workout saved.';

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
  String get openWorkoutDetails => 'View route and highlights';

  @override
  String get workoutDetailTitle => 'Workout details';

  @override
  String get loadingWorkout => 'Loading workout...';

  @override
  String get routeReplay => 'Saved route';

  @override
  String get workoutHighlights => 'Highlights';

  @override
  String get routeTimeline => 'Route markers';

  @override
  String get startedAtLabel => 'Start';

  @override
  String get midRouteLabel => 'Mid-route';

  @override
  String get endedAtLabel => 'Finish';

  @override
  String get workoutDetails => 'Workout data';

  @override
  String get gpsTraceMissing => 'No GPS trace was saved for this workout.';

  @override
  String get shareSavedWorkout => 'Share workout';

  @override
  String get fastestMoment => 'Peak speed';

  @override
  String get speedPeakMarker => 'Peak';

  @override
  String get midRouteMarker => 'Mid-route';

  @override
  String fastestMomentAt(String time) {
    return 'At $time';
  }

  @override
  String get workoutNoteEmpty => 'No note for this workout.';

  @override
  String routePointCount(int count) {
    return '$count points';
  }

  @override
  String effortValue(int value) {
    return '$value/10';
  }

  @override
  String routeDistanceAt(String distance) {
    return '$distance from start';
  }

  @override
  String get replayRouteAction => 'Replay this route';

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
  String get coachTitle => 'Super Coach';

  @override
  String get coachSubtitle => 'Advice, alerts and exercises';

  @override
  String get coachHeadline => 'Personal analysis with Super Coach';

  @override
  String get coachUnavailableTitle => 'Super Coach is preparing';

  @override
  String get coachUnavailableBody =>
      'Personalized advice is not available yet. Try again a little later.';

  @override
  String get effortWarningTitle => 'Insufficient effort alert';

  @override
  String get effortWarningBody =>
      'The coach will compare your sessions with targets and explain what is left to do.';

  @override
  String get exerciseSuggestionsTitle => 'Exercise suggestions';

  @override
  String get exerciseSuggestionsBody =>
      'Super Coach can suggest an easy run, brisk walk or strength work based on your level.';

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
      'No advice yet. Request a review to generate your first recommendation.';

  @override
  String get coachPreviewChecking => 'Checking Super Coach...';

  @override
  String get coachPreviewUnavailable =>
      'Super Coach is not ready yet. Try again a little later.';

  @override
  String get coachPreviewLocked => 'Super Coach is locked on this account.';

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
      'Set your main goal. Super Coach can later suggest exercises and flag weak weeks.';

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
  String get challengeRouteGuide => 'Route guide';

  @override
  String get challengeModeTitle => 'Challenge mode';

  @override
  String get challengeEnabled => 'Enable challenge';

  @override
  String get challengeDistanceTarget => 'Target distance';

  @override
  String get challengeTimeLimit => 'Time limit';

  @override
  String get challengeFieldsRequired =>
      'Enter a valid target distance and time limit.';

  @override
  String get challengeLiveTitle => 'Challenge in progress';

  @override
  String challengeProgressLabel(String distance, String target) {
    return '$distance / $target';
  }

  @override
  String challengeRemainingTime(String time) {
    return '$time left';
  }

  @override
  String get challengeHalfway => 'You are already halfway. Keep this rhythm.';

  @override
  String get challengeDeadlineApproaching =>
      'Deadline is close: stay focused, finish strong.';

  @override
  String get challengeDeadlineMissed =>
      'Time limit passed. Finish the distance cleanly.';

  @override
  String get challengeTargetReachedTitle => 'Challenge completed';

  @override
  String get challengeTargetReachedBody =>
      'Target reached in time. Great session.';

  @override
  String get challengeRouteReplayActive => 'Route replay active';

  @override
  String get challengeRouteReplayBody =>
      'The previous track is shown on the map.';

  @override
  String get minutesUnit => 'min';

  @override
  String get currentLocation => 'My location';

  @override
  String get locationPermissionDenied =>
      'Allow location access to start tracking.';

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
  String get feelingGreat => 'Great';

  @override
  String get feelingGood => 'Good';

  @override
  String get feelingOk => 'OK';

  @override
  String get feelingTired => 'Tired';

  @override
  String get feelingExhausted => 'Exhausted';

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
  String get maxSpeed => 'Peak speed';

  @override
  String get shareWorkoutImage => 'Share image';

  @override
  String get sharingWorkoutImage => 'Preparing image...';

  @override
  String get shareWorkoutTitle => 'My GymFlow workout';

  @override
  String get shareWorkoutChoiceTitle => 'What do you want to share?';

  @override
  String get shareRouteOnlyTitle => 'Map only';

  @override
  String get shareRouteOnlySubtitle => 'The route, markers and speed peaks.';

  @override
  String get shareRouteWithDataTitle => 'Map + data';

  @override
  String get shareRouteWithDataSubtitle =>
      'Route, distance, timer, pace and speed.';

  @override
  String get shareRouteOnlyText => 'My GymFlow route';

  @override
  String get shareWorkoutUnavailable => 'Unable to prepare the image for now.';

  @override
  String get workoutAppreciationTitle => 'GymFlow rating';

  @override
  String workoutScore(int score) {
    return '$score/100';
  }

  @override
  String get workoutRatingExcellent => 'Excellent performance';

  @override
  String get workoutRatingGood => 'Very good session';

  @override
  String get workoutRatingOk => 'Useful session';

  @override
  String get workoutRatingLow => 'Base set';

  @override
  String get workoutRatingRecordBody =>
      'You beat a personal reference. Keep that momentum.';

  @override
  String get workoutRatingChallengeBody =>
      'You matched your challenge: clear target, clean execution.';

  @override
  String get workoutRatingGoodBody =>
      'Volume and rhythm are moving in the right direction. Keep going.';

  @override
  String get workoutRatingOkBody =>
      'Session saved. Next step: a little more consistency or distance.';

  @override
  String get workoutRatingLowBody =>
      'Even a short workout counts. Restart simple and steady.';

  @override
  String get workoutChallengeCompletedBadge => 'Challenge done';

  @override
  String workoutChallengeProgressBadge(int percent) {
    return '$percent% of challenge';
  }

  @override
  String get workoutDistanceRecordBadge => 'Distance record';

  @override
  String get workoutPaceRecordBadge => 'Pace record';

  @override
  String get recordCelebrationTitle => 'New record';

  @override
  String get distanceRecordCelebrationBody =>
      'You just beat your longest distance.';

  @override
  String get paceRecordCelebrationBody => 'You just improved your best pace.';

  @override
  String get notConnectedYet =>
      'GPS is active. You can pause, resume or finish the workout.';

  @override
  String get confirmPauseTitle => 'Pause this workout?';

  @override
  String get confirmPauseBody =>
      'Active time stops and the route continues when you resume.';

  @override
  String get confirmPauseAction => 'Pause';

  @override
  String get confirmFinishTitle => 'Finish this workout?';

  @override
  String get confirmFinishBody =>
      'You will leave live tracking and move to the summary. Make sure the workout is really done.';

  @override
  String get confirmFinishAction => 'Finish';

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
  String get weeklyGoalReached =>
      'Goal reached. You can consolidate or aim for a bonus.';

  @override
  String get weeklyGoalAlmost =>
      'Almost done. One short outing can close the week.';

  @override
  String get weeklyGoalStrong => 'Very good start. Keep this rhythm.';

  @override
  String weeklyGoalRemaining(String distance) {
    return '$distance left this week.';
  }

  @override
  String get weeklyGoalNoTarget => 'Add a goal to track your progress.';

  @override
  String get goalNeedsWork =>
      'Still far from target. A short session can restart progress.';

  @override
  String get performance => 'Performance';

  @override
  String get record5k => '5K record';

  @override
  String get averagePace => 'Average pace';

  @override
  String get completedGoals => 'Completed goals';

  @override
  String get pricingTitle => 'Pricing';

  @override
  String get pricingSubtitle =>
      'GymFlow plans are coming soon. Access and modules are being prepared.';

  @override
  String get pricingComingSoon => 'Coming soon';

  @override
  String get pricingRequiredTitle => 'Payment required';

  @override
  String get pricingRequiredBody =>
      'Your access must be activated to continue using these features.';

  @override
  String get pricingRetryAccess => 'Check access';

  @override
  String get pricingPlanEssential => 'Essential';

  @override
  String get pricingPlanPerformance => 'Performance';

  @override
  String get pricingPlanCoach => 'Super Coach';

  @override
  String get pricingFeatureTracking =>
      'GPS tracking, pause and workout summary';

  @override
  String get pricingFeatureStats => 'Week, month and year stats';

  @override
  String get pricingFeatureHistory => 'History and saved routes';

  @override
  String get pricingFeatureChallenges => 'Distance + time challenges';

  @override
  String get pricingFeatureRouteReplay => 'Replay a saved route';

  @override
  String get pricingFeatureExports => 'Share map only or map + data';

  @override
  String get pricingFeatureCoach => 'Personalized advice';

  @override
  String get pricingFeatureWeeklyReview => 'Weekly review';

  @override
  String get pricingFeatureMotivation => 'Motivation and celebrations';

  @override
  String get sessionExpiredToast =>
      'Your session has expired. Sign in again to continue.';

  @override
  String get paymentRequiredToast =>
      'Paid access will be required to continue.';

  @override
  String get profileSaveVerificationFailed =>
      'The profile has not been confirmed by the server yet. Try again.';

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
  String userGreeting(String name) {
    return 'Hi, $name';
  }

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

  @override
  String get upgradeRequiredTitle => 'Update required';

  @override
  String get upgradeRequiredBody =>
      'This version of the app is no longer accepted by the server. Update it to keep recording your workouts.';

  @override
  String upgradeRequiredMinimum(String version) {
    return 'Minimum expected version: $version';
  }

  @override
  String get upgradeRequiredCopyLink => 'Copy store link';

  @override
  String get upgradeRequiredLinkCopied => 'Link copied to clipboard';

  @override
  String get upgradeRequiredRetry => 'Try again';
}
