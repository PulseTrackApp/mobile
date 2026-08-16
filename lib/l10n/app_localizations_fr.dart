// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'GymFlow';

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
  String get email => 'Email';

  @override
  String get emailHint => 'toi@exemple.com';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordHint => '8 caractères minimum';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get passwordResetTitle => 'Réinitialisation';

  @override
  String get passwordResetCode => 'Code reçu';

  @override
  String get passwordResetCodeHint => 'Ex : ABCD1234';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get requestResetCode => 'Recevoir le code';

  @override
  String get resetPassword => 'Changer le mot de passe';

  @override
  String get passwordResetSending => 'Envoi...';

  @override
  String get passwordResetSubmitting => 'Mise à jour...';

  @override
  String get passwordResetEmailRequired =>
      'Renseigne ton e-mail pour recevoir un code.';

  @override
  String get passwordResetRequiredFields =>
      'Renseigne l\'e-mail, le code et le nouveau mot de passe.';

  @override
  String get passwordResetCodeSent =>
      'Si ce compte existe, un code vient d\'être envoyé.';

  @override
  String get passwordResetSuccess =>
      'Mot de passe mis à jour. Tu peux te connecter.';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get changePasswordSuccess =>
      'Mot de passe changé. La session a été sécurisée.';

  @override
  String get changePasswordRequiredFields =>
      'Renseigne le mot de passe actuel et le nouveau mot de passe.';

  @override
  String get emailVerified => 'Adresse e-mail confirmée';

  @override
  String get emailNotVerified => 'Adresse e-mail non confirmée';

  @override
  String get emailVerificationTitle => 'Confirmer l\'adresse e-mail';

  @override
  String get emailVerificationBody =>
      'Saisis le code reçu par e-mail pour confirmer ton adresse.';

  @override
  String get verificationCode => 'Code de confirmation';

  @override
  String get resendVerificationCode => 'Renvoyer le code';

  @override
  String get verifyEmail => 'Confirmer l\'adresse';

  @override
  String get emailVerificationCodeSent =>
      'Si l\'adresse existe, un code vient d\'être envoyé.';

  @override
  String get emailVerificationSuccess => 'Adresse e-mail confirmée.';

  @override
  String get emailVerificationRequiredFields =>
      'Renseigne le code reçu par e-mail.';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountBody =>
      'Cette action efface définitivement le profil, les séances, les parcours, les objectifs et les données de suivi.';

  @override
  String get deleteAccountConfirmLabel =>
      'Je comprends que cette action est définitive.';

  @override
  String get deleteAccountFinalButton => 'Supprimer définitivement';

  @override
  String get deleteAccountSuccess => 'Compte supprimé.';

  @override
  String get deleteAccountRequiredFields =>
      'Renseigne ton mot de passe et confirme l\'action.';

  @override
  String get close => 'Fermer';

  @override
  String get moduleLockedTitle => 'Module verrouillé';

  @override
  String get moduleLockedShort => 'Fonctionnalité verrouillée';

  @override
  String moduleLockedBody(String module) {
    return 'Le module $module n\'est pas actif sur ce compte. Un administrateur peut l\'activer depuis l\'application desktop.';
  }

  @override
  String get moduleWorkouts => 'Séances et parcours';

  @override
  String get moduleBodyCheckins => 'Évolution physique';

  @override
  String get moduleGoals => 'Objectifs';

  @override
  String get moduleStats => 'Statistiques';

  @override
  String get moduleWeeklySummary => 'Bilan hebdomadaire';

  @override
  String get moduleCoach => 'Super Coach';

  @override
  String get moduleExport => 'Export des données';

  @override
  String get modulePush => 'Notifications';

  @override
  String get existingAccount => 'J\'ai déjà un compte';

  @override
  String get sexOptional => 'Sexe';

  @override
  String get sexOptionalHint => 'Homme ou femme';

  @override
  String get sexMale => 'Homme';

  @override
  String get sexFemale => 'Femme';

  @override
  String get ageOptional => 'Âge (optionnel)';

  @override
  String get weightKg => 'Poids (kg)';

  @override
  String get heightCm => 'Taille (cm)';

  @override
  String get mainGoal => 'Objectifs';

  @override
  String get mainGoalHint => 'Ex : perdre du poids';

  @override
  String get fitnessLevel => 'Niveau sportif';

  @override
  String get fitnessLevelHint => 'Débutant, régulier, avancé';

  @override
  String get fitnessLevelBeginner => 'Débutant';

  @override
  String get fitnessLevelIntermediate => 'Régulier';

  @override
  String get fitnessLevelAdvanced => 'Avancé';

  @override
  String get preferredSports => 'Sports principaux';

  @override
  String get preferredSportsHint => 'Course, vélo, marche';

  @override
  String get bodyIndicators => 'Indicateurs physiques';

  @override
  String get bmiPreview =>
      'L\'IMC est calculé automatiquement à partir du poids et de la taille.';

  @override
  String get bmiTitle => 'IMC estimé';

  @override
  String get bmiWaiting => 'Saisis ton poids et ta taille pour voir ton IMC.';

  @override
  String bmiValue(String value) {
    return 'IMC $value';
  }

  @override
  String get bmiHelper => 'Repère de suivi, pas un diagnostic médical.';

  @override
  String get bmiCategory => 'Catégorie';

  @override
  String get bmiCategoryUnderweight => 'Insuffisance pondérale';

  @override
  String get bmiCategoryNormal => 'Corpulence normale';

  @override
  String get bmiCategoryOverweight => 'Surpoids';

  @override
  String get bmiCategoryObese => 'Obésité';

  @override
  String get profileDataNote =>
      'Ces données servent aux calories, objectifs et conseils du Super Coach.';

  @override
  String get saveProfile => 'Sauvegarder le profil';

  @override
  String get saving => 'Sauvegarde...';

  @override
  String get requiredProfileFields =>
      'Renseigne au minimum ton pseudo, ton poids et ta taille.';

  @override
  String get requiredLoginFields => 'Renseigne ton e-mail et ton mot de passe.';

  @override
  String get existingAccountSessionMissing =>
      'La session n\'est plus active. Reconnecte-toi depuis l\'étape profil.';

  @override
  String get profileSavedApi => 'Profil sauvegardé.';

  @override
  String get apiErrorPrefix => 'Erreur :';

  @override
  String get apiUnexpectedError =>
      'Service GymFlow indisponible pour le moment.';

  @override
  String get requiredBodyCheckInFields => 'Renseigne au minimum ton poids.';

  @override
  String get checkInSavedApi => 'Check-in sauvegardé.';

  @override
  String get requiredGoalFields => 'Renseigne une cible valide.';

  @override
  String get goalSavedApi => 'Objectif sauvegardé.';

  @override
  String get createGoal => 'Créer l\'objectif';

  @override
  String get goalTargetValue => 'Valeur cible';

  @override
  String get noGoalsYet => 'Aucun objectif actif pour le moment.';

  @override
  String get coachAvailable => 'Super Coach prêt';

  @override
  String get requestWeeklyReview => 'Demander le bilan';

  @override
  String get coachQuestion => 'Question au coach';

  @override
  String get coachQuestionHint => 'Ex : que puis-je faire cette semaine ?';

  @override
  String get askCoach => 'Envoyer au coach';

  @override
  String get workoutSavedApi => 'Séance sauvegardée.';

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
  String get openWorkoutDetails => 'Voir le parcours et les moments forts';

  @override
  String get workoutDetailTitle => 'Détail séance';

  @override
  String get loadingWorkout => 'Chargement de la séance...';

  @override
  String get routeReplay => 'Parcours enregistré';

  @override
  String get workoutHighlights => 'Moments forts';

  @override
  String get routeTimeline => 'Repères du parcours';

  @override
  String get startedAtLabel => 'Départ';

  @override
  String get midRouteLabel => 'Mi-parcours';

  @override
  String get endedAtLabel => 'Arrivée';

  @override
  String get workoutDetails => 'Données de séance';

  @override
  String get gpsTraceMissing =>
      'Aucune trace GPS enregistrée pour cette séance.';

  @override
  String get shareSavedWorkout => 'Partager la séance';

  @override
  String get fastestMoment => 'Pic de vitesse';

  @override
  String get speedPeakMarker => 'Pic';

  @override
  String get midRouteMarker => 'Mi-parcours';

  @override
  String fastestMomentAt(String time) {
    return 'À $time';
  }

  @override
  String get workoutNoteEmpty => 'Aucune note pour cette séance.';

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
    return '$distance depuis le départ';
  }

  @override
  String get replayRouteAction => 'Refaire ce parcours';

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
  String get coachTitle => 'Super Coach';

  @override
  String get coachSubtitle => 'Conseils, alertes et exercices';

  @override
  String get coachHeadline => 'Analyse personnelle avec Super Coach';

  @override
  String get coachUnavailableTitle => 'Super Coach en préparation';

  @override
  String get coachUnavailableBody =>
      'Les conseils personnalisés ne sont pas encore disponibles. Réessaie un peu plus tard.';

  @override
  String get effortWarningTitle => 'Alerte effort insuffisant';

  @override
  String get effortWarningBody =>
      'Le coach comparera tes séances aux targets et te dira ce qu\'il reste à faire.';

  @override
  String get exerciseSuggestionsTitle => 'Propositions d\'exercices';

  @override
  String get exerciseSuggestionsBody =>
      'Le Super Coach pourra proposer une sortie facile, une marche rapide ou du renforcement selon ton niveau.';

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
      'Aucun conseil pour le moment. Demande un bilan pour générer ta première recommandation.';

  @override
  String get coachPreviewChecking => 'Vérification du Super Coach...';

  @override
  String get coachPreviewUnavailable =>
      'Super Coach n\'est pas encore prêt. Réessaie un peu plus tard.';

  @override
  String get coachPreviewLocked => 'Super Coach est verrouillé sur ce compte.';

  @override
  String get openMenu => 'Ouvrir le menu';

  @override
  String get draftSaved => 'Écran prêt. Prochaine étape : stockage local.';

  @override
  String get onboardingWelcomeTitle => 'Ton sport, tes stats, tes objectifs';

  @override
  String get onboardingWelcomeBody =>
      'GymFlow reste personnel : pas de réseau social, pas d\'abonnement, juste tes parcours, tes performances et ton évolution.';

  @override
  String get onboardingProfileTitle => 'Profil de départ';

  @override
  String get onboardingProfileBody =>
      'Renseigne poids, taille et niveau pour calculer des calories et des targets plus justes.';

  @override
  String get onboardingTargetsTitle => 'Targets et coach';

  @override
  String get onboardingTargetsBody =>
      'Définis ton objectif principal. Le Super Coach pourra ensuite proposer des exercices et signaler les semaines trop faibles.';

  @override
  String onboardingStep(int current, int total) {
    return 'Étape $current / $total';
  }

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingFinish => 'Entrer dans GymFlow';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingGoalLoseWeight => 'Perdre du poids';

  @override
  String get onboardingGoalEndurance => 'Améliorer l\'endurance';

  @override
  String get onboardingGoalRestart => 'Reprendre le sport';

  @override
  String get onboardingGoalRunFaster => 'Courir plus vite';

  @override
  String get onboardingGoalGoFurther => 'Faire plus de distance';

  @override
  String get onboardingGoalMaintain => 'Maintenir la forme';

  @override
  String get onboardingGoalCyclingWalking => 'Progresser en vélo ou marche';

  @override
  String get onboardingGoalOther => 'Autre';

  @override
  String get customGoal => 'Précise ton objectif';

  @override
  String get customGoalHint => 'Ex : préparer un 10 km, mieux récupérer...';

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
  String get challengeRouteGuide => 'Parcours guide';

  @override
  String get challengeModeTitle => 'Mode défi';

  @override
  String get challengeEnabled => 'Activer le défi';

  @override
  String get challengeDistanceTarget => 'Distance cible';

  @override
  String get challengeTimeLimit => 'Temps limite';

  @override
  String get challengeFieldsRequired =>
      'Renseigne une distance cible et un temps limite valides.';

  @override
  String get challengeLiveTitle => 'Défi en cours';

  @override
  String challengeProgressLabel(String distance, String target) {
    return '$distance / $target';
  }

  @override
  String challengeRemainingTime(String time) {
    return 'Reste $time';
  }

  @override
  String get challengeHalfway =>
      'Tu as déjà passé la mi-distance. Garde ce rythme.';

  @override
  String get challengeDeadlineApproaching =>
      'Échéance proche : reste concentré, tu peux finir fort.';

  @override
  String get challengeDeadlineMissed =>
      'Temps limite dépassé. Termine proprement la distance.';

  @override
  String get challengeTargetReachedTitle => 'Défi réussi';

  @override
  String get challengeTargetReachedBody =>
      'Objectif atteint dans le temps. Très belle séance.';

  @override
  String get challengeRouteReplayActive => 'Parcours à refaire actif';

  @override
  String get challengeRouteReplayBody =>
      'L\'ancien tracé est affiché sur la carte.';

  @override
  String get minutesUnit => 'min';

  @override
  String get currentLocation => 'Ma position';

  @override
  String get locationPermissionDenied =>
      'Autorise la localisation pour démarrer le tracking.';

  @override
  String get currentLocationUnavailable =>
      'Position indisponible. Vérifie l\'autorisation GPS.';

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
      'Vérifie les métriques, ajoute ton ressenti, puis sauvegarde la séance.';

  @override
  String get perceivedEffort => 'Effort perçu';

  @override
  String get feeling => 'Ressenti';

  @override
  String get feelingGreat => 'Excellent';

  @override
  String get feelingGood => 'Bon';

  @override
  String get feelingOk => 'Correct';

  @override
  String get feelingTired => 'Fatigué';

  @override
  String get feelingExhausted => 'Épuisé';

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
  String get maxSpeed => 'Pic de vitesse';

  @override
  String get shareWorkoutImage => 'Partager l\'image';

  @override
  String get sharingWorkoutImage => 'Préparation de l\'image...';

  @override
  String get shareWorkoutTitle => 'Ma séance GymFlow';

  @override
  String get shareWorkoutChoiceTitle => 'Que veux-tu partager ?';

  @override
  String get shareRouteOnlyTitle => 'Carte seule';

  @override
  String get shareRouteOnlySubtitle =>
      'Le parcours, les repères et les pics de vitesse.';

  @override
  String get shareRouteWithDataTitle => 'Carte + données';

  @override
  String get shareRouteWithDataSubtitle =>
      'Parcours, distance, chrono, allure et vitesse.';

  @override
  String get shareRouteOnlyText => 'Mon parcours GymFlow';

  @override
  String get shareWorkoutUnavailable =>
      'Impossible de préparer l\'image pour le moment.';

  @override
  String get workoutAppreciationTitle => 'Appréciation GymFlow';

  @override
  String workoutScore(int score) {
    return '$score/100';
  }

  @override
  String get workoutRatingExcellent => 'Performance excellente';

  @override
  String get workoutRatingGood => 'Très bonne séance';

  @override
  String get workoutRatingOk => 'Séance utile';

  @override
  String get workoutRatingLow => 'Base posée';

  @override
  String get workoutRatingRecordBody =>
      'Tu as dépassé une référence personnelle. On garde cette dynamique.';

  @override
  String get workoutRatingChallengeBody =>
      'Tu as respecté ton défi : objectif clair, exécution propre.';

  @override
  String get workoutRatingGoodBody =>
      'Le volume et le rythme vont dans le bon sens. Continue comme ça.';

  @override
  String get workoutRatingOkBody =>
      'Séance validée. La prochaine étape : un peu plus de régularité ou de distance.';

  @override
  String get workoutRatingLowBody =>
      'Même courte, une séance compte. Repars simple et régulier.';

  @override
  String get workoutChallengeCompletedBadge => 'Défi réussi';

  @override
  String workoutChallengeProgressBadge(int percent) {
    return '$percent% du défi';
  }

  @override
  String get workoutDistanceRecordBadge => 'Record distance';

  @override
  String get workoutPaceRecordBadge => 'Record allure';

  @override
  String get recordCelebrationTitle => 'Nouveau record';

  @override
  String get distanceRecordCelebrationBody =>
      'Tu viens de dépasser ta plus longue distance.';

  @override
  String get paceRecordCelebrationBody =>
      'Tu viens d\'améliorer ta meilleure allure.';

  @override
  String get notConnectedYet =>
      'GPS actif. Tu peux mettre en pause, reprendre ou terminer la séance.';

  @override
  String get confirmPauseTitle => 'Mettre la séance en pause ?';

  @override
  String get confirmPauseBody =>
      'Le chrono actif s\'arrête et la trace reprend quand tu relances.';

  @override
  String get confirmPauseAction => 'Mettre en pause';

  @override
  String get confirmFinishTitle => 'Terminer la séance ?';

  @override
  String get confirmFinishBody =>
      'Tu vas quitter le suivi en direct et passer au résumé. Vérifie que la séance est bien finie.';

  @override
  String get confirmFinishAction => 'Terminer';

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
  String get weeklyGoalReached =>
      'Objectif atteint. Tu peux consolider ou viser un bonus.';

  @override
  String get weeklyGoalAlmost =>
      'Presque terminé. Une petite sortie peut boucler la semaine.';

  @override
  String get weeklyGoalStrong => 'Très bien parti. Continue sur ce rythme.';

  @override
  String weeklyGoalRemaining(String distance) {
    return 'Il reste $distance cette semaine.';
  }

  @override
  String get weeklyGoalNoTarget =>
      'Ajoute un objectif pour suivre ta progression.';

  @override
  String get goalNeedsWork =>
      'Encore loin de la cible. Une séance courte peut déjà relancer la progression.';

  @override
  String get performance => 'Performance';

  @override
  String get record5k => 'Record 5 km';

  @override
  String get averagePace => 'Allure moyenne';

  @override
  String get completedGoals => 'Objectifs terminés';

  @override
  String get pricingTitle => 'Pricing';

  @override
  String get pricingSubtitle =>
      'Les offres GymFlow arrivent bientôt. Préparation des accès et modules.';

  @override
  String get pricingComingSoon => 'À venir';

  @override
  String get pricingRequiredTitle => 'Paiement requis';

  @override
  String get pricingRequiredBody =>
      'Ton accès doit être activé pour continuer à utiliser ces fonctionnalités.';

  @override
  String get pricingRetryAccess => 'Vérifier l\'accès';

  @override
  String get pricingPlanEssential => 'Essentiel';

  @override
  String get pricingPlanPerformance => 'Performance';

  @override
  String get pricingPlanCoach => 'Super Coach';

  @override
  String get pricingFeatureTracking =>
      'Tracking GPS, pause et résumé de séance';

  @override
  String get pricingFeatureStats => 'Stats semaine, mois et année';

  @override
  String get pricingFeatureHistory => 'Historique et parcours enregistrés';

  @override
  String get pricingFeatureChallenges => 'Défis distance + temps';

  @override
  String get pricingFeatureRouteReplay => 'Refaire un parcours déjà enregistré';

  @override
  String get pricingFeatureExports => 'Partage carte seule ou carte + données';

  @override
  String get pricingFeatureCoach => 'Conseils personnalisés';

  @override
  String get pricingFeatureWeeklyReview => 'Bilan hebdomadaire';

  @override
  String get pricingFeatureMotivation => 'Motivations et félicitations';

  @override
  String get sessionExpiredToast =>
      'Ta session a expiré. Reconnecte-toi pour continuer.';

  @override
  String get paymentRequiredToast =>
      'Un accès payant sera requis pour continuer.';

  @override
  String get profileSaveVerificationFailed =>
      'Le profil n\'a pas encore été confirmé par le serveur. Réessaie.';

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
  String get settingsAccount => 'Compte';

  @override
  String get account => 'Compte connecté';

  @override
  String userGreeting(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get connectedAccount => 'Compte connecté à GymFlow.';

  @override
  String connectedAs(String email) {
    return 'Connecté avec $email';
  }

  @override
  String get signOut => 'Déconnexion';

  @override
  String get signedOut => 'Tu es déconnecté.';

  @override
  String get decrease => 'Diminuer';

  @override
  String get increase => 'Augmenter';

  @override
  String get upgradeRequiredTitle => 'Mise à jour requise';

  @override
  String get upgradeRequiredBody =>
      'Cette version de l\'application n\'est plus acceptée par le serveur. Mets-la à jour pour continuer à enregistrer tes séances.';

  @override
  String upgradeRequiredMinimum(String version) {
    return 'Version minimale attendue : $version';
  }

  @override
  String get upgradeRequiredCopyLink => 'Copier le lien du magasin';

  @override
  String get upgradeRequiredLinkCopied => 'Lien copié dans le presse-papiers';

  @override
  String get upgradeRequiredRetry => 'Réessayer';

  @override
  String get routesTitle => 'Parcours';

  @override
  String get routesSubtitle =>
      'Tes circuits enregistrés, à reprendre quand tu veux';

  @override
  String get routesEmpty =>
      'Aucun parcours pour l\'instant. Enregistre le tracé d\'une séance depuis son détail pour pouvoir le reprendre.';

  @override
  String get routeLoop => 'Boucle';

  @override
  String get routeOneWay => 'Aller simple';

  @override
  String routeAttempts(int count) {
    return '$count passage(s)';
  }

  @override
  String routeBestTime(String time) {
    return 'Meilleur temps : $time';
  }

  @override
  String get routeNeverRun => 'Jamais rejoué';

  @override
  String get routeAttemptsTitle => 'Passages';

  @override
  String get routeAttemptsEmpty => 'Ce circuit n\'a pas encore été rejoué.';

  @override
  String routeRank(int rank) {
    return '$rankᵉ';
  }

  @override
  String get routeDelete => 'Supprimer le parcours';

  @override
  String get routeDeleteConfirm =>
      'Supprimer ce parcours ? Les séances qui le rejouaient sont conservées, elles perdent seulement leur rattachement.';

  @override
  String get routeRename => 'Renommer';

  @override
  String get routeNameLabel => 'Nom du parcours';

  @override
  String get challengesTitle => 'Défis';

  @override
  String get challengesSubtitle => 'Parcourir telle distance en tel temps';

  @override
  String get challengesEmpty =>
      'Aucun défi pour l\'instant. Fixe-t\'en un : c\'est ce qui donne une raison de sortir aujourd\'hui plutôt que demain.';

  @override
  String get challengeCreate => 'Créer le défi';

  @override
  String get challengeDistanceLabel => 'Distance (km)';

  @override
  String get challengeMinutesLabel => 'Temps (minutes)';

  @override
  String challengeRequiredPace(String pace) {
    return 'Allure à tenir : $pace';
  }

  @override
  String get challengeStart => 'Démarrer';

  @override
  String get challengeAbandon => 'Abandonner';

  @override
  String get challengeAbandonConfirm =>
      'Abandonner ce défi ? Ce n\'est ni une réussite ni un échec, et cela libère la place pour un autre.';

  @override
  String get challengeDelete => 'Supprimer';

  @override
  String get challengeStatusDraft => 'À relever';

  @override
  String get challengeStatusActive => 'En cours';

  @override
  String get challengeStatusSucceeded => 'Relevé';

  @override
  String get challengeStatusFailed => 'Manqué';

  @override
  String get challengeStatusAbandoned => 'Abandonné';

  @override
  String get challengeStatusExpired => 'Expiré';

  @override
  String get challengeInvalidTarget => 'Indique une distance et un temps.';

  @override
  String get challengeAlreadyRunning =>
      'Un défi est déjà en cours. Termine-le ou abandonne-le d\'abord.';

  @override
  String get ratingTitle => 'Ma note';

  @override
  String get ratingSubtitle => 'Sur les quatre dernières semaines';

  @override
  String ratingWindow(int days) {
    return 'Sur $days jours';
  }

  @override
  String ratingStreak(int days) {
    return '$days jour(s) d\'affilée';
  }

  @override
  String get ratingTrendUp => 'En progrès';

  @override
  String get ratingTrendFlat => 'Stable';

  @override
  String get ratingTrendDown => 'En baisse';

  @override
  String ratingNextTier(int points, String tier) {
    return 'Encore $points points pour le palier $tier';
  }

  @override
  String get ratingComponents => 'Le détail';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get routeSaveAction => 'Enregistrer ce parcours';

  @override
  String get routeSaved => 'Parcours enregistré';

  @override
  String subscriptionTrialDays(int days) {
    return 'Il te reste $days jour(s) d\'essai';
  }

  @override
  String get subscriptionUnknown => 'Accès en cours de vérification';

  @override
  String updateAvailableBanner(String version) {
    return 'Une version plus récente est disponible ($version). Mets l\'application à jour quand tu peux.';
  }

  @override
  String get updateAvailableAction => 'Mettre à jour';

  @override
  String get weekCalendarTitle => 'Ta semaine';

  @override
  String weekCalendarDaysDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours de sport',
      one: '1 jour de sport',
      zero: 'Aucun jour de sport',
    );
    return '$_temp0';
  }

  @override
  String weekCalendarStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours d\'affilée',
      one: '1 jour d\'affilée',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get weekCalendarBestTitle => 'Meilleure perf';

  @override
  String get weekCalendarNoBest =>
      'Aucun record pour l\'instant. La première séance en posera un.';

  @override
  String get weekCalendarToday => 'Aujourd\'hui';

  @override
  String get menuHelpSection => 'Aide et compte';

  @override
  String get supportTitle => 'Aide et support';

  @override
  String get supportSubtitle => 'Poser une question, signaler un souci';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutSubtitle => 'Version de l\'application et éditeur';

  @override
  String get legalTitle => 'Mentions légales';

  @override
  String get legalSubtitle => 'Confidentialité et conditions d\'utilisation';

  @override
  String get deleteAccountMenuSubtitle =>
      'Effacer définitivement ton compte et tes données';

  @override
  String get supportIntro =>
      'Décris ce que tu faisais au moment du problème et joins les informations ci-dessous : elles suffisent presque toujours à retrouver la cause.';

  @override
  String get supportContactTitle => 'Nous écrire';

  @override
  String get supportCopyEmail => 'Copier l\'adresse';

  @override
  String get supportEmailCopied => 'Adresse copiée.';

  @override
  String get supportDiagnosticsTitle => 'Informations à joindre';

  @override
  String get supportFaqTitle => 'Questions fréquentes';

  @override
  String get supportFaqGpsQuestion =>
      'Ma trace GPS est en dents de scie ou s\'arrête';

  @override
  String get supportFaqGpsAnswer =>
      'Le GPS a besoin du ciel dégagé et de l\'autorisation de localisation en arrière-plan. Vérifie aussi que l\'économiseur de batterie n\'a pas mis GymFlow en veille : c\'est la cause la plus fréquente d\'une trace coupée en plein milieu.';

  @override
  String get supportFaqStatsQuestion => 'Mes statistiques semblent fausses';

  @override
  String get supportFaqStatsAnswer =>
      'Les distances sont filtrées pour écarter le bruit du GPS, si bien qu\'elles sont souvent un peu plus courtes que celles d\'une montre qui ne filtre pas. Si l\'écart dépasse quelques pour cent, écris-nous avec la date de la séance.';

  @override
  String get supportFaqLockedQuestion =>
      'Une fonction est marquée « verrouillée »';

  @override
  String get supportFaqLockedAnswer =>
      'Certaines fonctions s\'ouvrent compte par compte. Ce n\'est pas une panne : demande simplement l\'ouverture par courriel.';

  @override
  String get supportFaqDataQuestion =>
      'Comment récupérer ou effacer mes données ?';

  @override
  String get supportFaqDataAnswer =>
      'L\'export se lance depuis les réglages et te renvoie l\'intégralité de tes séances. La suppression du compte est définitive et efface tout : exporte avant si tu veux garder une trace.';

  @override
  String get aboutIntro =>
      'GymFlow enregistre tes séances, en tire des statistiques et t\'aide à tenir tes objectifs.';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutBuildLabel => 'Build';

  @override
  String get aboutAccountLabel => 'Compte';

  @override
  String get aboutServerLabel => 'Serveur';

  @override
  String get aboutPublisherTitle => 'Éditeur';

  @override
  String get aboutPublisherBody => 'Liceli Technologies';

  @override
  String get aboutOpenSourceTitle => 'Logiciels utilisés';

  @override
  String get aboutOpenSourceButton => 'Voir les licences';

  @override
  String get legalDraftNotice =>
      'Ce texte décrit fidèlement ce que fait l\'application, mais il n\'a pas encore été relu par un juriste. À faire avant toute publication.';

  @override
  String get legalDataTitle => 'Ce que l\'application enregistre';

  @override
  String get legalDataBody =>
      'Ton adresse électronique et ton mot de passe, sous forme chiffrée, pour te reconnaître. Tes séances : durée, distance, tracé GPS, dénivelé et dépense estimée. Tes pesées et tes objectifs, si tu en saisis. Un identifiant d\'appareil, uniquement si tu acceptes les notifications.';

  @override
  String get legalUsageTitle => 'Ce qu\'on en fait';

  @override
  String get legalUsageBody =>
      'Ces données servent à t\'afficher tes propres statistiques, tes records et tes bilans. Elles ne sont ni vendues, ni cédées, ni utilisées pour de la publicité. Personne d\'autre que toi ne voit tes séances.';

  @override
  String get legalHostingTitle => 'Hébergement';

  @override
  String get legalHostingBody =>
      'Les données sont hébergées sur un serveur loué par l\'éditeur, en Europe, et les échanges avec l\'application sont chiffrés.';

  @override
  String get legalRightsTitle => 'Tes droits';

  @override
  String get legalRightsBody =>
      'Tu peux exporter l\'intégralité de tes données depuis les réglages, à tout moment et sans rien demander. Tu peux supprimer ton compte depuis l\'application : la suppression est immédiate et définitive, sauvegardes comprises. Pour toute autre demande, écris-nous.';

  @override
  String get legalTermsTitle => 'Conditions d\'utilisation';

  @override
  String get legalTermsBody =>
      'GymFlow est une aide à l\'entraînement, pas un dispositif médical. Les distances, allures et dépenses affichées sont des estimations. En cas de doute sur ton état de santé, demande un avis médical avant de reprendre le sport.';

  @override
  String get legalContactTitle => 'Nous contacter';

  @override
  String get deleteAccountScreenIntro =>
      'Supprimer ton compte efface définitivement tes séances, tes tracés, tes pesées, tes objectifs et tes records. Rien n\'est conservé et rien n\'est récupérable.';

  @override
  String get deleteAccountExportFirst =>
      'Si tu veux garder une trace de ton historique, exporte tes données depuis les réglages avant de continuer.';

  @override
  String get supportCopyDiagnostics => 'Copier ces informations';

  @override
  String get supportDiagnosticsCopied => 'Informations copiées.';
}
