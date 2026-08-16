import '../../../core/api/api_formatters.dart';
import 'workout_challenge.dart';

class PersonalRecordSnapshot {
  const PersonalRecordSnapshot({
    required this.longestDistanceMeters,
    required this.bestPaceSecondsPerKm,
  });

  /// Lit les records **courants** rendus par `GET /workouts/records`.
  ///
  /// Remplace la lecture des statistiques, qui posait deux problèmes : leurs
  /// records sont bornés à une période, et elles appartiennent au module
  /// `STATS`, fermé par défaut — l'aperçu était donc vide sur la plupart des
  /// comptes, et faux sur les autres.
  ///
  /// La réponse est un tableau, un bloc par sport. On n'en interroge qu'un.
  factory PersonalRecordSnapshot.fromSportRecords(
    List<Map<String, dynamic>> sports,
  ) {
    if (sports.isEmpty) {
      return const PersonalRecordSnapshot(
        longestDistanceMeters: 0,
        bestPaceSecondsPerKm: 0,
      );
    }

    final records = sports.first['records'];
    var longestDistance = 0.0;
    var bestPace = 0;

    if (records is List) {
      for (final entry in records.whereType<Map>()) {
        final record = Map<String, dynamic>.from(entry);
        final value = jsonDouble(record, 'value');
        switch (record['kind']?.toString()) {
          case 'LONGEST_DISTANCE':
            longestDistance = value;
          case 'BEST_AVERAGE_PACE':
            bestPace = value.round();
        }
      }
    }

    return PersonalRecordSnapshot(
      longestDistanceMeters: longestDistance,
      bestPaceSecondsPerKm: bestPace,
    );
  }

  final double longestDistanceMeters;
  final int bestPaceSecondsPerKm;
}

class WorkoutRating {
  const WorkoutRating({
    required this.score,
    required this.distanceRecord,
    required this.paceRecord,
    required this.challengeCompleted,
    required this.challengeProgress,
  });

  factory WorkoutRating.evaluate({
    required double distanceMeters,
    required Duration elapsed,
    required int paceSecondsPerKm,
    WorkoutChallenge? challenge,
    PersonalRecordSnapshot? records,
  }) {
    final challengeProgress = challenge?.progressFor(distanceMeters) ?? 0.0;
    final challengeCompleted =
        challenge?.isCompletedBy(
          distanceMeters: distanceMeters,
          elapsed: elapsed,
        ) ??
        false;
    final challengeMissed =
        challenge?.isDeadlineMissedBy(
          distanceMeters: distanceMeters,
          elapsed: elapsed,
        ) ??
        false;
    final distanceRecord =
        records != null &&
        records.longestDistanceMeters > 0 &&
        distanceMeters > records.longestDistanceMeters;
    final paceRecord =
        records != null &&
        records.bestPaceSecondsPerKm > 0 &&
        paceSecondsPerKm > 0 &&
        paceSecondsPerKm < records.bestPaceSecondsPerKm;

    var score = 45;
    if (distanceMeters >= 1000) score += 10;
    if (distanceMeters >= 5000) score += 8;
    if (elapsed.inMinutes >= 20) score += 7;

    if (challenge?.hasDistanceTarget == true) {
      score += challengeCompleted
          ? 25
          : ((challengeProgress * 18).round() - (challengeMissed ? 8 : 0));
    }

    if (distanceRecord) score += 16;
    if (paceRecord) score += 12;

    return WorkoutRating(
      score: score.clamp(0, 100),
      distanceRecord: distanceRecord,
      paceRecord: paceRecord,
      challengeCompleted: challengeCompleted,
      challengeProgress: challengeProgress,
    );
  }

  final int score;
  final bool distanceRecord;
  final bool paceRecord;
  final bool challengeCompleted;
  final double challengeProgress;

  bool get hasRecord => distanceRecord || paceRecord;
}
