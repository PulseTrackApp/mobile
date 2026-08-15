import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/activity/models/workout_challenge.dart';
import 'package:mobile_flutter/features/activity/models/workout_rating.dart';

void main() {
  test('marque le record distance et le defi reussi', () {
    final challenge = WorkoutChallenge.distanceTime(
      targetDistanceMeters: 5000,
      targetDuration: const Duration(minutes: 30),
    );
    final records = const PersonalRecordSnapshot(
      longestDistanceMeters: 4500,
      bestPaceSecondsPerKm: 400,
    );

    final rating = WorkoutRating.evaluate(
      distanceMeters: 5200,
      elapsed: const Duration(minutes: 28),
      paceSecondsPerKm: 323,
      challenge: challenge,
      records: records,
    );

    expect(rating.challengeCompleted, isTrue);
    expect(rating.distanceRecord, isTrue);
    expect(rating.paceRecord, isTrue);
    expect(rating.score, 100);
  });

  test('note une seance partielle sans inventer de record', () {
    final challenge = WorkoutChallenge.distanceTime(
      targetDistanceMeters: 5000,
      targetDuration: const Duration(minutes: 30),
    );
    final records = const PersonalRecordSnapshot(
      longestDistanceMeters: 8000,
      bestPaceSecondsPerKm: 330,
    );

    final rating = WorkoutRating.evaluate(
      distanceMeters: 3000,
      elapsed: const Duration(minutes: 31),
      paceSecondsPerKm: 620,
      challenge: challenge,
      records: records,
    );

    expect(rating.challengeCompleted, isFalse);
    expect(rating.distanceRecord, isFalse);
    expect(rating.paceRecord, isFalse);
    expect(rating.score, lessThan(70));
  });
}
