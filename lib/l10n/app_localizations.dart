import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'GymFlow'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @homeTab.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get homeTab;

  /// No description provided for @activityTab.
  ///
  /// In fr, this message translates to:
  /// **'Activité'**
  String get activityTab;

  /// No description provided for @statsTab.
  ///
  /// In fr, this message translates to:
  /// **'Stats'**
  String get statsTab;

  /// No description provided for @menuTab.
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get menuTab;

  /// No description provided for @menuTitle.
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Thème, langue, GPS et confidentialité'**
  String get settingsSubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil initial'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Poids, taille, objectif et niveau'**
  String get profileSubtitle;

  /// No description provided for @profileHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Tes données de départ'**
  String get profileHeadline;

  /// No description provided for @displayName.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo'**
  String get displayName;

  /// No description provided for @displayNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Jayson'**
  String get displayNameHint;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In fr, this message translates to:
  /// **'toi@exemple.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum'**
  String get passwordHint;

  /// No description provided for @showPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get hidePassword;

  /// No description provided for @existingAccount.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà un compte'**
  String get existingAccount;

  /// No description provided for @sexOptional.
  ///
  /// In fr, this message translates to:
  /// **'Sexe (optionnel)'**
  String get sexOptional;

  /// No description provided for @sexOptionalHint.
  ///
  /// In fr, this message translates to:
  /// **'Homme, femme ou libre'**
  String get sexOptionalHint;

  /// No description provided for @ageOptional.
  ///
  /// In fr, this message translates to:
  /// **'Âge (optionnel)'**
  String get ageOptional;

  /// No description provided for @weightKg.
  ///
  /// In fr, this message translates to:
  /// **'Poids (kg)'**
  String get weightKg;

  /// No description provided for @heightCm.
  ///
  /// In fr, this message translates to:
  /// **'Taille (cm)'**
  String get heightCm;

  /// No description provided for @mainGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs'**
  String get mainGoal;

  /// No description provided for @mainGoalHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : perdre du poids'**
  String get mainGoalHint;

  /// No description provided for @fitnessLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau sportif'**
  String get fitnessLevel;

  /// No description provided for @fitnessLevelHint.
  ///
  /// In fr, this message translates to:
  /// **'Débutant, régulier, avancé'**
  String get fitnessLevelHint;

  /// No description provided for @fitnessLevelBeginner.
  ///
  /// In fr, this message translates to:
  /// **'Débutant'**
  String get fitnessLevelBeginner;

  /// No description provided for @fitnessLevelIntermediate.
  ///
  /// In fr, this message translates to:
  /// **'Régulier'**
  String get fitnessLevelIntermediate;

  /// No description provided for @fitnessLevelAdvanced.
  ///
  /// In fr, this message translates to:
  /// **'Avancé'**
  String get fitnessLevelAdvanced;

  /// No description provided for @preferredSports.
  ///
  /// In fr, this message translates to:
  /// **'Sports principaux'**
  String get preferredSports;

  /// No description provided for @preferredSportsHint.
  ///
  /// In fr, this message translates to:
  /// **'Course, vélo, marche'**
  String get preferredSportsHint;

  /// No description provided for @bodyIndicators.
  ///
  /// In fr, this message translates to:
  /// **'Indicateurs physiques'**
  String get bodyIndicators;

  /// No description provided for @bmiPreview.
  ///
  /// In fr, this message translates to:
  /// **'L\'IMC est calculé automatiquement à partir du poids et de la taille.'**
  String get bmiPreview;

  /// No description provided for @bmiTitle.
  ///
  /// In fr, this message translates to:
  /// **'IMC estimé'**
  String get bmiTitle;

  /// No description provided for @bmiWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ton poids et ta taille pour voir ton IMC.'**
  String get bmiWaiting;

  /// No description provided for @bmiValue.
  ///
  /// In fr, this message translates to:
  /// **'IMC {value}'**
  String bmiValue(String value);

  /// No description provided for @bmiHelper.
  ///
  /// In fr, this message translates to:
  /// **'Repère de suivi, pas un diagnostic médical.'**
  String get bmiHelper;

  /// No description provided for @bmiCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get bmiCategory;

  /// No description provided for @bmiCategoryUnderweight.
  ///
  /// In fr, this message translates to:
  /// **'Insuffisance pondérale'**
  String get bmiCategoryUnderweight;

  /// No description provided for @bmiCategoryNormal.
  ///
  /// In fr, this message translates to:
  /// **'Corpulence normale'**
  String get bmiCategoryNormal;

  /// No description provided for @bmiCategoryOverweight.
  ///
  /// In fr, this message translates to:
  /// **'Surpoids'**
  String get bmiCategoryOverweight;

  /// No description provided for @bmiCategoryObese.
  ///
  /// In fr, this message translates to:
  /// **'Obésité'**
  String get bmiCategoryObese;

  /// No description provided for @profileDataNote.
  ///
  /// In fr, this message translates to:
  /// **'Ces données servent aux calories, objectifs et conseils Gemini.'**
  String get profileDataNote;

  /// No description provided for @saveProfile.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder le profil'**
  String get saveProfile;

  /// No description provided for @saving.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde...'**
  String get saving;

  /// No description provided for @requiredProfileFields.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne au minimum email, mot de passe, pseudo, poids et taille.'**
  String get requiredProfileFields;

  /// No description provided for @profileSavedApi.
  ///
  /// In fr, this message translates to:
  /// **'Profil sauvegardé sur l\'API.'**
  String get profileSavedApi;

  /// No description provided for @apiErrorPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Erreur API :'**
  String get apiErrorPrefix;

  /// No description provided for @apiUnexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre l\'API pour le moment.'**
  String get apiUnexpectedError;

  /// No description provided for @requiredBodyCheckInFields.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne au minimum ton poids.'**
  String get requiredBodyCheckInFields;

  /// No description provided for @checkInSavedApi.
  ///
  /// In fr, this message translates to:
  /// **'Check-in sauvegardé sur l\'API.'**
  String get checkInSavedApi;

  /// No description provided for @requiredGoalFields.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne une cible valide.'**
  String get requiredGoalFields;

  /// No description provided for @goalSavedApi.
  ///
  /// In fr, this message translates to:
  /// **'Objectif sauvegardé sur l\'API.'**
  String get goalSavedApi;

  /// No description provided for @createGoal.
  ///
  /// In fr, this message translates to:
  /// **'Créer l\'objectif'**
  String get createGoal;

  /// No description provided for @goalTargetValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur cible'**
  String get goalTargetValue;

  /// No description provided for @noGoalsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun objectif actif pour le moment.'**
  String get noGoalsYet;

  /// No description provided for @coachAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Coach disponible'**
  String get coachAvailable;

  /// No description provided for @requestWeeklyReview.
  ///
  /// In fr, this message translates to:
  /// **'Demander le bilan'**
  String get requestWeeklyReview;

  /// No description provided for @coachQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Question au coach'**
  String get coachQuestion;

  /// No description provided for @coachQuestionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : que puis-je faire cette semaine ?'**
  String get coachQuestionHint;

  /// No description provided for @askCoach.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer au coach'**
  String get askCoach;

  /// No description provided for @workoutSavedApi.
  ///
  /// In fr, this message translates to:
  /// **'Séance sauvegardée sur l\'API.'**
  String get workoutSavedApi;

  /// No description provided for @bodyProgressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Évolution physique'**
  String get bodyProgressTitle;

  /// No description provided for @bodyProgressSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Check-in hebdo, poids et mensurations'**
  String get bodyProgressSubtitle;

  /// No description provided for @weeklyCheckIn.
  ///
  /// In fr, this message translates to:
  /// **'Check-in de la semaine'**
  String get weeklyCheckIn;

  /// No description provided for @currentWeight.
  ///
  /// In fr, this message translates to:
  /// **'Poids actuel'**
  String get currentWeight;

  /// No description provided for @weeklyChange.
  ///
  /// In fr, this message translates to:
  /// **'Variation'**
  String get weeklyChange;

  /// No description provided for @waistCm.
  ///
  /// In fr, this message translates to:
  /// **'Tour de taille (cm)'**
  String get waistCm;

  /// No description provided for @chestCm.
  ///
  /// In fr, this message translates to:
  /// **'Tour de poitrine (cm)'**
  String get chestCm;

  /// No description provided for @hipsCm.
  ///
  /// In fr, this message translates to:
  /// **'Tour de hanches (cm)'**
  String get hipsCm;

  /// No description provided for @energyLevel.
  ///
  /// In fr, this message translates to:
  /// **'Énergie ressentie'**
  String get energyLevel;

  /// No description provided for @sleepHours.
  ///
  /// In fr, this message translates to:
  /// **'Sommeil moyen (h)'**
  String get sleepHours;

  /// No description provided for @weeklyNote.
  ///
  /// In fr, this message translates to:
  /// **'Note de la semaine'**
  String get weeklyNote;

  /// No description provided for @weeklyNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Fatigue, douleurs, motivation...'**
  String get weeklyNoteHint;

  /// No description provided for @bodyTrendTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tendance physique'**
  String get bodyTrendTitle;

  /// No description provided for @bodyTrendEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Les courbes apparaîtront après tes premiers check-ins.'**
  String get bodyTrendEmpty;

  /// No description provided for @saveCheckIn.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder le check-in'**
  String get saveCheckIn;

  /// No description provided for @workoutHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get workoutHistoryTitle;

  /// No description provided for @workoutHistorySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Séances, calories et parcours'**
  String get workoutHistorySubtitle;

  /// No description provided for @sessionsOverview.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble des séances'**
  String get sessionsOverview;

  /// No description provided for @caloriesBurned.
  ///
  /// In fr, this message translates to:
  /// **'Calories brûlées'**
  String get caloriesBurned;

  /// No description provided for @totalDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance totale'**
  String get totalDistance;

  /// No description provided for @movingTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps actif'**
  String get movingTime;

  /// No description provided for @recentSessions.
  ///
  /// In fr, this message translates to:
  /// **'Séances récentes'**
  String get recentSessions;

  /// No description provided for @noSessionsYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune séance enregistrée pour le moment.'**
  String get noSessionsYet;

  /// No description provided for @filters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filters;

  /// No description provided for @goalsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Targets'**
  String get goalsTitle;

  /// No description provided for @goalsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs semaine et performance'**
  String get goalsSubtitle;

  /// No description provided for @targetsHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Tes objectifs actifs'**
  String get targetsHeadline;

  /// No description provided for @weeklyDistanceTarget.
  ///
  /// In fr, this message translates to:
  /// **'Distance hebdomadaire'**
  String get weeklyDistanceTarget;

  /// No description provided for @weeklySessionsTarget.
  ///
  /// In fr, this message translates to:
  /// **'Séances par semaine'**
  String get weeklySessionsTarget;

  /// No description provided for @weeklyCaloriesTarget.
  ///
  /// In fr, this message translates to:
  /// **'Calories sportives'**
  String get weeklyCaloriesTarget;

  /// No description provided for @weeklyTrainingTimeTarget.
  ///
  /// In fr, this message translates to:
  /// **'Temps d\'entraînement'**
  String get weeklyTrainingTimeTarget;

  /// No description provided for @weightTarget.
  ///
  /// In fr, this message translates to:
  /// **'Poids cible'**
  String get weightTarget;

  /// No description provided for @performanceTarget.
  ///
  /// In fr, this message translates to:
  /// **'Performance cible'**
  String get performanceTarget;

  /// No description provided for @coachTitle.
  ///
  /// In fr, this message translates to:
  /// **'Coach Gemini'**
  String get coachTitle;

  /// No description provided for @coachSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Conseils, alertes et exercices'**
  String get coachSubtitle;

  /// No description provided for @coachHeadline.
  ///
  /// In fr, this message translates to:
  /// **'Analyse personnelle avec Gemini'**
  String get coachHeadline;

  /// No description provided for @geminiApiKey.
  ///
  /// In fr, this message translates to:
  /// **'Assistant IA'**
  String get geminiApiKey;

  /// No description provided for @geminiApiKeyHint.
  ///
  /// In fr, this message translates to:
  /// **'Géré par l\'API'**
  String get geminiApiKeyHint;

  /// No description provided for @geminiPrivacyNote.
  ///
  /// In fr, this message translates to:
  /// **'Le mobile ne manipule aucune clé. Il envoie seulement tes demandes à l\'API et affiche les conseils reçus.'**
  String get geminiPrivacyNote;

  /// No description provided for @saveGeminiKey.
  ///
  /// In fr, this message translates to:
  /// **'Statut du coach'**
  String get saveGeminiKey;

  /// No description provided for @geminiBackendStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Assistant connecté à l\'API'**
  String get geminiBackendStatusTitle;

  /// No description provided for @geminiBackendStatusBody.
  ///
  /// In fr, this message translates to:
  /// **'Quand le service est actif, l\'app peut demander un bilan, des alertes d\'effort et des propositions d\'exercices.'**
  String get geminiBackendStatusBody;

  /// No description provided for @effortWarningTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alerte effort insuffisant'**
  String get effortWarningTitle;

  /// No description provided for @effortWarningBody.
  ///
  /// In fr, this message translates to:
  /// **'Le coach comparera tes séances aux targets et te dira ce qu\'il reste à faire.'**
  String get effortWarningBody;

  /// No description provided for @exerciseSuggestionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Propositions d\'exercices'**
  String get exerciseSuggestionsTitle;

  /// No description provided for @exerciseSuggestionsBody.
  ///
  /// In fr, this message translates to:
  /// **'Gemini pourra proposer une sortie facile, une marche rapide ou du renforcement selon ton niveau.'**
  String get exerciseSuggestionsBody;

  /// No description provided for @weeklyReviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bilan hebdomadaire'**
  String get weeklyReviewTitle;

  /// No description provided for @weeklyReviewBody.
  ///
  /// In fr, this message translates to:
  /// **'Chaque semaine, l\'app analysera progression, calories, poids et récupération.'**
  String get weeklyReviewBody;

  /// No description provided for @physicalProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression physique'**
  String get physicalProgress;

  /// No description provided for @profileMissing.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute ton poids et ta taille pour calculer calories et tendances.'**
  String get profileMissing;

  /// No description provided for @caloriesThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Calories semaine'**
  String get caloriesThisWeek;

  /// No description provided for @coachPreview.
  ///
  /// In fr, this message translates to:
  /// **'Conseil coach'**
  String get coachPreview;

  /// No description provided for @coachPreviewEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Le coach sera disponible lorsque l\'API sera connectée.'**
  String get coachPreviewEmpty;

  /// No description provided for @openMenu.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le menu'**
  String get openMenu;

  /// No description provided for @draftSaved.
  ///
  /// In fr, this message translates to:
  /// **'Écran prêt. Prochaine étape : stockage local.'**
  String get draftSaved;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ton sport, tes stats, tes objectifs'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In fr, this message translates to:
  /// **'GymFlow reste personnel : pas de réseau social, pas d\'abonnement, juste tes parcours, tes performances et ton évolution.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil de départ'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingProfileBody.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne poids, taille et niveau pour calculer des calories et des targets plus justes.'**
  String get onboardingProfileBody;

  /// No description provided for @onboardingTargetsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Targets et coach'**
  String get onboardingTargetsTitle;

  /// No description provided for @onboardingTargetsBody.
  ///
  /// In fr, this message translates to:
  /// **'Définis ton objectif principal. Gemini pourra ensuite proposer des exercices et signaler les semaines trop faibles.'**
  String get onboardingTargetsBody;

  /// No description provided for @onboardingStep.
  ///
  /// In fr, this message translates to:
  /// **'Étape {current} / {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @onboardingBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// No description provided for @onboardingFinish.
  ///
  /// In fr, this message translates to:
  /// **'Entrer dans GymFlow'**
  String get onboardingFinish;

  /// No description provided for @onboardingSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// No description provided for @onboardingGoalLoseWeight.
  ///
  /// In fr, this message translates to:
  /// **'Perdre du poids'**
  String get onboardingGoalLoseWeight;

  /// No description provided for @onboardingGoalEndurance.
  ///
  /// In fr, this message translates to:
  /// **'Améliorer l\'endurance'**
  String get onboardingGoalEndurance;

  /// No description provided for @onboardingGoalRestart.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre le sport'**
  String get onboardingGoalRestart;

  /// No description provided for @onboardingGoalRunFaster.
  ///
  /// In fr, this message translates to:
  /// **'Courir plus vite'**
  String get onboardingGoalRunFaster;

  /// No description provided for @onboardingGoalGoFurther.
  ///
  /// In fr, this message translates to:
  /// **'Faire plus de distance'**
  String get onboardingGoalGoFurther;

  /// No description provided for @onboardingGoalMaintain.
  ///
  /// In fr, this message translates to:
  /// **'Maintenir la forme'**
  String get onboardingGoalMaintain;

  /// No description provided for @onboardingGoalCyclingWalking.
  ///
  /// In fr, this message translates to:
  /// **'Progresser en vélo ou marche'**
  String get onboardingGoalCyclingWalking;

  /// No description provided for @onboardingGoalOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get onboardingGoalOther;

  /// No description provided for @customGoal.
  ///
  /// In fr, this message translates to:
  /// **'Précise ton objectif'**
  String get customGoal;

  /// No description provided for @customGoalHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : préparer un 10 km, mieux récupérer...'**
  String get customGoalHint;

  /// No description provided for @onboardingFavoriteSport.
  ///
  /// In fr, this message translates to:
  /// **'Sport favori'**
  String get onboardingFavoriteSport;

  /// No description provided for @onboardingWeeklyTarget.
  ///
  /// In fr, this message translates to:
  /// **'Target semaine'**
  String get onboardingWeeklyTarget;

  /// No description provided for @activityReadyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prêt à lancer'**
  String get activityReadyTitle;

  /// No description provided for @activityReadyBody.
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton sport, attends le signal GPS, puis démarre la séance.'**
  String get activityReadyBody;

  /// No description provided for @trackingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tracking'**
  String get trackingTitle;

  /// No description provided for @gpsWaiting.
  ///
  /// In fr, this message translates to:
  /// **'GPS en attente'**
  String get gpsWaiting;

  /// No description provided for @gpsReady.
  ///
  /// In fr, this message translates to:
  /// **'GPS prêt'**
  String get gpsReady;

  /// No description provided for @liveSession.
  ///
  /// In fr, this message translates to:
  /// **'Séance en cours'**
  String get liveSession;

  /// No description provided for @pausedSession.
  ///
  /// In fr, this message translates to:
  /// **'Séance en pause'**
  String get pausedSession;

  /// No description provided for @elapsedTime.
  ///
  /// In fr, this message translates to:
  /// **'Chrono'**
  String get elapsedTime;

  /// No description provided for @currentSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse'**
  String get currentSpeed;

  /// No description provided for @elevation.
  ///
  /// In fr, this message translates to:
  /// **'Dénivelé'**
  String get elevation;

  /// No description provided for @estimatedCalories.
  ///
  /// In fr, this message translates to:
  /// **'Calories estimées'**
  String get estimatedCalories;

  /// No description provided for @routePreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu parcours'**
  String get routePreview;

  /// No description provided for @liveRoute.
  ///
  /// In fr, this message translates to:
  /// **'Parcours en direct'**
  String get liveRoute;

  /// No description provided for @currentLocation.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get currentLocation;

  /// No description provided for @currentLocationUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Position indisponible. Vérifie l\'autorisation GPS.'**
  String get currentLocationUnavailable;

  /// No description provided for @pause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get resume;

  /// No description provided for @finish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finish;

  /// No description provided for @sessionSummaryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résumé séance'**
  String get sessionSummaryTitle;

  /// No description provided for @workoutSavedDraft.
  ///
  /// In fr, this message translates to:
  /// **'Vérifie les métriques, ajoute ton ressenti, puis sauvegarde la séance.'**
  String get workoutSavedDraft;

  /// No description provided for @perceivedEffort.
  ///
  /// In fr, this message translates to:
  /// **'Effort perçu'**
  String get perceivedEffort;

  /// No description provided for @feeling.
  ///
  /// In fr, this message translates to:
  /// **'Ressenti'**
  String get feeling;

  /// No description provided for @sessionNote.
  ///
  /// In fr, this message translates to:
  /// **'Note de séance'**
  String get sessionNote;

  /// No description provided for @sessionNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Comment tu t\'es senti ?'**
  String get sessionNotesHint;

  /// No description provided for @saveWorkout.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder la séance'**
  String get saveWorkout;

  /// No description provided for @routePoints.
  ///
  /// In fr, this message translates to:
  /// **'Points GPS'**
  String get routePoints;

  /// No description provided for @averageSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse moyenne'**
  String get averageSpeed;

  /// No description provided for @notConnectedYet.
  ///
  /// In fr, this message translates to:
  /// **'GPS actif. Garde l\'écran ouvert pendant la séance.'**
  String get notConnectedYet;

  /// No description provided for @statsThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get statsThisWeek;

  /// No description provided for @statsThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get statsThisMonth;

  /// No description provided for @statsThisYear.
  ///
  /// In fr, this message translates to:
  /// **'Cette année'**
  String get statsThisYear;

  /// No description provided for @statsPeriodWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine'**
  String get statsPeriodWeek;

  /// No description provided for @statsPeriodMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get statsPeriodMonth;

  /// No description provided for @statsPeriodYear.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get statsPeriodYear;

  /// No description provided for @statsOverview.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble'**
  String get statsOverview;

  /// No description provided for @statsTrend.
  ///
  /// In fr, this message translates to:
  /// **'Tendance'**
  String get statsTrend;

  /// No description provided for @statsEmptyPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Les statistiques apparaîtront après tes premières séances sauvegardées.'**
  String get statsEmptyPeriod;

  /// No description provided for @sessions.
  ///
  /// In fr, this message translates to:
  /// **'Séances'**
  String get sessions;

  /// No description provided for @activeDays.
  ///
  /// In fr, this message translates to:
  /// **'Jours actifs'**
  String get activeDays;

  /// No description provided for @bestPace.
  ///
  /// In fr, this message translates to:
  /// **'Meilleure allure'**
  String get bestPace;

  /// No description provided for @longestDistance.
  ///
  /// In fr, this message translates to:
  /// **'Plus longue distance'**
  String get longestDistance;

  /// No description provided for @readyForNextSession.
  ///
  /// In fr, this message translates to:
  /// **'Prêt pour la prochaine session ?'**
  String get readyForNextSession;

  /// No description provided for @run.
  ///
  /// In fr, this message translates to:
  /// **'Course'**
  String get run;

  /// No description provided for @ride.
  ///
  /// In fr, this message translates to:
  /// **'Vélo'**
  String get ride;

  /// No description provided for @walk.
  ///
  /// In fr, this message translates to:
  /// **'Marche'**
  String get walk;

  /// No description provided for @startWorkout.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer une session'**
  String get startWorkout;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get start;

  /// No description provided for @todayDistance.
  ///
  /// In fr, this message translates to:
  /// **'0.00 km aujourd\'hui'**
  String get todayDistance;

  /// No description provided for @distance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @time.
  ///
  /// In fr, this message translates to:
  /// **'Temps'**
  String get time;

  /// No description provided for @pace.
  ///
  /// In fr, this message translates to:
  /// **'Allure'**
  String get pace;

  /// No description provided for @weeklyGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif semaine'**
  String get weeklyGoal;

  /// No description provided for @weeklyGoalProgress.
  ///
  /// In fr, this message translates to:
  /// **'0 / 20 km'**
  String get weeklyGoalProgress;

  /// No description provided for @performance.
  ///
  /// In fr, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @record5k.
  ///
  /// In fr, this message translates to:
  /// **'Record 5 km'**
  String get record5k;

  /// No description provided for @averagePace.
  ///
  /// In fr, this message translates to:
  /// **'Allure moyenne'**
  String get averagePace;

  /// No description provided for @completedGoals.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs terminés'**
  String get completedGoals;

  /// No description provided for @emptyDuration.
  ///
  /// In fr, this message translates to:
  /// **'00:00:00'**
  String get emptyDuration;

  /// No description provided for @emptyDistanceKm.
  ///
  /// In fr, this message translates to:
  /// **'0.00 km'**
  String get emptyDistanceKm;

  /// No description provided for @emptyPace.
  ///
  /// In fr, this message translates to:
  /// **'-- /km'**
  String get emptyPace;

  /// No description provided for @emptyTime.
  ///
  /// In fr, this message translates to:
  /// **'0:00'**
  String get emptyTime;

  /// No description provided for @emptyValue.
  ///
  /// In fr, this message translates to:
  /// **'--'**
  String get emptyValue;

  /// No description provided for @zero.
  ///
  /// In fr, this message translates to:
  /// **'0'**
  String get zero;

  /// No description provided for @kilometersUnit.
  ///
  /// In fr, this message translates to:
  /// **'km'**
  String get kilometersUnit;

  /// No description provided for @hoursUnit.
  ///
  /// In fr, this message translates to:
  /// **'h'**
  String get hoursUnit;

  /// No description provided for @paceUnit.
  ///
  /// In fr, this message translates to:
  /// **'/km'**
  String get paceUnit;

  /// No description provided for @settingsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get languageSystem;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'FR'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'EN'**
  String get languageEnglish;

  /// No description provided for @settingsSport.
  ///
  /// In fr, this message translates to:
  /// **'Sport'**
  String get settingsSport;

  /// No description provided for @settingsUnits.
  ///
  /// In fr, this message translates to:
  /// **'Unités'**
  String get settingsUnits;

  /// No description provided for @unitsMetric.
  ///
  /// In fr, this message translates to:
  /// **'km'**
  String get unitsMetric;

  /// No description provided for @unitsImperial.
  ///
  /// In fr, this message translates to:
  /// **'mi'**
  String get unitsImperial;

  /// No description provided for @defaultSport.
  ///
  /// In fr, this message translates to:
  /// **'Sport par défaut'**
  String get defaultSport;

  /// No description provided for @weeklyTargetValue.
  ///
  /// In fr, this message translates to:
  /// **'{value} km par semaine'**
  String weeklyTargetValue(int value);

  /// No description provided for @settingsTracking.
  ///
  /// In fr, this message translates to:
  /// **'Tracking'**
  String get settingsTracking;

  /// No description provided for @gpsAccuracy.
  ///
  /// In fr, this message translates to:
  /// **'Précision GPS'**
  String get gpsAccuracy;

  /// No description provided for @gpsBalanced.
  ///
  /// In fr, this message translates to:
  /// **'Éco'**
  String get gpsBalanced;

  /// No description provided for @gpsHigh.
  ///
  /// In fr, this message translates to:
  /// **'Précise'**
  String get gpsHigh;

  /// No description provided for @gpsBest.
  ///
  /// In fr, this message translates to:
  /// **'Max'**
  String get gpsBest;

  /// No description provided for @autoPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause auto'**
  String get autoPause;

  /// No description provided for @autoPauseDescription.
  ///
  /// In fr, this message translates to:
  /// **'Met la session en pause quand tu t\'arrêtes.'**
  String get autoPauseDescription;

  /// No description provided for @countdown.
  ///
  /// In fr, this message translates to:
  /// **'Compte à rebours'**
  String get countdown;

  /// No description provided for @countdownDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute 3 secondes avant le départ.'**
  String get countdownDescription;

  /// No description provided for @voiceCues.
  ///
  /// In fr, this message translates to:
  /// **'Annonces vocales'**
  String get voiceCues;

  /// No description provided for @voiceCuesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Annonce les temps et distances pendant la session.'**
  String get voiceCuesDescription;

  /// No description provided for @keepScreenAwake.
  ///
  /// In fr, this message translates to:
  /// **'Écran actif'**
  String get keepScreenAwake;

  /// No description provided for @keepScreenAwakeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Garde l\'écran allumé pendant le tracking.'**
  String get keepScreenAwakeDescription;

  /// No description provided for @settingsPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get settingsPrivacy;

  /// No description provided for @saveRoutes.
  ///
  /// In fr, this message translates to:
  /// **'Sauver les parcours'**
  String get saveRoutes;

  /// No description provided for @saveRoutesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Conserve les points GPS pour revoir la trace.'**
  String get saveRoutesDescription;

  /// No description provided for @privateActivities.
  ///
  /// In fr, this message translates to:
  /// **'Activités privées'**
  String get privateActivities;

  /// No description provided for @privateActivitiesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Garde les sessions visibles seulement par toi.'**
  String get privateActivitiesDescription;

  /// No description provided for @settingsAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settingsAccount;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte connecté'**
  String get account;

  /// No description provided for @connectedAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte connecté à GymFlow.'**
  String get connectedAccount;

  /// No description provided for @connectedAs.
  ///
  /// In fr, this message translates to:
  /// **'Connecté avec {email}'**
  String connectedAs(String email);

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get signOut;

  /// No description provided for @signedOut.
  ///
  /// In fr, this message translates to:
  /// **'Tu es déconnecté.'**
  String get signedOut;

  /// No description provided for @decrease.
  ///
  /// In fr, this message translates to:
  /// **'Diminuer'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In fr, this message translates to:
  /// **'Augmenter'**
  String get increase;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
