import '../../../core/api/api_formatters.dart';

/// Ce que le serveur répond à l'enregistrement d'une séance : les records
/// tombés, la place sur le parcours rejoué, et le verdict du défi.
///
/// **C'est la seule source de vérité pour les félicitations.** L'application ne
/// devine plus si un record est battu : le serveur applique des marges
/// anti-bruit (1 % et 50 m sur la distance, 2 s/km sur l'allure, jamais d'allure
/// sous un kilomètre) que le client ne peut pas reproduire, et il compare sur
/// tout l'historique du sport — là où les statistiques sont bornées à une
/// période et appartiennent à un module verrouillable.
class WorkoutOutcome {
  const WorkoutOutcome({
    this.achievements = const [],
    this.routeComparison,
    this.challengeResult,
  });

  factory WorkoutOutcome.fromWorkoutResponse(Map<String, dynamic> response) {
    final rawAchievements = response['achievements'];
    return WorkoutOutcome(
      achievements: rawAchievements is List
          ? rawAchievements
                .whereType<Map>()
                .map((raw) => Achievement.fromJson(Map<String, dynamic>.from(raw)))
                .toList(growable: false)
          : const [],
      routeComparison: _mapOrNull(response['routeComparison']),
      challengeResult: _mapOrNull(response['challengeResult']),
    );
  }

  /// Records tombés pendant cette séance. **Liste non vide ⇒ félicitations.**
  final List<Achievement> achievements;

  final Map<String, dynamic>? routeComparison;
  final Map<String, dynamic>? challengeResult;

  bool get hasAchievements => achievements.isNotEmpty;

  /// Le record à mettre en avant : le premier annoncé par le serveur, qui les
  /// ordonne déjà par importance.
  Achievement? get headlineAchievement =>
      achievements.isEmpty ? null : achievements.first;

  /// Vrai quand le défi a été relevé.
  bool get challengeSucceeded => challengeResult?['succeeded'] == true;

  /// Vrai quand il faut fêter le défi — réussi, ou manqué de peu avec un record
  /// au passage. Le serveur tranche : un défi manqué de dix secondes sur la
  /// meilleure sortie de l'année mérite mieux qu'un écran rouge.
  bool get shouldCelebrateChallenge => challengeResult?['celebrate'] == true;

  /// Titre et message du verdict de défi, rédigés côté serveur.
  String? get challengeHeadline =>
      jsonString(jsonMap(challengeResult, 'appreciation'), 'headline');

  String? get challengeMessage =>
      jsonString(jsonMap(challengeResult, 'appreciation'), 'message');

  /// Vrai quand cette sortie est le meilleur temps sur le parcours rejoué.
  bool get isNewRouteBest => routeComparison?['isNewBest'] == true;

  String? get routeHeadline => jsonString(routeComparison, 'headline');

  String? get routeMessage => jsonString(routeComparison, 'message');

  static Map<String, dynamic>? _mapOrNull(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}

/// Un record tombé, prêt à être célébré.
class Achievement {
  const Achievement({
    required this.kind,
    required this.label,
    required this.headline,
    required this.message,
    this.improvement,
    this.unit,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      kind: json['kind']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      headline: json['headline']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      improvement: (json['improvement'] as num?)?.toDouble(),
      unit: json['unit']?.toString(),
    );
  }

  /// Constante de protocole : `LONGEST_DISTANCE`, `BEST_AVERAGE_PACE`… À ne
  /// jamais afficher telle quelle, c'est [label] qui est lisible.
  final String kind;

  final String label;

  /// Titre court et message chiffré, rédigés côté serveur : Android et iOS
  /// félicitent ainsi avec exactement les mêmes mots.
  final String headline;
  final String message;

  /// Gain, **toujours positif**, y compris pour une allure ou un chronomètre où
  /// la valeur baisse.
  final double? improvement;

  final String? unit;

  /// Première séance dans ce sport : une célébration, pas un record battu.
  bool get isFirstSession => kind == 'FIRST_SESSION';
}
