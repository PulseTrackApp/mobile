import '../../../core/api/api_formatters.dart';
import 'workout_challenge.dart';

class PersonalRecordSnapshot {
  const PersonalRecordSnapshot({
    required this.longestDistanceMeters,
    required this.bestPaceSecondsPerKm,
  });

  factory PersonalRecordSnapshot.fromStats(Map<String, dynamic>? stats) {
    final records = jsonMap(stats, 'records');
    return PersonalRecordSnapshot(
      longestDistanceMeters: jsonDouble(records, 'longestDistanceMeters'),
      bestPaceSecondsPerKm: jsonInt(records, 'bestPaceSecondsPerKm'),
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
