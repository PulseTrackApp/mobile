// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'PulseTrack';

  @override
  String get settings => 'Paramètres';

  @override
  String get homeTab => 'Accueil';

  @override
  String get activityTab => 'Activité';

  @override
  String get statsTab => 'Stats';

  @override
  String get menuTab => 'Menu';

  @override
  String get menuTitle => 'Menu';

  @override
  String get settingsSubtitle => 'Thème, langue, GPS et confidentialité';

  @override
  String get profileTitle => 'Profil initial';

  @override
  String get profileSubtitle => 'Poids, taille, objectif et niveau';

  @override
  String get profileHeadline => 'Tes données de départ';

  @override
  String get displayName => 'Pseudo';

  @override
  String get displayNameHint => 'Ex : Jayson';

  @override
  String get sexOptional => 'Sexe (optionnel)';

  @override
  String get sexOptionalHint => 'Homme, femme ou libre';

  @override
  String get ageOptional => 'Âge (optionnel)';

  @override
  String get weightKg => 'Poids (kg)';

  @override
  String get heightCm => 'Taille (cm)';

  @override
  String get mainGoal => 'Objectif principal';

  @override
  String get mainGoalHint => 'Ex : perdre du poids';

  @override
  String get fitnessLevel => 'Niveau sportif';

  @override
  String get fitnessLevelHint => 'Débutant, régulier, avancé';

  @override
  String get preferredSports => 'Sports principaux';

  @override
  String get preferredSportsHint => 'Course, vélo, marche';

  @override
  String get bodyIndicators => 'Indicateurs physiques';

  @override
  String get bmiPreview =>
      'L\'IMC sera calculé automatiquement quand le profil sera sauvegardé.';

  @override
  String get profileDataNote =>
      'Ces données servent aux calories, objectifs et conseils Gemini.';

  @override
  String get saveProfile => 'Sauvegarder le profil';

  @override
  String get bodyProgressTitle => 'Évolution physique';

  @override
  String get bodyProgressSubtitle => 'Check-in hebdo, poids et mensurations';

  @override
  String get weeklyCheckIn => 'Check-in de la semaine';

  @override
  String get currentWeight => 'Poids actuel';

  @override
  String get weeklyChange => 'Variation';

  @override
  String get waistCm => 'Tour de taille (cm)';

  @override
  String get chestCm => 'Tour de poitrine (cm)';

  @override
  String get hipsCm => 'Tour de hanches (cm)';

  @override
  String get energyLevel => 'Énergie ressentie';

  @override
  String get sleepHours => 'Sommeil moyen (h)';

  @override
  String get weeklyNote => 'Note de la semaine';

  @override
  String get weeklyNoteHint => 'Fatigue, douleurs, motivation...';

  @override
  String get bodyTrendTitle => 'Tendance physique';

  @override
  String get bodyTrendEmpty =>
      'Les courbes apparaîtront après tes premiers check-ins.';

  @override
  String get saveCheckIn => 'Sauvegarder le check-in';

  @override
  String get workoutHistoryTitle => 'Historique';

  @override
  String get workoutHistorySubtitle => 'Séances, calories et parcours';

  @override
  String get sessionsOverview => 'Vue d\'ensemble des séances';

  @override
  String get caloriesBurned => 'Calories brûlées';

  @override
  String get totalDistance => 'Distance totale';

  @override
  String get movingTime => 'Temps actif';

  @override
  String get recentSessions => 'Séances récentes';

  @override
  String get noSessionsYet => 'Aucune séance enregistrée pour le moment.';

  @override
  String get filters => 'Filtres';

  @override
  String get goalsTitle => 'Targets';

  @override
  String get goalsSubtitle => 'Objectifs semaine et performance';

  @override
  String get targetsHeadline => 'Tes objectifs actifs';

  @override
  String get weeklyDistanceTarget => 'Distance hebdomadaire';

  @override
  String get weeklySessionsTarget => 'Séances par semaine';

  @override
  String get weeklyCaloriesTarget => 'Calories sportives';

  @override
  String get weeklyTrainingTimeTarget => 'Temps d\'entraînement';

  @override
  String get weightTarget => 'Poids cible';

  @override
  String get performanceTarget => 'Performance cible';

  @override
  String get coachTitle => 'Coach Gemini';

  @override
  String get coachSubtitle => 'Conseils, alertes et exercices';

  @override
  String get coachHeadline => 'Analyse personnelle avec Gemini';

  @override
  String get geminiApiKey => 'Gemini côté backend';

  @override
  String get geminiApiKeyHint => 'Variable d\'environnement backend';

  @override
  String get geminiPrivacyNote =>
      'La clé API Gemini est stockée uniquement dans les variables d\'environnement du backend. Le mobile ne l\'affiche pas et ne la sauvegarde jamais.';

  @override
  String get saveGeminiKey => 'Configuration backend';

  @override
  String get geminiBackendStatusTitle => 'Clé gérée par l\'API';

  @override
  String get geminiBackendStatusBody =>
      'Flutter appellera le backend pour obtenir les conseils. Le backend utilisera sa variable d\'environnement GEMINI_API_KEY.';

  @override
  String get effortWarningTitle => 'Alerte effort insuffisant';

  @override
  String get effortWarningBody =>
      'Le coach comparera tes séances aux targets et te dira ce qu\'il reste à faire.';

  @override
  String get exerciseSuggestionsTitle => 'Propositions d\'exercices';

  @override
  String get exerciseSuggestionsBody =>
      'Gemini pourra proposer une sortie facile, une marche rapide ou du renforcement selon ton niveau.';

  @override
  String get weeklyReviewTitle => 'Bilan hebdomadaire';

  @override
  String get weeklyReviewBody =>
      'Chaque semaine, l\'app analysera progression, calories, poids et récupération.';

  @override
  String get physicalProgress => 'Progression physique';

  @override
  String get profileMissing =>
      'Ajoute ton poids et ta taille pour calculer calories et tendances.';

  @override
  String get caloriesThisWeek => 'Calories semaine';

  @override
  String get coachPreview => 'Conseil coach';

  @override
  String get coachPreviewEmpty =>
      'Configure Gemini pour recevoir des propositions d\'exercices.';

  @override
  String get openMenu => 'Ouvrir le menu';

  @override
  String get draftSaved => 'Écran prêt. Prochaine étape : stockage local.';

  @override
  String get onboardingWelcomeTitle => 'Ton sport, tes stats, tes objectifs';

  @override
  String get onboardingWelcomeBody =>
      'PulseTrack reste personnel : pas de réseau social, pas d\'abonnement, juste tes parcours, tes performances et ton évolution.';

  @override
  String get onboardingProfileTitle => 'Profil de départ';

  @override
  String get onboardingProfileBody =>
      'Renseigne poids, taille et niveau pour calculer des calories et des targets plus justes.';

  @override
  String get onboardingTargetsTitle => 'Targets et coach';

  @override
  String get onboardingTargetsBody =>
      'Définis ton objectif principal. Gemini pourra ensuite proposer des exercices et signaler les semaines trop faibles.';

  @override
  String onboardingStep(int current, int total) {
    return 'Étape $current / $total';
  }

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingFinish => 'Entrer dans PulseTrack';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingGoalLoseWeight => 'Perdre du poids';

  @override
  String get onboardingGoalEndurance => 'Améliorer l\'endurance';

  @override
  String get onboardingGoalRestart => 'Reprendre le sport';

  @override
  String get onboardingGoalMaintain => 'Maintenir la forme';

  @override
  String get onboardingFavoriteSport => 'Sport favori';

  @override
  String get onboardingWeeklyTarget => 'Target semaine';

  @override
  String get activityReadyTitle => 'Prêt à lancer';

  @override
  String get activityReadyBody =>
      'Choisis ton sport, attends le signal GPS, puis démarre la séance.';

  @override
  String get trackingTitle => 'Tracking';

  @override
  String get gpsWaiting => 'GPS en attente';

  @override
  String get gpsReady => 'GPS prêt';

  @override
  String get liveSession => 'Séance en cours';

  @override
  String get pausedSession => 'Séance en pause';

  @override
  String get elapsedTime => 'Chrono';

  @override
  String get currentSpeed => 'Vitesse';

  @override
  String get elevation => 'Dénivelé';

  @override
  String get estimatedCalories => 'Calories estimées';

  @override
  String get routePreview => 'Aperçu parcours';

  @override
  String get liveRoute => 'Parcours en direct';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get finish => 'Terminer';

  @override
  String get sessionSummaryTitle => 'Résumé séance';

  @override
  String get workoutSavedDraft =>
      'Séance prête à sauvegarder quand l\'API sera branchée.';

  @override
  String get perceivedEffort => 'Effort perçu';

  @override
  String get feeling => 'Ressenti';

  @override
  String get sessionNote => 'Note de séance';

  @override
  String get sessionNotesHint => 'Comment tu t\'es senti ?';

  @override
  String get saveWorkout => 'Sauvegarder la séance';

  @override
  String get routePoints => 'Points GPS';

  @override
  String get averageSpeed => 'Vitesse moyenne';

  @override
  String get notConnectedYet => 'Pas encore branché au GPS réel';

  @override
  String get statsThisWeek => 'Cette semaine';

  @override
  String get statsThisMonth => 'Ce mois';

  @override
  String get statsThisYear => 'Cette année';

  @override
  String get statsPeriodWeek => 'Semaine';

  @override
  String get statsPeriodMonth => 'Mois';

  @override
  String get statsPeriodYear => 'Année';

  @override
  String get statsOverview => 'Vue d\'ensemble';

  @override
  String get statsTrend => 'Tendance';

  @override
  String get statsEmptyPeriod =>
      'Les statistiques apparaîtront après tes premières séances sauvegardées.';

  @override
  String get sessions => 'Séances';

  @override
  String get activeDays => 'Jours actifs';

  @override
  String get bestPace => 'Meilleure allure';

  @override
  String get longestDistance => 'Plus longue distance';

  @override
  String get readyForNextSession => 'Prêt pour la prochaine session ?';

  @override
  String get run => 'Course';

  @override
  String get ride => 'Vélo';

  @override
  String get walk => 'Marche';

  @override
  String get startWorkout => 'Démarrer une session';

  @override
  String get start => 'Démarrer';

  @override
  String get todayDistance => '0.00 km aujourd\'hui';

  @override
  String get distance => 'Distance';

  @override
  String get time => 'Temps';

  @override
  String get pace => 'Allure';

  @override
  String get weeklyGoal => 'Objectif semaine';

  @override
  String get weeklyGoalProgress => '0 / 20 km';

  @override
  String get performance => 'Performance';

  @override
  String get record5k => 'Record 5 km';

  @override
  String get averagePace => 'Allure moyenne';

  @override
  String get completedGoals => 'Objectifs terminés';

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
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageFrench => 'FR';

  @override
  String get languageEnglish => 'EN';

  @override
  String get settingsSport => 'Sport';

  @override
  String get settingsUnits => 'Unités';

  @override
  String get unitsMetric => 'km';

  @override
  String get unitsImperial => 'mi';

  @override
  String get defaultSport => 'Sport par défaut';

  @override
  String weeklyTargetValue(int value) {
    return '$value km par semaine';
  }

  @override
  String get settingsTracking => 'Tracking';

  @override
  String get gpsAccuracy => 'Précision GPS';

  @override
  String get gpsBalanced => 'Éco';

  @override
  String get gpsHigh => 'Précise';

  @override
  String get gpsBest => 'Max';

  @override
  String get autoPause => 'Pause auto';

  @override
  String get autoPauseDescription =>
      'Met la session en pause quand tu t\'arrêtes.';

  @override
  String get countdown => 'Compte à rebours';

  @override
  String get countdownDescription => 'Ajoute 3 secondes avant le départ.';

  @override
  String get voiceCues => 'Annonces vocales';

  @override
  String get voiceCuesDescription =>
      'Annonce les temps et distances pendant la session.';

  @override
  String get keepScreenAwake => 'Écran actif';

  @override
  String get keepScreenAwakeDescription =>
      'Garde l\'écran allumé pendant le tracking.';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get saveRoutes => 'Sauver les parcours';

  @override
  String get saveRoutesDescription =>
      'Conserve les points GPS pour revoir la trace.';

  @override
  String get privateActivities => 'Activités privées';

  @override
  String get privateActivitiesDescription =>
      'Garde les sessions visibles seulement par toi.';

  @override
  String get decrease => 'Diminuer';

  @override
  String get increase => 'Augmenter';
}
